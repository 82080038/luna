<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getDatabaseConnection();
    
    // Get telepon from query parameter
    $telepon = $_GET['telepon'] ?? null;
    
    if (!$telepon) {
        sendJsonResponse(false, null, 'Nomor telepon is required', 400);
    }
    
    // Validate phone number format
    if (!preg_match('/^[0-9]{10,13}$/', $telepon)) {
        sendJsonResponse(false, null, 'Format nomor telepon tidak valid (10-13 digit)', 400);
    }
    
    // Check if phone number exists in orang_identitas
    $stmt = $pdo->prepare("
        SELECT 
            o.id as orang_id,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang,
            o.jenis_kelamin,
            oi.nilai_identitas as telepon,
            u.username,
            r.nama_role
        FROM orang o
        JOIN orang_identitas oi ON o.id = oi.orang_id
        JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
        LEFT JOIN user u ON o.id = u.orang_id
        LEFT JOIN role r ON u.role_id = r.id
        WHERE mji.nama_jenis = 'Telepon' 
        AND oi.nilai_identitas = ?
        AND oi.is_primary = TRUE
    ");
    $stmt->execute([$telepon]);
    $existingUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existingUser) {
        // Phone number exists
        $nama_lengkap = trim($existingUser['nama_depan'] . ' ' . 
                           ($existingUser['nama_tengah'] ? $existingUser['nama_tengah'] . ' ' : '') . 
                           ($existingUser['nama_belakang'] ? $existingUser['nama_belakang'] : ''));
        
        sendJsonResponse(true, [
            'exists' => true,
            'message' => 'Nomor telah terdaftar atas nama: ' . $nama_lengkap,
            'data' => [
                'orang_id' => $existingUser['orang_id'],
                'nama_depan' => $existingUser['nama_depan'],
                'nama_tengah' => $existingUser['nama_tengah'],
                'nama_belakang' => $existingUser['nama_belakang'],
                'nama_lengkap' => $nama_lengkap,
                'jenis_kelamin' => $existingUser['jenis_kelamin'],
                'telepon' => $existingUser['telepon'],
                'username' => $existingUser['username'],
                'role' => $existingUser['nama_role']
            ]
        ]);
    } else {
        // Phone number doesn't exist
        sendJsonResponse(true, [
            'exists' => false,
            'message' => 'Nomor HP bisa digunakan'
        ]);
    }
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 