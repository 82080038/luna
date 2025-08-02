<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Query untuk mendapatkan semua user yang dapat dikelola oleh BOS
    // BOS dapat melihat: Admin Bos, Transporter, Penjual, Pembeli
    $query = "
        SELECT 
            u.id,
            u.username,
            u.is_active,
            u.created_at,
            CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
            r.nama_role as role,
            oi.nilai_identitas as telepon
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        LEFT JOIN orang_identitas oi ON o.id = oi.orang_id 
            AND oi.jenis_identitas_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon') 
            AND oi.is_primary = 1
        WHERE r.nama_role IN ('Admin Bos', 'Transporter', 'Penjual', 'Pembeli')
        ORDER BY u.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format data untuk response
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => $user['id'],
            'username' => $user['username'],
            'nama_lengkap' => trim($user['nama_lengkap']),
            'telepon' => $user['telepon'] ?? '-',
            'role' => $user['role'],
            'is_active' => (bool)$user['is_active'],
            'created_at' => date('d/m/Y H:i', strtotime($user['created_at']))
        ];
    }
    
    sendJsonResponse(true, $formattedUsers);
    
} catch (PDOException $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Server error: ' . $e->getMessage(), 500);
}
?> 