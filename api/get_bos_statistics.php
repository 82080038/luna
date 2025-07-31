<?php
require_once 'config.php';
setCommonHeaders();

// Rate limiting
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!checkRateLimit($clientIP, 60, 3600)) {
    sendJsonResponse(false, null, 'Rate limit exceeded', 429);
}

// Establish database connection
try {
    $pdo = getDatabaseConnection();
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database connection failed', 500);
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    // Get BOS statistics
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_bos,
            SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) as bos_aktif,
            SUM(CASE WHEN u.is_active = 0 THEN 1 ELSE 0 END) as bos_tidak_aktif
        FROM user u
        WHERE u.role_id = 2
    ");
    
    $stmt->execute();
    $stats = $stmt->fetch();

    // If no BOS users exist, return default values
    if (!$stats) {
        $stats = [
            'total_bos' => 0,
            'bos_aktif' => 0,
            'bos_tidak_aktif' => 0
        ];
    }

    // Format response data
    $responseData = [
        'total_bos' => (int)$stats['total_bos'],
        'bos_aktif' => (int)$stats['bos_aktif'],
        'bos_tidak_aktif' => (int)$stats['bos_tidak_aktif']
    ];

    sendJsonResponse(true, $responseData, null, 200);

} catch (PDOException $e) {
    error_log("BOS Statistics Error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Database error occurred', 500);
} catch (Exception $e) {
    error_log("BOS Statistics Error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Internal server error', 500);
}
?> 