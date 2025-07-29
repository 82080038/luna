<?php
require_once 'config.php';
setCommonHeaders();

// Establish database connection
try {
    $pdo = getDatabaseConnection();
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
    if (empty($input[$field])) {
        sendJsonResponse(false, null, "Field '$field' is required", 400);
    }
}

// Validate phone number format
if (!preg_match('/^[0-9]{10,13}$/', $input['telepon'])) {
    sendJsonResponse(false, null, 'Nomor telepon harus 10-13 digit angka', 400);
}

// Auto-generate username if not provided
if (empty($input['username'])) {
    $input['username'] = $input['telepon'];
}

// Auto-generate password if not provided
if (empty($input['password'])) {
    $input['password'] = $input['telepon'];
}

// Check if username already exists
$stmt = $pdo->prepare("SELECT id FROM user WHERE username = ?");
$stmt->execute([$input['username']]);
if ($stmt->fetch()) {
    sendJsonResponse(false, null, 'Username sudah digunakan', 400);
}

// Check if phone number already exists as a user (not just in orang_identitas)
$stmt = $pdo->prepare("
    SELECT u.id, o.nama_depan, o.nama_belakang
    FROM user u
    JOIN orang o ON u.orang_id = o.id
    JOIN orang_identitas oi ON o.id = oi.orang_id
    JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
    WHERE mji.nama_jenis = 'Telepon' 
    AND oi.nilai_identitas = ?
    AND oi.is_primary = TRUE
");
$stmt->execute([$input['telepon']]);
$existingUser = $stmt->fetch();

if ($existingUser) {
    $nama_lengkap = trim($existingUser['nama_depan'] . ' ' . $existingUser['nama_belakang']);
    sendJsonResponse(false, null, 'Nomor telepon sudah terdaftar sebagai user atas nama: ' . $nama_lengkap, 400);
}

try {
    // Start transaction
    $pdo->beginTransaction();
    
    // 1. Insert into orang table (minimal data)
    $stmt = $pdo->prepare("
        INSERT INTO orang (
            nama_depan, jenis_kelamin
        ) VALUES (?, ?)
    ");
    
    $stmt->execute([
        $input['nama_depan'],
        $input['jenis_kelamin']
    ]);
    
    $orang_id = $pdo->lastInsertId();
    
    // 2. Insert contact information (orang_identitas)
    $contact_data = [
        ['Telepon', $input['telepon'], true]
    ];
    
    if (!empty($input['whatsapp'])) {
        $contact_data[] = ['WhatsApp', $input['whatsapp'], false];
    }
    
    foreach ($contact_data as $contact) {
        $stmt = $pdo->prepare("
            INSERT INTO orang_identitas (
                orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified
            ) VALUES (
                ?, (SELECT id FROM master_jenis_identitas WHERE nama_jenis = ?), ?, ?, TRUE
            )
        ");
        $stmt->execute([$orang_id, $contact[0], $contact[1], $contact[2]]);
    }
    
    // 3. Insert address information (orang_alamat)
    $stmt = $pdo->prepare("
        INSERT INTO orang_alamat (
            orang_id, alamat_jenis_id, kelurahan_desa_id, alamat_lengkap, is_primary, is_verified
        ) VALUES (?, 1, ?, ?, TRUE, TRUE)
    ");
    
    $stmt->execute([
        $orang_id,
        $input['kelurahan_desa_id'],
        $input['alamat_lengkap']
    ]);
    
    // 4. Create user account with Bos role (role_id = 2)
    $password_hash = password_hash($input['password'], PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("
        INSERT INTO user (
            orang_id, role_id, username, password_hash, is_active, created_by
        ) VALUES (?, 2, ?, ?, TRUE, 1)
    ");
    
    $stmt->execute([$orang_id, $input['username'], $password_hash]);
    
    $user_id = $pdo->lastInsertId();
    
    // 5. Create user ownership (owned by Super Admin)
    $stmt = $pdo->prepare("
        INSERT INTO user_ownership (owner_id, owned_id, relationship_type)
        VALUES (?, ?, 'SuperAdmin-Bos')
    ");
    
    $stmt->execute([1, $user_id]);
    
    // Commit transaction
    $pdo->commit();
    
    // Return success response
    sendJsonResponse(true, [
        'message' => 'Bos berhasil ditambahkan',
        'data' => [
            'user_id' => $user_id,
            'orang_id' => $orang_id,
            'username' => $input['username'],
            'password' => $input['password'],
            'nama_lengkap' => $input['nama_depan']
        ]
    ]);
    
} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 