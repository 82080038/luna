<?php
require_once 'config.php';
setCommonHeaders();

try {
    // Use address database for location data
    $pdo = getAddressDatabaseConnection();
    
    // Get all provinces from sistem_alamat database
    $stmt = $pdo->query("SELECT id_propinsi as id, nama_propinsi as nama FROM cbo_propinsi ORDER BY nama_propinsi");
    $provinsi = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $provinsi);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 