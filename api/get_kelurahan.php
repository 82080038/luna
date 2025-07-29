<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getDatabaseConnection();
    
    // Get kecamatan_id from query parameter
    $kecamatan_id = $_GET['kecamatan_id'] ?? null;
    
    if (!$kecamatan_id) {
        sendJsonResponse(false, null, 'Kecamatan ID is required', 400);
    }
    
    // Get kelurahan/desa by kecamatan_id
    $stmt = $pdo->prepare("SELECT id, nama FROM kelurahan_desa WHERE kecamatan_id = ? ORDER BY nama");
    $stmt->execute([$kecamatan_id]);
    $kelurahan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kelurahan);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 