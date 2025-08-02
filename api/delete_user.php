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
if (!isset($input['user_id'])) {
    sendJsonResponse(false, null, 'user_id harus diisi', 400);
}

try {
    $pdo = getDatabaseConnection();
    
    // Start transaction
    $pdo->beginTransaction();
    
    // Verify that the user exists and is not Super Admin
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.orang_id, r.nama_role
        FROM user u
        JOIN role r ON u.role_id = r.id
        WHERE u.id = ?
    ");
    $stmt->execute([$input['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendJsonResponse(false, null, 'User tidak ditemukan', 404);
    }
    
    // Prevent deleting Super Admin
    if ($user['nama_role'] === 'Super Admin') {
        sendJsonResponse(false, null, 'Tidak dapat menghapus Super Admin', 403);
    }
    
    // Check if user has any dependent users (for BOS, Admin Bos, Transporter, Penjual)
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as count
        FROM user_ownership
        WHERE owner_id = ?
    ");
    $stmt->execute([$input['user_id']]);
    $dependentCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    if ($dependentCount > 0) {
        sendJsonResponse(false, null, "User tidak dapat dihapus karena memiliki $dependentCount user yang bergantung padanya", 400);
    }
    
    // Delete user ownership records where this user is owned
    $stmt = $pdo->prepare("DELETE FROM user_ownership WHERE owned_id = ?");
    $stmt->execute([$input['user_id']]);
    
    // Delete user
    $stmt = $pdo->prepare("DELETE FROM user WHERE id = ?");
    $stmt->execute([$input['user_id']]);
    
    if ($stmt->rowCount() > 0) {
        // Delete related data (orang_identitas, orang_alamat, orang)
        $stmt = $pdo->prepare("DELETE FROM orang_identitas WHERE orang_id = ?");
        $stmt->execute([$user['orang_id']]);
        
        $stmt = $pdo->prepare("DELETE FROM orang_alamat WHERE id_orang = ?");
        $stmt->execute([$user['orang_id']]);
        
        $stmt = $pdo->prepare("DELETE FROM orang WHERE id = ?");
        $stmt->execute([$user['orang_id']]);
        
        // Commit transaction
        $pdo->commit();
        
        sendJsonResponse(true, [
            'user_id' => $input['user_id'],
            'message' => 'User berhasil dihapus'
        ], 'User berhasil dihapus');
    } else {
        // Rollback transaction
        $pdo->rollBack();
        sendJsonResponse(false, null, 'Gagal menghapus user', 500);
    }
    
} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 