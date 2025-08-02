<?php
require_once 'config.php';
setCommonHeaders();

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    $pdo = getDatabaseConnection();
    
    // Get statistics for all users that BOS can manage
    $stmt = $pdo->prepare("
        SELECT 
            r.nama_role,
            COUNT(*) as total,
            SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) as aktif
        FROM user u
        JOIN role r ON u.role_id = r.id
        WHERE r.nama_role IN ('Bos', 'Admin Bos', 'Transporter', 'Penjual', 'Pembeli')
        GROUP BY r.nama_role
    ");
    
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format data for response
    $formattedStats = [
        'admin_bos_aktif' => 0,
        'total_admin_bos' => 0,
        'transporter_aktif' => 0,
        'total_transporter' => 0,
        'penjual_aktif' => 0,
        'total_penjual' => 0,
        'pembeli_aktif' => 0,
        'total_pembeli' => 0
    ];
    
    foreach ($stats as $stat) {
        switch ($stat['nama_role']) {
            case 'Bos':
                $formattedStats['admin_bos_aktif'] = (int)$stat['aktif'];
                $formattedStats['total_admin_bos'] = (int)$stat['total'];
                break;
            case 'Admin Bos':
                $formattedStats['admin_bos_aktif'] = (int)$stat['aktif'];
                $formattedStats['total_admin_bos'] = (int)$stat['total'];
                break;
            case 'Transporter':
                $formattedStats['transporter_aktif'] = (int)$stat['aktif'];
                $formattedStats['total_transporter'] = (int)$stat['total'];
                break;
            case 'Penjual':
                $formattedStats['penjual_aktif'] = (int)$stat['aktif'];
                $formattedStats['total_penjual'] = (int)$stat['total'];
                break;
            case 'Pembeli':
                $formattedStats['pembeli_aktif'] = (int)$stat['aktif'];
                $formattedStats['total_pembeli'] = (int)$stat['total'];
                break;
        }
    }
    
    sendJsonResponse(true, $formattedStats, 'Statistik user berhasil diambil');
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 