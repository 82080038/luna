<?php
require_once 'config.php';
setCommonHeaders();

try {
    $provinsi_id = $_GET['provinsi_id'] ?? null;
    $kabupaten_id = $_GET['kabupaten_id'] ?? null;
    $kecamatan_id = $_GET['kecamatan_id'] ?? null;
    $kelurahan_id = $_GET['kelurahan_id'] ?? null;
    
    $pdo = getAddressDatabaseConnection();
    $validation_result = [];
    
    // Validate provinsi
    if ($provinsi_id) {
        $stmt = $pdo->prepare("SELECT id_propinsi, nama_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
        $stmt->execute([$provinsi_id]);
        $validation_result['provinsi'] = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Validate kabupaten
    if ($kabupaten_id && $provinsi_id) {
        $stmt = $pdo->prepare("SELECT id_kab_kota, nama_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ? AND id_propinsi = ?");
        $stmt->execute([$kabupaten_id, $provinsi_id]);
        $validation_result['kabupaten'] = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Validate kecamatan
    if ($kecamatan_id && $kabupaten_id) {
        $stmt = $pdo->prepare("SELECT id_kecamatan, nama_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ? AND id_kab_kota = ?");
        $stmt->execute([$kecamatan_id, $kabupaten_id]);
        $validation_result['kecamatan'] = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Validate kelurahan
    if ($kelurahan_id && $kecamatan_id) {
        $stmt = $pdo->prepare("SELECT id_desa, nama_desa FROM cbo_desa WHERE id_desa = ? AND id_kecamatan = ?");
        $stmt->execute([$kelurahan_id, $kecamatan_id]);
        $validation_result['kelurahan'] = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    sendJsonResponse(true, $validation_result);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, $e->getMessage(), 500);
}
?> 