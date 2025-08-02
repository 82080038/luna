<?php
require_once 'config.php';
setCommonHeaders();

try {
    $provinsi_id = $_GET['provinsi_id'] ?? null;
    
    if (!$provinsi_id) {
        sendJsonResponse(false, null, 'Provinsi ID is required', 400);
    }
    
    // Use address database for location data
    $pdo = getAddressDatabaseConnection();
    
    $stmt = $pdo->prepare("SELECT id_kab_kota as id, nama_kab_kota as nama FROM cbo_kab_kota WHERE id_propinsi = ? ORDER BY nama_kab_kota");
    $stmt->execute([$provinsi_id]);
    $kabupaten = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kabupaten);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 