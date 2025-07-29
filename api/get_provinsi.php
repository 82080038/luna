<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getDatabaseConnection();
    
    // Get all provinces
    $stmt = $pdo->query("SELECT id, nama FROM provinsi ORDER BY nama");
    $provinsi = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $provinsi);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 