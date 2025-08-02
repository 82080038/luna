<?php
require_once 'config.php';
setCommonHeaders();

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
}

try {
    $pdo = getDatabaseConnection();
    
    // Get all BOS users with their details
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.is_active,
            u.created_at,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang,
            oi.nilai_identitas as telepon
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        LEFT JOIN orang_identitas oi ON o.id = oi.orang_id 
            AND oi.jenis_identitas_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon')
            AND oi.is_primary = 1
        WHERE r.nama_role = 'Bos'
        ORDER BY u.created_at DESC
    ");
    
    $stmt->execute();
    $bosList = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format data for response
    $formattedBosList = [];
    foreach ($bosList as $bos) {
        $nama_lengkap = trim($bos['nama_depan'] . ' ' . 
                           ($bos['nama_tengah'] ? $bos['nama_tengah'] . ' ' : '') . 
                           ($bos['nama_belakang'] ? $bos['nama_belakang'] : ''));
        
        $formattedBosList[] = [
            'id' => $bos['id'],
            'username' => $bos['username'],
            'nama_lengkap' => $nama_lengkap,
            'telepon' => $bos['telepon'] ?: '-',
            'is_active' => (bool)$bos['is_active'],
            'created_at' => date('d/m/Y H:i', strtotime($bos['created_at']))
        ];
    }
    
    sendJsonResponse(true, $formattedBosList, 'Daftar BOS berhasil diambil');
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 