<?php
require_once 'config.php';
setCommonHeaders();

// Rate limiting
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!checkRateLimit($clientIP, 10, 3600)) { // 10 requests per hour
    sendJsonResponse(false, null, 'Rate limit exceeded. Please try again later.', 429);
}

// Establish database connection
try {
    $pdo = getDatabaseConnection();
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database connection failed', 500);
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

// Define validation rules
$validationRules = [
    'nama_depan' => [
        'required' => true,
        'type' => 'string',
        'min_length' => 2,
        'max_length' => 50,
        'pattern' => '/^[a-zA-Z\s]+$/'
    ],
    'nama_belakang' => [
        'required' => false,
        'type' => 'string',
        'max_length' => 50,
        'pattern' => '/^[a-zA-Z\s]*$/'
    ],
    'jenis_kelamin' => [
        'required' => true,
        'pattern' => '/^(Laki-laki|Perempuan)$/'
    ],
    'tempat_lahir' => [
        'required' => false,
        'max_length' => 100
    ],
    'tanggal_lahir' => [
        'required' => false,
        'pattern' => '/^\d{4}-\d{2}-\d{2}$/'
    ],
    'nik' => [
        'required' => false,
        'pattern' => '/^\d{16}$/'
    ],
    'telepon' => [
        'required' => true,
        'type' => 'phone'
    ],
    'email' => [
        'required' => false,
        'type' => 'email'
    ],
    'alamat_lengkap' => [
        'required' => true,
        'min_length' => 10,
        'max_length' => 500
    ],
    'rt' => [
        'required' => false,
        'pattern' => '/^\d{1,3}$/'
    ],
    'rw' => [
        'required' => false,
        'pattern' => '/^\d{1,3}$/'
    ],
    'kode_pos' => [
        'required' => false,
        'pattern' => '/^\d{5}$/'
    ],
    'provinsi_id' => [
        'required' => true,
        'type' => 'numeric'
    ],
    'kabupaten_kota_id' => [
        'required' => true,
        'type' => 'numeric'
    ],
    'kecamatan_id' => [
        'required' => true,
        'type' => 'numeric'
    ],
    'kelurahan_desa_id' => [
        'required' => true,
        'type' => 'numeric'
    ],
    'username' => [
        'required' => false,
        'min_length' => 3,
        'max_length' => 50,
        'pattern' => '/^[a-zA-Z0-9_]+$/'
    ],
    'password' => [
        'required' => false,
        'min_length' => 6,
        'max_length' => 255
    ]
];

// Validate input
$validation = validateAndSanitizeInput($input, $validationRules);

if (!$validation['valid']) {
    sendJsonResponse(false, null, implode(', ', $validation['errors']), 400);
}

$data = $validation['data'];

// Auto-generate username if not provided
if (empty($data['username'])) {
    $data['username'] = $data['telepon'];
}

// Auto-generate password if not provided
if (empty($data['password'])) {
    $data['password'] = $data['telepon'];
}

// Additional validations
try {
    // Check if username already exists
    $stmt = $pdo->prepare("SELECT id FROM user WHERE username = ?");
    $stmt->execute([$data['username']]);
    if ($stmt->fetch()) {
        sendJsonResponse(false, null, 'Username sudah digunakan', 409);
    }

    // Check if NIK already exists (if provided)
    if (!empty($data['nik'])) {
        $stmt = $pdo->prepare("SELECT o.id FROM orang o 
                              JOIN orang_identitas oi ON o.id = oi.orang_id 
                              JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
                              WHERE mji.nama_jenis = 'NIK' AND oi.nilai_identitas = ?");
        $stmt->execute([$data['nik']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'NIK sudah terdaftar', 409);
        }
    }

    // Check if phone number already exists
    $stmt = $pdo->prepare("SELECT o.id FROM orang o 
                          JOIN orang_identitas oi ON o.id = oi.orang_id 
                          JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
                          WHERE mji.nama_jenis = 'Telepon' AND oi.nilai_identitas = ?");
    $stmt->execute([$data['telepon']]);
    if ($stmt->fetch()) {
        sendJsonResponse(false, null, 'Nomor telepon sudah terdaftar', 409);
    }

    // Check if email already exists (if provided)
    if (!empty($data['email'])) {
        $stmt = $pdo->prepare("SELECT o.id FROM orang o 
                              JOIN orang_identitas oi ON o.id = oi.orang_id 
                              JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id 
                              WHERE mji.nama_jenis = 'Email' AND oi.nilai_identitas = ?");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'Email sudah terdaftar', 409);
        }
    }

    // Start transaction
    $pdo->beginTransaction();

    // Insert into orang table
    $stmt = $pdo->prepare("
        INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin, tempat_lahir, tanggal_lahir, created_at) 
        VALUES (?, ?, ?, ?, ?, NOW())
    ");
    $stmt->execute([
        $data['nama_depan'],
        $data['nama_belakang'],
        $data['jenis_kelamin'],
        $data['tempat_lahir'],
        $data['tanggal_lahir']
    ]);
    
    $orangId = $pdo->lastInsertId();

    // Insert identitas data
    $identitasData = [
        'Telepon' => $data['telepon'],
        'Email' => $data['email'],
        'NIK' => $data['nik']
    ];

    foreach ($identitasData as $jenisIdentitas => $nilai) {
        if (!empty($nilai)) {
            // Get jenis identitas ID
            $stmt = $pdo->prepare("SELECT id FROM master_jenis_identitas WHERE nama_jenis = ?");
            $stmt->execute([$jenisIdentitas]);
            $jenisId = $stmt->fetchColumn();

            if ($jenisId) {
                $isPrimary = ($jenisIdentitas === 'Telepon' || $jenisIdentitas === 'Email') ? 1 : 0;
                $stmt = $pdo->prepare("
                    INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, created_at) 
                    VALUES (?, ?, ?, ?, NOW())
                ");
                $stmt->execute([$orangId, $jenisId, $nilai, $isPrimary]);
            }
        }
    }

    // Insert address
    $stmt = $pdo->prepare("
        INSERT INTO orang_alamat (
            orang_id, jenis_alamat_id, alamat_lengkap, rt, rw, kode_pos, 
            provinsi_id, kabupaten_kota_id, kecamatan_id, kelurahan_desa_id, 
            is_primary, created_at
        ) VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())
    ");
    $stmt->execute([
        $orangId,
        $data['alamat_lengkap'],
        $data['rt'],
        $data['rw'],
        $data['kode_pos'],
        $data['provinsi_id'],
        $data['kabupaten_kota_id'],
        $data['kecamatan_id'],
        $data['kelurahan_desa_id']
    ]);

    // Create user account
    $hashedPassword = password_hash($data['password'], PASSWORD_ARGON2ID);
    $stmt = $pdo->prepare("
        INSERT INTO user (username, password, role_id, is_active, created_at) 
        VALUES (?, ?, 2, 1, NOW())
    ");
    $stmt->execute([$data['username'], $hashedPassword]);
    
    $userId = $pdo->lastInsertId();

    // Link user with orang
    $stmt = $pdo->prepare("
        INSERT INTO user_ownership (user_id, orang_id, created_at) 
        VALUES (?, ?, NOW())
    ");
    $stmt->execute([$userId, $orangId]);

    // Commit transaction
    $pdo->commit();

    sendJsonResponse(true, [
        'user_id' => $userId,
        'orang_id' => $orangId,
        'username' => $data['username'],
        'message' => 'User Bos berhasil ditambahkan'
    ], null, 201);

} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo->inTransaction()) {
        $pdo->rollback();
    }
    
    // Log error for debugging (in production, log to file)
    error_log("Add Bos Error: " . $e->getMessage());
    
    sendJsonResponse(false, null, 'Internal server error', 500);
}
?> 