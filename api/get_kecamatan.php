<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getDatabaseConnection();
    
    // Get kabupaten_kota_id from query parameter
    $kabupaten_kota_id = $_GET['kabupaten_kota_id'] ?? null;
    
    if (!$kabupaten_kota_id) {
        sendJsonResponse(false, null, 'Kabupaten/Kota ID is required', 400);
    }
    
    // Get kecamatan by kabupaten_kota_id
    $stmt = $pdo->prepare("SELECT id, nama FROM kecamatan WHERE kabupaten_kota_id = ? ORDER BY nama");
    $stmt->execute([$kabupaten_kota_id]);
    $kecamatan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kecamatan);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 