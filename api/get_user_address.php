<?php
require_once 'config.php';
setCommonHeaders();

try {
    $user_id = $_GET['user_id'] ?? null;
    
    if (!$user_id) {
        sendJsonResponse(false, null, 'User ID is required', 400);
    }
    
    // Get user address from main database
    $pdo_main = getMainDatabaseConnection();
    $stmt = $pdo_main->prepare("
        SELECT 
            oa.id,
            oa.id_orang,
            oa.id_jenis_alamat,
            oa.id_negara,
            oa.id_propinsi,
            oa.id_kab_kota,
            oa.id_kecamatan,
            oa.id_desa,
            oa.nama_alamat,
            oa.kode_pos,
            oa.lat_long,
            oa.alamat_utama,
            oa.aktif,
            o.nama_depan,
            o.nama_belakang,
            aj.nama_jenis as jenis_alamat
        FROM orang_alamat oa
        JOIN orang o ON oa.id_orang = o.id
        JOIN alamat_jenis aj ON oa.id_jenis_alamat = aj.id
        JOIN user u ON o.id = u.orang_id
        WHERE u.id = ? AND oa.aktif = 'Y'
        ORDER BY oa.alamat_utama DESC, oa.id ASC
    ");
    $stmt->execute([$user_id]);
    $addresses = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($addresses)) {
        sendJsonResponse(false, null, 'No addresses found for this user', 404);
    }
    
    // Get address details from address database
    $pdo_address = getAddressDatabaseConnection();
    $complete_addresses = [];
    
    foreach ($addresses as $address) {
        $address_detail = $address;
        
        // Get provinsi name
        if ($address['id_propinsi']) {
            $stmt = $pdo_address->prepare("SELECT nama_propinsi FROM cbo_propinsi WHERE id_propinsi = ?");
            $stmt->execute([$address['id_propinsi']]);
            $provinsi = $stmt->fetch();
            $address_detail['nama_propinsi'] = $provinsi ? $provinsi['nama_propinsi'] : null;
        }
        
        // Get kabupaten name
        if ($address['id_kab_kota']) {
            $stmt = $pdo_address->prepare("SELECT nama_kab_kota FROM cbo_kab_kota WHERE id_kab_kota = ?");
            $stmt->execute([$address['id_kab_kota']]);
            $kabupaten = $stmt->fetch();
            $address_detail['nama_kabupaten'] = $kabupaten ? $kabupaten['nama_kab_kota'] : null;
        }
        
        // Get kecamatan name
        if ($address['id_kecamatan']) {
            $stmt = $pdo_address->prepare("SELECT nama_kecamatan FROM cbo_kecamatan WHERE id_kecamatan = ?");
            $stmt->execute([$address['id_kecamatan']]);
            $kecamatan = $stmt->fetch();
            $address_detail['nama_kecamatan'] = $kecamatan ? $kecamatan['nama_kecamatan'] : null;
        }
        
        // Get desa name
        if ($address['id_desa']) {
            $stmt = $pdo_address->prepare("SELECT nama_desa FROM cbo_desa WHERE id_desa = ?");
            $stmt->execute([$address['id_desa']]);
            $desa = $stmt->fetch();
            $address_detail['nama_desa'] = $desa ? $desa['nama_desa'] : null;
        }
        
        // Build full address
        $full_address_parts = [];
        if ($address['nama_alamat']) $full_address_parts[] = $address['nama_alamat'];
        if ($address_detail['nama_desa']) $full_address_parts[] = $address_detail['nama_desa'];
        if ($address_detail['nama_kecamatan']) $full_address_parts[] = $address_detail['nama_kecamatan'];
        if ($address_detail['nama_kabupaten']) $full_address_parts[] = $address_detail['nama_kabupaten'];
        if ($address_detail['nama_propinsi']) $full_address_parts[] = $address_detail['nama_propinsi'];
        
        $address_detail['alamat_lengkap'] = implode(', ', $full_address_parts);
        
        $complete_addresses[] = $address_detail;
    }
    
    sendJsonResponse(true, [
        'user_id' => $user_id,
        'nama_lengkap' => $addresses[0]['nama_depan'] . ' ' . ($addresses[0]['nama_belakang'] ?? ''),
        'addresses' => $complete_addresses,
        'total_addresses' => count($complete_addresses)
    ]);
    
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Error: ' . $e->getMessage(), 500);
}
?> 