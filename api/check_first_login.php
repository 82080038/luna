<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    
    if (!$input || empty($input['user_id'])) {
        sendJsonResponse(false, null, 'User ID is required', 400);
    }
    
    $pdo = new PDO("mysql:host=$host;dbname=sistem_angka", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Cek apakah user sudah pernah login
    $stmt = $pdo->prepare("SELECT last_login FROM user WHERE id = ?");
    $stmt->execute([$input['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendJsonResponse(false, null, 'User not found', 404);
    }
    
    $is_first_login = $user['last_login'] === null;
    
    sendJsonResponse(true, [
        'is_first_login' => $is_first_login,
        'last_login' => $user['last_login']
    ]);
    
} catch (PDOException $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Server error: ' . $e->getMessage(), 500);
}
?> 