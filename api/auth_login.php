<?php
require_once 'config.php';
setCommonHeaders();

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
if (empty($input['username']) || empty($input['password'])) {
    sendJsonResponse(false, null, 'Username dan password harus diisi', 400);
}

try {
    $pdo = getDatabaseConnection();
    
    // Get user data with role information
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.password,
            u.is_active,
            r.nama_role,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang,
            o.jenis_kelamin
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        WHERE u.username = ?
    ");
    
    $stmt->execute([$input['username']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendJsonResponse(false, null, 'Username atau password salah', 401);
    }
    
    // Check if user is active
    if (!$user['is_active']) {
        sendJsonResponse(false, null, 'Akun tidak aktif', 401);
    }
    
    // Verify password
    if (!password_verify($input['password'], $user['password'])) {
        sendJsonResponse(false, null, 'Username atau password salah', 401);
    }
    
    // Get user's contact information
    $stmt = $pdo->prepare("
        SELECT 
            mji.nama_jenis,
            oi.nilai_identitas,
            oi.is_primary
        FROM orang_identitas oi
        JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
        WHERE oi.orang_id = ?
        ORDER BY oi.is_primary DESC
    ");
    
    $stmt->execute([$user['id']]);
    $contacts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Build contact info
    $email = '';
    $telepon = '';
    foreach ($contacts as $contact) {
        if ($contact['nama_jenis'] === 'Email' && $contact['is_primary']) {
            $email = $contact['nilai_identitas'];
        }
        if ($contact['nama_jenis'] === 'Telepon' && $contact['is_primary']) {
            $telepon = $contact['nilai_identitas'];
        }
    }
    
    // Build full name
    $nama_lengkap = trim($user['nama_depan'] . ' ' . 
                        ($user['nama_tengah'] ? $user['nama_tengah'] . ' ' : '') . 
                        ($user['nama_belakang'] ? $user['nama_belakang'] : ''));
    
    // Prepare user data for response
    $userData = [
        'id' => $user['id'],
        'username' => $user['username'],
        'role' => $user['nama_role'],
        'nama_lengkap' => $nama_lengkap,
        'nama_depan' => $user['nama_depan'],
        'nama_tengah' => $user['nama_tengah'],
        'nama_belakang' => $user['nama_belakang'],
        'jenis_kelamin' => $user['jenis_kelamin'],
        'email' => $email,
        'telepon' => $telepon,
        'is_active' => (bool)$user['is_active']
    ];
    
    // Generate simple token (in production, use JWT)
    $token = bin2hex(random_bytes(32));
    
    // Store token in session or database (for demo, we'll just return it)
    // In production, implement proper session management
    
    sendJsonResponse(true, [
        'user' => $userData,
        'token' => $token,
        'message' => 'Login berhasil'
    ]);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Login failed: ' . $e->getMessage(), 500);
}
?> 