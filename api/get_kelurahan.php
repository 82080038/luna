<?php
require_once 'config.php';
setCommonHeaders();

try {
    $kecamatan_id = $_GET['kecamatan_id'] ?? null;
    
    if (!$kecamatan_id) {
        sendJsonResponse(false, null, 'Kecamatan ID is required', 400);
    }
    
    // Use address database for location data
    $pdo = getAddressDatabaseConnection();
    
    $stmt = $pdo->prepare("SELECT id_desa as id, nama_desa as nama FROM cbo_desa WHERE id_kecamatan = ? ORDER BY nama_desa");
    $stmt->execute([$kecamatan_id]);
    $kelurahan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kelurahan);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 