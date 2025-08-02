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
if (!isset($input['user_id']) || !isset($input['is_active'])) {
    sendJsonResponse(false, null, 'user_id dan is_active harus diisi', 400);
}

try {
    $pdo = getDatabaseConnection();
    
    // Verify that the user exists and is not Super Admin
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, r.nama_role
        FROM user u
        JOIN role r ON u.role_id = r.id
        WHERE u.id = ?
    ");
    $stmt->execute([$input['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendJsonResponse(false, null, 'User tidak ditemukan', 404);
    }
    
    // Prevent modifying Super Admin
    if ($user['nama_role'] === 'Super Admin') {
        sendJsonResponse(false, null, 'Tidak dapat mengubah status Super Admin', 403);
    }
    
    // Update user status
    $stmt = $pdo->prepare("UPDATE user SET is_active = ? WHERE id = ?");
    $stmt->execute([$input['is_active'] ? 1 : 0, $input['user_id']]);
    
    if ($stmt->rowCount() > 0) {
        $statusText = $input['is_active'] ? 'diaktifkan' : 'dinonaktifkan';
        sendJsonResponse(true, [
            'user_id' => $input['user_id'],
            'is_active' => (bool)$input['is_active'],
            'message' => "User berhasil $statusText"
        ], "User berhasil $statusText");
    } else {
        sendJsonResponse(false, null, 'Tidak ada perubahan status', 400);
    }
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 