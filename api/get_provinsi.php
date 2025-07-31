<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getAlamatDatabaseConnection();
    
                    // Get all provinces from sistem_alamat database
                $stmt = $pdo->query("SELECT id_propinsi as id, nama_propinsi as nama FROM cbo_propinsi ORDER BY nama_propinsi");
    $provinsi = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $provinsi);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 