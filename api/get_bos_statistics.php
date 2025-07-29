<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get BOS role ID (role_id = 2 for 'Bos')
    $bosRoleId = 2;

    // Query to get BOS statistics
    $query = "
        SELECT 
            COUNT(*) as total_bos,
            SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) as bos_aktif,
            SUM(CASE WHEN u.is_active = 0 THEN 1 ELSE 0 END) as bos_tidak_aktif
        FROM user u
        WHERE u.role_id = :bos_role_id
    ";

    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':bos_role_id', $bosRoleId, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    // Format response
    $response = [
        'success' => true,
        'data' => [
            'total_bos' => (int)$result['total_bos'],
            'bos_aktif' => (int)$result['bos_aktif'],
            'bos_tidak_aktif' => (int)$result['bos_tidak_aktif']
        ],
        'message' => 'BOS statistics retrieved successfully'
    ];

    echo json_encode($response);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}
?> 