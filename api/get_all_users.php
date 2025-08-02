<?php
require_once 'config.php';
setCommonHeaders();

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    $pdo = getDatabaseConnection();
    
    // Get all users with their details
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.is_active,
            u.created_at,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang,
            r.nama_role as role,
            oi.nilai_identitas as telepon
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        LEFT JOIN orang_identitas oi ON o.id = oi.orang_id 
            AND oi.jenis_identitas_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon')
            AND oi.is_primary = 1
        ORDER BY u.created_at DESC
    ");
    
    $stmt->execute();
    $usersList = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format data for response
    $formattedUsersList = [];
    foreach ($usersList as $user) {
        $nama_lengkap = trim($user['nama_depan'] . ' ' . 
                           ($user['nama_tengah'] ? $user['nama_tengah'] . ' ' : '') . 
                           ($user['nama_belakang'] ? $user['nama_belakang'] : ''));
        
        $formattedUsersList[] = [
            'id' => $user['id'],
            'username' => $user['username'],
            'nama_lengkap' => $nama_lengkap,
            'telepon' => $user['telepon'] ?: '-',
            'role' => $user['role'],
            'is_active' => (bool)$user['is_active'],
            'created_at' => date('d/m/Y H:i', strtotime($user['created_at']))
        ];
    }
    
    sendJsonResponse(true, $formattedUsersList, 'Daftar user berhasil diambil');
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 