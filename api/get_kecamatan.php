<?php
require_once 'config.php';
setCommonHeaders();

try {
    $kabupaten_id = $_GET['kabupaten_kota_id'] ?? $_GET['kabupaten_id'] ?? null;
    
    if (!$kabupaten_id) {
        sendJsonResponse(false, null, 'Kabupaten ID is required', 400);
    }
    
    // Use address database for location data
    $pdo = getAddressDatabaseConnection();
    
    $stmt = $pdo->prepare("SELECT id_kecamatan as id, nama_kecamatan as nama FROM cbo_kecamatan WHERE id_kab_kota = ? ORDER BY nama_kecamatan");
    $stmt->execute([$kabupaten_id]);
    $kecamatan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kecamatan);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 