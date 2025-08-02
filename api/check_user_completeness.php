<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || empty($input['user_id'])) {
        sendJsonResponse(false, null, 'User ID is required', 400);
    }
    
    $pdo = new PDO("mysql:host=$host;dbname=sistem_angka", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Get user data with role information
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.is_active,
            r.nama_role,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang,
            o.jenis_kelamin,
            o.tanggal_lahir,
            o.tempat_lahir
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        WHERE u.id = ?
    ");
    
    $stmt->execute([$input['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendJsonResponse(false, null, 'User not found', 404);
    }
    
    // Get user's contact information
    $stmt = $pdo->prepare("
        SELECT 
            mji.nama_jenis,
            oi.nilai_identitas,
            oi.is_primary
        FROM orang_identitas oi
        JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
        WHERE oi.orang_id = (SELECT orang_id FROM user WHERE id = ?)
        ORDER BY oi.is_primary DESC
    ");
    
    $stmt->execute([$input['user_id']]);
    $contacts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get user's address information
    $stmt = $pdo->prepare("
        SELECT 
            oa.id,
            oa.alamat_lengkap,
            oa.rt,
            oa.rw,
            oa.kode_pos,
            oa.is_primary,
            cp.nama_propinsi,
            ckk.nama_kab_kota,
            ck.nama_kecamatan,
            cd.nama_desa
        FROM orang_alamat oa
        LEFT JOIN cbo_propinsi cp ON oa.propinsi_id = cp.id
        LEFT JOIN cbo_kab_kota ckk ON oa.kabupaten_kota_id = ckk.id
        LEFT JOIN cbo_kecamatan ck ON oa.kecamatan_id = ck.id
        LEFT JOIN cbo_desa cd ON oa.kelurahan_desa_id = cd.id
        WHERE oa.orang_id = (SELECT orang_id FROM user WHERE id = ?)
        ORDER BY oa.is_primary DESC
    ");
    
    $stmt->execute([$input['user_id']]);
    $addresses = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Build contact info
    $email = '';
    $telepon = '';
    $nik = '';
    $whatsapp = '';
    
    foreach ($contacts as $contact) {
        switch ($contact['nama_jenis']) {
            case 'Email':
                if ($contact['is_primary']) $email = $contact['nilai_identitas'];
                break;
            case 'Telepon':
                if ($contact['is_primary']) $telepon = $contact['nilai_identitas'];
                break;
            case 'NIK':
                if ($contact['is_primary']) $nik = $contact['nilai_identitas'];
                break;
            case 'WhatsApp':
                if ($contact['is_primary']) $whatsapp = $contact['nilai_identitas'];
                break;
        }
    }
    
    // Check completeness
    $completeness = [
        'personal_data' => [
            'nama_depan' => !empty($user['nama_depan']),
            'jenis_kelamin' => !empty($user['jenis_kelamin']),
            'tanggal_lahir' => !empty($user['tanggal_lahir']),
            'tempat_lahir' => !empty($user['tempat_lahir'])
        ],
        'contact_data' => [
            'email' => !empty($email),
            'telepon' => !empty($telepon),
            'nik' => !empty($nik),
            'whatsapp' => !empty($whatsapp)
        ],
        'address_data' => [
            'has_address' => count($addresses) > 0,
            'primary_address' => false,
            'address_details' => false
        ]
    ];
    
    // Check address completeness
    if (count($addresses) > 0) {
        $primary_address = array_filter($addresses, function($addr) {
            return $addr['is_primary'] == 1;
        });
        
        if (!empty($primary_address)) {
            $primary = reset($primary_address);
            $completeness['address_data']['primary_address'] = true;
            $completeness['address_data']['address_details'] = !empty($primary['alamat_lengkap']) && 
                                                             !empty($primary['nama_propinsi']) && 
                                                             !empty($primary['nama_kab_kota']) && 
                                                             !empty($primary['nama_kecamatan']) && 
                                                             !empty($primary['nama_desa']);
        }
    }
    
    // Calculate overall completeness percentage
    $total_fields = 0;
    $completed_fields = 0;
    
    // Personal data (nama_tengah and nama_belakang are optional)
    foreach ($completeness['personal_data'] as $field => $completed) {
        $total_fields++;
        if ($completed) $completed_fields++;
    }
    
    // Contact data
    foreach ($completeness['contact_data'] as $field => $completed) {
        $total_fields++;
        if ($completed) $completed_fields++;
    }
    
    // Address data
    foreach ($completeness['address_data'] as $field => $completed) {
        $total_fields++;
        if ($completed) $completed_fields++;
    }
    
    $completeness_percentage = round(($completed_fields / $total_fields) * 100, 1);
    
    // Determine completeness status
    $completeness_status = 'incomplete';
    if ($completeness_percentage >= 90) {
        $completeness_status = 'complete';
    } elseif ($completeness_percentage >= 70) {
        $completeness_status = 'mostly_complete';
    } elseif ($completeness_percentage >= 50) {
        $completeness_status = 'partially_complete';
    }
    
    // Prepare response data
    $response_data = [
        'user_id' => $user['id'],
        'username' => $user['username'],
        'role' => $user['nama_role'],
        'nama_lengkap' => trim($user['nama_depan'] . ' ' . 
                              ($user['nama_tengah'] ? $user['nama_tengah'] . ' ' : '') . 
                              ($user['nama_belakang'] ? $user['nama_belakang'] : '')),
        'completeness' => $completeness,
        'completeness_percentage' => $completeness_percentage,
        'completeness_status' => $completeness_status,
        'personal_data' => [
            'nama_depan' => $user['nama_depan'],
            'nama_tengah' => $user['nama_tengah'],
            'nama_belakang' => $user['nama_belakang'],
            'jenis_kelamin' => $user['jenis_kelamin'],
            'tanggal_lahir' => $user['tanggal_lahir'],
            'tempat_lahir' => $user['tempat_lahir']
        ],
        'contact_data' => [
            'email' => $email,
            'telepon' => $telepon,
            'nik' => $nik,
            'whatsapp' => $whatsapp
        ],
        'address_data' => $addresses
    ];
    
    sendJsonResponse(true, $response_data);
    
} catch (PDOException $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Server error: ' . $e->getMessage(), 500);
}
?> 