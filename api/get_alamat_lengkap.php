<?php
require_once 'config.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
    exit();
}

try {
    // Get parameters
    $orang_id = $_GET['orang_id'] ?? null;
    
    if (!$orang_id) {
        sendJsonResponse(false, null, 'Orang ID is required', 400);
        exit();
    }
    
    // Validate orang_id
    if (!is_numeric($orang_id)) {
        sendJsonResponse(false, null, 'Invalid Orang ID', 400);
        exit();
    }
    
    // Get connection to sistem_angka database
    $pdo_angka = getDatabaseConnection();
    
    // Get connection to sistem_alamat database
    $pdo_alamat = getAlamatDatabaseConnection();
    
    // Get alamat data from sistem_angka
    $stmt = $pdo_angka->prepare("
        SELECT 
            oa.id,
            oa.orang_id,
            oa.alamat_jenis_id,
            oa.alamat_lengkap,
            oa.rt,
            oa.rw,
            oa.kode_pos,
            oa.negara_id,
            oa.provinsi_id,
            oa.kabupaten_kota_id,
            oa.kecamatan_id,
            oa.desa_id,
            oa.is_primary,
            oa.is_verified,
            oa.created_at,
            aj.nama_jenis AS jenis_alamat,
            CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) AS nama_lengkap
        FROM orang_alamat oa
        JOIN orang o ON oa.orang_id = o.id
        JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
        WHERE oa.orang_id = ?
        ORDER BY oa.is_primary DESC, oa.created_at ASC
    ");
    
    $stmt->execute([$orang_id]);
    $alamat_list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($alamat_list)) {
        sendJsonResponse(false, null, 'No address found for this person', 404);
        exit();
    }
    
    // Enrich with geographic data from sistem_alamat
    $enriched_alamat = [];
    
    foreach ($alamat_list as $alamat) {
        $enriched_address = $alamat;
        
        // Get negara data if available
        if ($alamat['negara_id']) {
            $stmt_negara = $pdo_alamat->prepare("SELECT id_negara, nama_negara FROM cbo_negara WHERE id_negara = ?");
            $stmt_negara->execute([$alamat['negara_id']]);
            $negara = $stmt_negara->fetch(PDO::FETCH_ASSOC);
            if ($negara) {
                $enriched_address['negara_nama'] = $negara['nama_negara'];
            }
        }
        
        // Get provinsi data if available
        if ($alamat['provinsi_id']) {
            $stmt_provinsi = $pdo_alamat->prepare("SELECT id_propinsi, nama_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
            $stmt_provinsi->execute([$alamat['provinsi_id']]);
            $provinsi = $stmt_provinsi->fetch(PDO::FETCH_ASSOC);
            if ($provinsi) {
                $enriched_address['provinsi_nama'] = $provinsi['nama_propinsi'];
            }
        }
        
        // Get kabupaten/kota data if available
        if ($alamat['kabupaten_kota_id']) {
            $stmt_kabupaten = $pdo_alamat->prepare("SELECT id_kab_kota, nama_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ?");
            $stmt_kabupaten->execute([$alamat['kabupaten_kota_id']]);
            $kabupaten = $stmt_kabupaten->fetch(PDO::FETCH_ASSOC);
            if ($kabupaten) {
                $enriched_address['kabupaten_nama'] = $kabupaten['nama_kab_kota'];
            }
        }
        
        // Get kecamatan data if available
        if ($alamat['kecamatan_id']) {
            $stmt_kecamatan = $pdo_alamat->prepare("SELECT id_kecamatan, nama_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ?");
            $stmt_kecamatan->execute([$alamat['kecamatan_id']]);
            $kecamatan = $stmt_kecamatan->fetch(PDO::FETCH_ASSOC);
            if ($kecamatan) {
                $enriched_address['kecamatan_nama'] = $kecamatan['nama_kecamatan'];
            }
        }
        
        // Get desa data if available
        if ($alamat['desa_id']) {
            $stmt_desa = $pdo_alamat->prepare("SELECT id_desa, nama_desa FROM cbo_desa WHERE id_desa = ?");
            $stmt_desa->execute([$alamat['desa_id']]);
            $desa = $stmt_desa->fetch(PDO::FETCH_ASSOC);
            if ($desa) {
                $enriched_address['desa_nama'] = $desa['nama_desa'];
            }
        }
        
        $enriched_alamat[] = $enriched_address;
    }
    
    // Return enriched data
    sendJsonResponse(true, [
        'orang_id' => $orang_id,
        'nama_lengkap' => $alamat_list[0]['nama_lengkap'],
        'total_alamat' => count($enriched_alamat),
        'alamat_list' => $enriched_alamat
    ]);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
}
?> 