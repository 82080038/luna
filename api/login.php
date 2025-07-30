<?php
require_once 'config.php';
setCommonHeaders();

// Rate limiting for login attempts
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!checkRateLimit($clientIP, 5, 900)) { // 5 attempts per 15 minutes
    sendJsonResponse(false, null, 'Too many login attempts. Please try again later.', 429);
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
    'username' => [
        'required' => true,
        'min_length' => 3,
        'max_length' => 50,
        'pattern' => '/^[a-zA-Z0-9_@.]+$/'
    ],
    'password' => [
        'required' => true,
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

try {
    // Get user data with role information
    $stmt = $pdo->prepare("
        SELECT 
            u.id, 
            u.username, 
            u.password, 
            u.is_active,
            u.last_login,
            u.failed_login_attempts,
            u.locked_until,
            r.nama_role as role_name,
            o.nama_depan,
            o.nama_belakang
        FROM user u
        JOIN role r ON u.role_id = r.id
        LEFT JOIN user_ownership uo ON u.id = uo.user_id
        LEFT JOIN orang o ON uo.orang_id = o.id
        WHERE u.username = ?
    ");
    
    $stmt->execute([$data['username']]);
    $user = $stmt->fetch();

    if (!$user) {
        // Simulate password verification to prevent timing attacks
        password_verify('dummy_password', '$2y$10$dummy.hash.to.prevent.timing.attacks');
        sendJsonResponse(false, null, 'Invalid username or password', 401);
    }

    // Check if account is locked
    if ($user['locked_until'] && new DateTime($user['locked_until']) > new DateTime()) {
        sendJsonResponse(false, null, 'Account is temporarily locked due to multiple failed login attempts', 423);
    }

    // Check if account is active
    if (!$user['is_active']) {
        sendJsonResponse(false, null, 'Account is deactivated', 403);
    }

    // Verify password
    if (!password_verify($data['password'], $user['password'])) {
        // Increment failed login attempts
        $failedAttempts = $user['failed_login_attempts'] + 1;
        $lockUntil = null;
        
        // Lock account after 5 failed attempts for 30 minutes
        if ($failedAttempts >= 5) {
            $lockUntil = date('Y-m-d H:i:s', strtotime('+30 minutes'));
        }
        
        $stmt = $pdo->prepare("
            UPDATE user 
            SET failed_login_attempts = ?, locked_until = ? 
            WHERE id = ?
        ");
        $stmt->execute([$failedAttempts, $lockUntil, $user['id']]);
        
        sendJsonResponse(false, null, 'Invalid username or password', 401);
    }

    // Check if password needs rehashing (for security upgrades)
    if (password_needs_rehash($user['password'], PASSWORD_ARGON2ID)) {
        $newHash = password_hash($data['password'], PASSWORD_ARGON2ID);
        $stmt = $pdo->prepare("UPDATE user SET password = ? WHERE id = ?");
        $stmt->execute([$newHash, $user['id']]);
    }

    // Reset failed login attempts and update last login
    $stmt = $pdo->prepare("
        UPDATE user 
        SET failed_login_attempts = 0, locked_until = NULL, last_login = NOW() 
        WHERE id = ?
    ");
    $stmt->execute([$user['id']]);

    // Generate session token
    $sessionToken = bin2hex(random_bytes(32));
    $sessionExpires = date('Y-m-d H:i:s', strtotime('+4 hours'));

    // Store session in database (create sessions table if needed)
    try {
        $stmt = $pdo->prepare("
            INSERT INTO user_sessions (user_id, session_token, expires_at, created_at) 
            VALUES (?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE 
            session_token = VALUES(session_token), 
            expires_at = VALUES(expires_at), 
            updated_at = NOW()
        ");
        $stmt->execute([$user['id'], hash('sha256', $sessionToken), $sessionExpires]);
    } catch (PDOException $e) {
        // If sessions table doesn't exist, we'll skip session storage for now
        error_log("Session table error: " . $e->getMessage());
    }

    // Prepare response data
    $userData = [
        'id' => $user['id'],
        'username' => $user['username'],
        'role' => $user['role_name'],
        'name' => trim($user['nama_depan'] . ' ' . $user['nama_belakang']),
        'last_login' => $user['last_login'],
        'session_token' => $sessionToken
    ];

    // Log successful login
    error_log("Successful login: User {$user['username']} ({$user['id']}) from IP {$clientIP}");

    sendJsonResponse(true, $userData, null, 200);

} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Internal server error', 500);
}
?>