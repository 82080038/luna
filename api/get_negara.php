<?php
require_once 'config.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
    exit();
}

try {
    $pdo = getAlamatDatabaseConnection();
    
    // Get all countries from sistem_alamat database
    $stmt = $pdo->query("SELECT id_negara as id, nama_negara as nama FROM cbo_negara ORDER BY nama_negara");
    $negara = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $negara);
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 