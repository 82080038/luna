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
    $required_fields = ['user_id', 'current_password', 'new_password', 'confirm_password'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            sendJsonResponse(false, null, "Field '$field' is required", 400);
        }
    }
    
    // Validasi password baru
    if (strlen($input['new_password']) < 6) {
        sendJsonResponse(false, null, 'Password baru minimal 6 karakter', 400);
    }
    
    if ($input['new_password'] !== $input['confirm_password']) {
        sendJsonResponse(false, null, 'Konfirmasi password tidak cocok', 400);
    }
    
    $pdo = new PDO("mysql:host=$host;dbname=sistem_angka", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Mulai transaksi
    $pdo->beginTransaction();
    
    try {
        // 1. Ambil data user
        $stmt = $pdo->prepare("SELECT username, password_hash FROM user WHERE id = ?");
        $stmt->execute([$input['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            sendJsonResponse(false, null, 'User not found', 404);
        }
        
        // 2. Verifikasi password lama
        if (!password_verify($input['current_password'], $user['password_hash'])) {
            sendJsonResponse(false, null, 'Password lama tidak benar', 400);
        }
        
        // 3. Hash password baru
        $new_password_hash = password_hash($input['new_password'], PASSWORD_DEFAULT);
        
        // 4. Update password dan last_login
        $stmt = $pdo->prepare("UPDATE user SET password_hash = ?, last_login = NOW() WHERE id = ?");
        $stmt->execute([$new_password_hash, $input['user_id']]);
        
        // Commit transaksi
        $pdo->commit();
        
        // Response sukses
        sendJsonResponse(true, [
            'message' => 'Password berhasil diubah',
            'username' => $user['username']
        ], 'Password berhasil diubah');
        
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