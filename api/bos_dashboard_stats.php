<?php
require_once 'config.php';
setCommonHeaders();

// Rate limiting
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!checkRateLimit($clientIP, 30, 3600)) {
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

// Check authentication
$authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
if (!$authHeader || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
    sendJsonResponse(false, null, 'Authorization header required', 401);
}

$sessionToken = $matches[1];

try {
    // Verify session and get user info
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, r.nama_role 
        FROM user u 
        JOIN role r ON u.role_id = r.id 
        LEFT JOIN user_sessions us ON u.id = us.user_id 
        WHERE us.session_token = ? AND us.expires_at > NOW() AND u.is_active = 1
    ");
    $stmt->execute([hash('sha256', $sessionToken)]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJsonResponse(false, null, 'Invalid or expired session', 401);
    }

    if ($user['nama_role'] !== 'Bos') {
        sendJsonResponse(false, null, 'Access denied. Bos role required', 403);
    }

    // Get dashboard statistics for this Bos
    $bosId = $user['id'];
    
    // Get total servers owned by this Bos
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as total_servers
        FROM server s
        WHERE s.created_by = ? OR s.owner_id = ?
    ");
    $stmt->execute([$bosId, $bosId]);
    $totalServers = $stmt->fetchColumn() ?: 0;

    // Get active sessions for Bos's servers
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as active_sessions
        FROM sesi_server ss
        JOIN server s ON ss.server_id = s.id
        WHERE (s.created_by = ? OR s.owner_id = ?)
        AND ss.status = 'active'
        AND ss.tanggal_sesi = CURDATE()
    ");
    $stmt->execute([$bosId, $bosId]);
    $activeSessions = $stmt->fetchColumn() ?: 0;

    // Get total users under this Bos (Admin Bos, Transporter, etc.)
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as total_users
        FROM user u
        JOIN user_ownership uo ON u.id = uo.owned_id
        WHERE uo.owner_id = ?
        AND u.is_active = 1
    ");
    $stmt->execute([$bosId]);
    $totalUsers = $stmt->fetchColumn() ?: 0;

    // Get total revenue from transactions in Bos's servers (last 30 days)
    $stmt = $pdo->prepare("
        SELECT COALESCE(SUM(tt.harga_total), 0) as total_revenue
        FROM transaksi_tebakan tt
        JOIN sesi_server ss ON tt.sesi_server_id = ss.id
        JOIN server s ON ss.server_id = s.id
        WHERE (s.created_by = ? OR s.owner_id = ?)
        AND tt.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        AND tt.status = 'confirmed'
    ");
    $stmt->execute([$bosId, $bosId]);
    $totalRevenue = $stmt->fetchColumn() ?: 0;

    // Additional metrics
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(DISTINCT DATE(tt.created_at)) as active_days,
            COUNT(*) as total_transactions,
            AVG(tt.harga_total) as avg_transaction_amount
        FROM transaksi_tebakan tt
        JOIN sesi_server ss ON tt.sesi_server_id = ss.id
        JOIN server s ON ss.server_id = s.id
        WHERE (s.created_by = ? OR s.owner_id = ?)
        AND tt.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        AND tt.status = 'confirmed'
    ");
    $stmt->execute([$bosId, $bosId]);
    $additionalStats = $stmt->fetch();

    // Get pending transactions count
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as pending_transactions
        FROM transaksi_tebakan tt
        JOIN sesi_server ss ON tt.sesi_server_id = ss.id
        JOIN server s ON ss.server_id = s.id
        WHERE (s.created_by = ? OR s.owner_id = ?)
        AND tt.status = 'pending'
    ");
    $stmt->execute([$bosId, $bosId]);
    $pendingTransactions = $stmt->fetchColumn() ?: 0;

    // Prepare response data
    $responseData = [
        'total_servers' => (int)$totalServers,
        'active_sessions' => (int)$activeSessions,
        'total_users' => (int)$totalUsers,
        'total_revenue' => (float)$totalRevenue,
        'additional_stats' => [
            'active_days' => (int)($additionalStats['active_days'] ?: 0),
            'total_transactions' => (int)($additionalStats['total_transactions'] ?: 0),
            'avg_transaction_amount' => (float)($additionalStats['avg_transaction_amount'] ?: 0),
            'pending_transactions' => (int)$pendingTransactions
        ]
    ];

    // Log the dashboard access
    $stmt = $pdo->prepare("
        INSERT INTO audit_logs (user_id, action, table_name, new_values, ip_address, created_at) 
        VALUES (?, 'DASHBOARD_ACCESS', 'bos_dashboard', ?, ?, NOW())
    ");
    $stmt->execute([
        $bosId, 
        json_encode(['action' => 'dashboard_stats_viewed']), 
        $clientIP
    ]);

    sendJsonResponse(true, $responseData, null, 200);

} catch (PDOException $e) {
    error_log("Bos Dashboard Stats Error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Database error occurred', 500);
} catch (Exception $e) {
    error_log("Bos Dashboard Stats Error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Internal server error', 500);
}
?>