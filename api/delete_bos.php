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
if (!isset($input['bos_id'])) {
    sendJsonResponse(false, null, 'bos_id harus diisi', 400);
}

try {
    $pdo = getDatabaseConnection();
    
    // Start transaction
    $pdo->beginTransaction();
    
    // Verify that the user is a BOS
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.orang_id, r.nama_role
        FROM user u
        JOIN role r ON u.role_id = r.id
        WHERE u.id = ? AND r.nama_role = 'Bos'
    ");
    $stmt->execute([$input['bos_id']]);
    $bos = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bos) {
        sendJsonResponse(false, null, 'BOS tidak ditemukan', 404);
    }
    
    // Check if BOS has any dependent users (Admin Bos, Transporter, Penjual, Pembeli)
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as count
        FROM user_ownership
        WHERE owner_id = ?
    ");
    $stmt->execute([$input['bos_id']]);
    $dependentCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    if ($dependentCount > 0) {
        sendJsonResponse(false, null, "BOS tidak dapat dihapus karena memiliki $dependentCount user yang bergantung padanya", 400);
    }
    
    // Delete user ownership records where this BOS is owned
    $stmt = $pdo->prepare("DELETE FROM user_ownership WHERE owned_id = ?");
    $stmt->execute([$input['bos_id']]);
    
    // Delete user
    $stmt = $pdo->prepare("DELETE FROM user WHERE id = ?");
    $stmt->execute([$input['bos_id']]);
    
    if ($stmt->rowCount() > 0) {
        // Delete related data (orang_identitas, orang_alamat, orang)
        $stmt = $pdo->prepare("DELETE FROM orang_identitas WHERE orang_id = ?");
        $stmt->execute([$bos['orang_id']]);
        
        $stmt = $pdo->prepare("DELETE FROM orang_alamat WHERE id_orang = ?");
        $stmt->execute([$bos['orang_id']]);
        
        $stmt = $pdo->prepare("DELETE FROM orang WHERE id = ?");
        $stmt->execute([$bos['orang_id']]);
        
        // Commit transaction
        $pdo->commit();
        
        sendJsonResponse(true, [
            'bos_id' => $input['bos_id'],
            'message' => 'BOS berhasil dihapus'
        ], 'BOS berhasil dihapus');
    } else {
        // Rollback transaction
        $pdo->rollBack();
        sendJsonResponse(false, null, 'Gagal menghapus BOS', 500);
    }
    
} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 