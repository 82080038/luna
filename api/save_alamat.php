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

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, null, 'Method not allowed', 405);
    exit();
}

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        sendJsonResponse(false, null, 'Invalid JSON input', 400);
        exit();
    }
    
    // Validate required fields
    $required_fields = ['orang_id', 'alamat_jenis_id', 'alamat_lengkap'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            sendJsonResponse(false, null, "Field '$field' is required", 400);
            exit();
        }
    }
    
    // Get connection to sistem_angka database
    $pdo_angka = getDatabaseConnection();
    
    // Get connection to sistem_alamat database for validation
    $pdo_alamat = getAlamatDatabaseConnection();
    
    // Validate orang_id exists
    $stmt = $pdo_angka->prepare("SELECT id FROM orang WHERE id = ?");
    $stmt->execute([$input['orang_id']]);
    if (!$stmt->fetch()) {
        sendJsonResponse(false, null, 'Person not found', 404);
        exit();
    }
    
    // Validate alamat_jenis_id exists
    $stmt = $pdo_angka->prepare("SELECT id FROM alamat_jenis WHERE id = ?");
    $stmt->execute([$input['alamat_jenis_id']]);
    if (!$stmt->fetch()) {
        sendJsonResponse(false, null, 'Address type not found', 404);
        exit();
    }
    
    // Validate geographic IDs if provided
    $geographic_validation = [];
    
    if (!empty($input['negara_id'])) {
        $stmt = $pdo_alamat->prepare("SELECT id_negara FROM cbo_negara WHERE id_negara = ?");
        $stmt->execute([$input['negara_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Invalid negara_id', 400);
            exit();
        }
        $geographic_validation['negara_id'] = $input['negara_id'];
    }
    
    if (!empty($input['provinsi_id'])) {
        $stmt = $pdo_alamat->prepare("SELECT id_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
        $stmt->execute([$input['provinsi_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Invalid provinsi_id', 400);
            exit();
        }
        $geographic_validation['provinsi_id'] = $input['provinsi_id'];
    }
    
    if (!empty($input['kabupaten_kota_id'])) {
        $stmt = $pdo_alamat->prepare("SELECT id_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ?");
        $stmt->execute([$input['kabupaten_kota_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Invalid kabupaten_kota_id', 400);
            exit();
        }
        $geographic_validation['kabupaten_kota_id'] = $input['kabupaten_kota_id'];
    }
    
    if (!empty($input['kecamatan_id'])) {
        $stmt = $pdo_alamat->prepare("SELECT id_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ?");
        $stmt->execute([$input['kecamatan_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Invalid kecamatan_id', 400);
            exit();
        }
        $geographic_validation['kecamatan_id'] = $input['kecamatan_id'];
    }
    
    if (!empty($input['desa_id'])) {
        $stmt = $pdo_alamat->prepare("SELECT id_desa FROM cbo_desa WHERE id_desa = ?");
        $stmt->execute([$input['desa_id']]);
        if (!$stmt->fetch()) {
            sendJsonResponse(false, null, 'Invalid desa_id', 400);
            exit();
        }
        $geographic_validation['desa_id'] = $input['desa_id'];
    }
    
    // Check if this is primary address
    $is_primary = isset($input['is_primary']) ? (bool)$input['is_primary'] : false;
    
    // If this is primary, unset other primary addresses for this person
    if ($is_primary) {
        $stmt = $pdo_angka->prepare("UPDATE orang_alamat SET is_primary = 0 WHERE orang_id = ?");
        $stmt->execute([$input['orang_id']]);
    }
    
    // Prepare data for insertion
    $alamat_data = [
        'orang_id' => $input['orang_id'],
        'alamat_jenis_id' => $input['alamat_jenis_id'],
        'alamat_lengkap' => $input['alamat_lengkap'],
        'rt' => $input['rt'] ?? null,
        'rw' => $input['rw'] ?? null,
        'kode_pos' => $input['kode_pos'] ?? null,
        'negara_id' => $geographic_validation['negara_id'] ?? null,
        'provinsi_id' => $geographic_validation['provinsi_id'] ?? null,
        'kabupaten_kota_id' => $geographic_validation['kabupaten_kota_id'] ?? null,
        'kecamatan_id' => $geographic_validation['kecamatan_id'] ?? null,
        'desa_id' => $geographic_validation['desa_id'] ?? null,
        'is_primary' => $is_primary ? 1 : 0,
        'is_verified' => isset($input['is_verified']) ? (bool)$input['is_verified'] : false
    ];
    
    // Insert new address
    $stmt = $pdo_angka->prepare("
        INSERT INTO orang_alamat (
            orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos,
            negara_id, provinsi_id, kabupaten_kota_id, kecamatan_id, desa_id,
            is_primary, is_verified, created_at, updated_at
        ) VALUES (
            :orang_id, :alamat_jenis_id, :alamat_lengkap, :rt, :rw, :kode_pos,
            :negara_id, :provinsi_id, :kabupaten_kota_id, :kecamatan_id, :desa_id,
            :is_primary, :is_verified, NOW(), NOW()
        )
    ");
    
    $stmt->execute($alamat_data);
    $alamat_id = $pdo_angka->lastInsertId();
    
    // Get the inserted data
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
        WHERE oa.id = ?
    ");
    
    $stmt->execute([$alamat_id]);
    $inserted_alamat = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Enrich with geographic data
    if ($inserted_alamat) {
        // Get negara data if available
        if ($inserted_alamat['negara_id']) {
            $stmt_negara = $pdo_alamat->prepare("SELECT id_negara, nama_negara FROM cbo_negara WHERE id_negara = ?");
            $stmt_negara->execute([$inserted_alamat['negara_id']]);
            $negara = $stmt_negara->fetch(PDO::FETCH_ASSOC);
            if ($negara) {
                $inserted_alamat['negara_nama'] = $negara['nama_negara'];
            }
        }
        
        // Get provinsi data if available
        if ($inserted_alamat['provinsi_id']) {
            $stmt_provinsi = $pdo_alamat->prepare("SELECT id_propinsi, nama_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
            $stmt_provinsi->execute([$inserted_alamat['provinsi_id']]);
            $provinsi = $stmt_provinsi->fetch(PDO::FETCH_ASSOC);
            if ($provinsi) {
                $inserted_alamat['provinsi_nama'] = $provinsi['nama_propinsi'];
            }
        }
        
        // Get kabupaten/kota data if available
        if ($inserted_alamat['kabupaten_kota_id']) {
            $stmt_kabupaten = $pdo_alamat->prepare("SELECT id_kab_kota, nama_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ?");
            $stmt_kabupaten->execute([$inserted_alamat['kabupaten_kota_id']]);
            $kabupaten = $stmt_kabupaten->fetch(PDO::FETCH_ASSOC);
            if ($kabupaten) {
                $inserted_alamat['kabupaten_nama'] = $kabupaten['nama_kab_kota'];
            }
        }
        
        // Get kecamatan data if available
        if ($inserted_alamat['kecamatan_id']) {
            $stmt_kecamatan = $pdo_alamat->prepare("SELECT id_kecamatan, nama_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ?");
            $stmt_kecamatan->execute([$inserted_alamat['kecamatan_id']]);
            $kecamatan = $stmt_kecamatan->fetch(PDO::FETCH_ASSOC);
            if ($kecamatan) {
                $inserted_alamat['kecamatan_nama'] = $kecamatan['nama_kecamatan'];
            }
        }
        
        // Get desa data if available
        if ($inserted_alamat['desa_id']) {
            $stmt_desa = $pdo_alamat->prepare("SELECT id_desa, nama_desa FROM cbo_desa WHERE id_desa = ?");
            $stmt_desa->execute([$inserted_alamat['desa_id']]);
            $desa = $stmt_desa->fetch(PDO::FETCH_ASSOC);
            if ($desa) {
                $inserted_alamat['desa_nama'] = $desa['nama_desa'];
            }
        }
    }
    
    sendJsonResponse(true, [
        'message' => 'Address saved successfully',
        'alamat_id' => $alamat_id,
        'alamat_data' => $inserted_alamat
    ]);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
}
?> 