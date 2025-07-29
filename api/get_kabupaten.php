<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getDatabaseConnection();
    
    // Get provinsi_id from query parameter
    $provinsi_id = $_GET['provinsi_id'] ?? null;
    
    if (!$provinsi_id) {
        sendJsonResponse(false, null, 'Provinsi ID is required', 400);
    }
    
    // Get kabupaten/kota by provinsi_id
    $stmt = $pdo->prepare("SELECT id, nama FROM kabupaten_kota WHERE provinsi_id = ? ORDER BY nama");
    $stmt->execute([$provinsi_id]);
    $kabupaten = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kabupaten);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 