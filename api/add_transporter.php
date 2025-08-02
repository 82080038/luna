<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

function sendJsonResponse($success, $data = null, $error = null, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'error' => $error
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        sendJsonResponse(false, null, 'Invalid JSON input', 400);
    }
    
    // Validasi input
    $required_fields = ['username', 'password', 'nama_depan', 'nama_belakang', 'telepon', 'email', 'provinsi_id', 'kabupaten_id', 'kecamatan_id', 'kelurahan_id'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            sendJsonResponse(false, null, "Field '$field' is required", 400);
        }
    }
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Mulai transaksi
    $pdo->beginTransaction();
    
    try {
        // 1. Cek apakah username sudah ada
        $stmt = $pdo->prepare("SELECT id FROM user WHERE username = ?");
        $stmt->execute([$input['username']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'Username sudah digunakan', 400);
        }
        
        // 2. Cek apakah telepon sudah ada
        $stmt = $pdo->prepare("
            SELECT oi.id FROM orang_identitas oi 
            JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
            WHERE mji.nama_jenis = 'Telepon' AND oi.nilai_identitas = ?
        ");
        $stmt->execute([$input['telepon']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'Nomor telepon sudah digunakan', 400);
        }
        
        // 3. Cek apakah email sudah ada
        $stmt = $pdo->prepare("
            SELECT oi.id FROM orang_identitas oi 
            JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
            WHERE mji.nama_jenis = 'Email' AND oi.nilai_identitas = ?
        ");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'Email sudah digunakan', 400);
        }
        
        // 4. Validasi alamat
        $stmt = $pdo->prepare("SELECT id FROM cbo_propinsi WHERE id = ?");
        $stmt->execute([$input['provinsi_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Provinsi tidak valid', 400);
        }
        
        $stmt = $pdo->prepare("SELECT id FROM cbo_kab_kota WHERE id = ? AND propinsi_id = ?");
        $stmt->execute([$input['kabupaten_id'], $input['provinsi_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Kabupaten tidak valid', 400);
        }
        
        $stmt = $pdo->prepare("SELECT id FROM cbo_kecamatan WHERE id = ? AND kabupaten_kota_id = ?");
        $stmt->execute([$input['kecamatan_id'], $input['kabupaten_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Kecamatan tidak valid', 400);
        }
        
        $stmt = $pdo->prepare("SELECT id FROM cbo_desa WHERE id = ? AND kecamatan_id = ?");
        $stmt->execute([$input['kelurahan_id'], $input['kecamatan_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Kelurahan tidak valid', 400);
        }
        
        // 5. Insert data orang
        $stmt = $pdo->prepare("
            INSERT INTO orang (nama_depan, nama_tengah, nama_belakang, created_at) 
            VALUES (?, ?, ?, NOW())
        ");
        $stmt->execute([
            $input['nama_depan'],
            $input['nama_tengah'] ?? null,
            $input['nama_belakang']
        ]);
        $orang_id = $pdo->lastInsertId();
        
        // 6. Insert alamat
        $stmt = $pdo->prepare("
            INSERT INTO orang_alamat (orang_id, propinsi_id, kabupaten_kota_id, kecamatan_id, desa_id, alamat_lengkap, is_primary, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, 1, NOW())
        ");
        $stmt->execute([
            $orang_id,
            $input['provinsi_id'],
            $input['kabupaten_id'],
            $input['kecamatan_id'],
            $input['kelurahan_id'],
            $input['alamat_lengkap'] ?? ''
        ]);
        
        // 7. Insert identitas (telepon)
        $stmt = $pdo->prepare("SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon'");
        $stmt->execute();
        $telepon_jenis_id = $stmt->fetchColumn();
        
        $stmt = $pdo->prepare("
            INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, created_at) 
            VALUES (?, ?, ?, 1, NOW())
        ");
        $stmt->execute([$orang_id, $telepon_jenis_id, $input['telepon']]);
        
        // 8. Insert identitas (email)
        $stmt = $pdo->prepare("SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Email'");
        $stmt->execute();
        $email_jenis_id = $stmt->fetchColumn();
        
        $stmt = $pdo->prepare("
            INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, created_at) 
            VALUES (?, ?, ?, 1, NOW())
        ");
        $stmt->execute([$orang_id, $email_jenis_id, $input['email']]);
        
        // 9. Insert user
        $stmt = $pdo->prepare("SELECT id FROM role WHERE nama_role = 'Transporter'");
        $stmt->execute();
        $role_id = $stmt->fetchColumn();
        
        $password_hash = password_hash($input['password'], PASSWORD_DEFAULT);
        
        $stmt = $pdo->prepare("
            INSERT INTO user (username, password_hash, role_id, orang_id, is_active, created_at) 
            VALUES (?, ?, ?, ?, 1, NOW())
        ");
        $stmt->execute([
            $input['username'],
            $password_hash,
            $role_id,
            $orang_id
        ]);
        $user_id = $pdo->lastInsertId();
        
        // Commit transaksi
        $pdo->commit();
        
        // Response sukses
        sendJsonResponse(true, [
            'user_id' => $user_id,
            'username' => $input['username'],
            'password' => $input['password'],
            'nama_depan' => $input['nama_depan'],
            'nama_lengkap' => trim($input['nama_depan'] . ' ' . ($input['nama_tengah'] ?? '') . ' ' . $input['nama_belakang']),
            'telepon' => $input['telepon'],
            'email' => $input['email'],
            'role' => 'Transporter'
        ], 'Transporter berhasil ditambahkan');
        
    } catch (Exception $e) {
        $pdo->rollback();
        throw $e;
    }
    
} catch (PDOException $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Server error: ' . $e->getMessage(), 500);
}
?> 