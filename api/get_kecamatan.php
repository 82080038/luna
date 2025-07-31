<?php
require_once 'config.php';
setCommonHeaders();

try {
    $pdo = getAlamatDatabaseConnection();
    
    // Get kabupaten_id from query parameter
    $kabupaten_id = $_GET['kabupaten_id'] ?? null;
    
    if (!$kabupaten_id) {
        sendJsonResponse(false, null, 'Kabupaten ID is required', 400);
    }
    
                    // Get kecamatan by kabupaten_id from sistem_alamat database
                $stmt = $pdo->prepare("SELECT id_kecamatan as id, nama_kecamatan as nama FROM cbo_kecamatan WHERE id_kab_kota = ? ORDER BY nama_kecamatan");
    $stmt->execute([$kabupaten_id]);
    $kecamatan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendJsonResponse(true, $kecamatan);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 