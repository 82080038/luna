<?php
require_once 'config.php';
setCommonHeaders();

// Establish database connections
try {
    $pdo_main = getMainDatabaseConnection();
    $pdo_address = getAddressDatabaseConnection();
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database connection failed: ' . $e->getMessage(), 500);
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    sendJsonResponse(false, null, 'Invalid JSON input', 400);
}

// Validate required fields
$required_fields = ['nama_depan', 'jenis_kelamin', 'telepon', 'alamat_lengkap', 'provinsi_id', 'kabupaten_kota_id', 'kecamatan_id', 'kelurahan_desa_id'];

foreach ($required_fields as $field) {
    if (!isset($input[$field]) || empty($input[$field])) {
        sendJsonResponse(false, null, "Field '$field' is required", 400);
    }
}

// Validate that only Super Admin can add BOS
// In a real application, you would validate the current user's session/token
// For now, we'll add a simple check to ensure this API is only called by Super Admin
// This should be enhanced with proper authentication/authorization

// TODO: Implement proper session validation
// For now, we assume this API is only accessible by Super Admin through the dashboard

try {
    // Validate address data from sistem_alamat database
    $address_data = [];
    
    // Validate provinsi
    $stmt = $pdo_address->prepare("SELECT id_propinsi, nama_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
    $stmt->execute([$input['provinsi_id']]);
    $provinsi = $stmt->fetch();
    
    if (!$provinsi) {
        sendJsonResponse(false, null, 'Provinsi tidak ditemukan', 400);
    }
    $address_data['provinsi'] = $provinsi;
    
    // Validate kabupaten
    $stmt = $pdo_address->prepare("SELECT id_kab_kota, nama_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ? AND id_propinsi = ?");
    $stmt->execute([$input['kabupaten_kota_id'], $input['provinsi_id']]);
    $kabupaten = $stmt->fetch();
    
    if (!$kabupaten) {
        sendJsonResponse(false, null, 'Kabupaten/Kota tidak ditemukan', 400);
    }
    $address_data['kabupaten'] = $kabupaten;
    
    // Validate kecamatan
    $stmt = $pdo_address->prepare("SELECT id_kecamatan, nama_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ? AND id_kab_kota = ?");
    $stmt->execute([$input['kecamatan_id'], $input['kabupaten_kota_id']]);
    $kecamatan = $stmt->fetch();
    
    if (!$kecamatan) {
        sendJsonResponse(false, null, 'Kecamatan tidak ditemukan', 400);
    }
    $address_data['kecamatan'] = $kecamatan;
    
    // Validate kelurahan
    $stmt = $pdo_address->prepare("SELECT id_desa, nama_desa FROM cbo_desa WHERE id_desa = ? AND id_kecamatan = ?");
    $stmt->execute([$input['kelurahan_desa_id'], $input['kecamatan_id']]);
    $kelurahan = $stmt->fetch();
    
    if (!$kelurahan) {
        sendJsonResponse(false, null, 'Kelurahan/Desa tidak ditemukan', 400);
    }
    $address_data['kelurahan'] = $kelurahan;
    
    // Check if phone number already exists
    $stmt = $pdo_main->prepare("
        SELECT oi.id FROM orang_identitas oi 
        JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
        WHERE mji.nama_jenis = 'Telepon' AND oi.nilai_identitas = ?
    ");
    $stmt->execute([$input['telepon']]);
    
    if ($stmt->fetch()) {
        sendJsonResponse(false, null, 'Nomor telepon sudah terdaftar', 400);
    }
    
    // Start transaction
    $pdo_main->beginTransaction();
    
    // 1. Insert into orang table
    $stmt = $pdo_main->prepare("INSERT INTO orang (nama_depan, jenis_kelamin) VALUES (?, ?)");
    $stmt->execute([$input['nama_depan'], $input['jenis_kelamin']]);
    $orang_id = $pdo_main->lastInsertId();
    
    // 2. Insert contact information
    $stmt = $pdo_main->prepare("
        INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified)
        VALUES (?, (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon'), ?, TRUE, TRUE)
    ");
    $stmt->execute([$orang_id, $input['telepon']]);
    
    // 3. Insert address information dengan struktur baru
    $stmt = $pdo_main->prepare("
        INSERT INTO orang_alamat (
            id_orang, id_jenis_alamat, id_negara, id_propinsi, id_kab_kota, 
            id_kecamatan, id_desa, nama_alamat, alamat_utama, aktif
        ) VALUES (?, 1, 1, ?, ?, ?, ?, ?, 'Y', 'Y')
    ");
    $stmt->execute([
        $orang_id,
        $input['provinsi_id'],
        $input['kabupaten_kota_id'],
        $input['kecamatan_id'],
        $input['kelurahan_desa_id'],
        $input['alamat_lengkap']
    ]);
    
    // 4. Create user account
    $password_hash = password_hash($input['telepon'], PASSWORD_DEFAULT);
    $stmt = $pdo_main->prepare("
        INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by)
        VALUES (?, 2, ?, ?, TRUE, 1)
    ");
    $stmt->execute([$orang_id, $input['telepon'], $password_hash]);
    $user_id = $pdo_main->lastInsertId();
    
    // 5. Create user ownership
    $stmt = $pdo_main->prepare("
        INSERT INTO user_ownership (owner_id, owned_id, relationship_type)
        VALUES (?, ?, 'SuperAdmin-Bos')
    ");
    $stmt->execute([1, $user_id]);
    
    // Commit transaction
    $pdo_main->commit();
    
    // Build full address for response
    $alamat_lengkap = $input['alamat_lengkap'] . ', ' . $kelurahan['nama_desa'] . ', ' . $kecamatan['nama_kecamatan'] . ', ' . $kabupaten['nama_kab_kota'] . ', ' . $provinsi['nama_propinsi'];
    
    // Return success response
    $response_data = [
        'user_id' => $user_id,
        'orang_id' => $orang_id,
        'username' => $input['telepon'],
        'password' => $input['telepon'], // Password same as phone number
        'nama_depan' => $input['nama_depan'],
        'alamat_lengkap' => $alamat_lengkap,
        'address_data' => [
            'provinsi' => $provinsi['nama_propinsi'],
            'kabupaten' => $kabupaten['nama_kab_kota'],
            'kecamatan' => $kecamatan['nama_kecamatan'],
            'kelurahan' => $kelurahan['nama_desa']
        ],
        'address_ids' => [
            'provinsi_id' => $input['provinsi_id'],
            'kabupaten_id' => $input['kabupaten_kota_id'],
            'kecamatan_id' => $input['kecamatan_id'],
            'kelurahan_id' => $input['kelurahan_desa_id']
        ]
    ];
    
    sendJsonResponse(true, $response_data, 'Bos berhasil ditambahkan');
    
} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo_main->inTransaction()) {
        $pdo_main->rollBack();
    }
    
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 