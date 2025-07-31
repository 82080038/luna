-- Script untuk membersihkan referensi lama yang masih tersisa
-- setelah migrasi ke sistem_alamat

USE sistem_angka;

-- 1. Drop stored procedure yang masih menggunakan tabel geografis lama
DROP PROCEDURE IF EXISTS sp_get_alamat_orang;
DROP PROCEDURE IF EXISTS sp_tambah_alamat_orang;

-- 2. Buat stored procedure baru untuk mendapatkan alamat orang
DELIMITER //

CREATE PROCEDURE sp_get_alamat_orang(IN p_orang_id INT)
BEGIN
    SELECT 
        aj.nama_jenis as jenis,
        oa.alamat_lengkap,
        oa.rt,
        oa.rw,
        oa.kode_pos,
        -- Data dari sistem_alamat (akan di-join nanti)
        oa.negara_id,
        oa.provinsi_id,
        oa.kabupaten_kota_id,
        oa.kecamatan_id,
        oa.desa_id,
        oa.is_primary,
        oa.is_verified
    FROM orang_alamat oa
    JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
    WHERE oa.orang_id = p_orang_id
    ORDER BY oa.is_primary DESC, aj.nama_jenis;
END //

-- 3. Buat stored procedure baru untuk menambah alamat orang
CREATE PROCEDURE sp_tambah_alamat_orang(
    IN p_orang_id INT, 
    IN p_jenis_alamat VARCHAR(50), 
    IN p_alamat_lengkap TEXT, 
    IN p_rt VARCHAR(3), 
    IN p_rw VARCHAR(3), 
    IN p_kode_pos VARCHAR(10), 
    IN p_negara_id INT,
    IN p_provinsi_id INT,
    IN p_kabupaten_kota_id INT,
    IN p_kecamatan_id INT,
    IN p_desa_id INT,
    IN p_is_primary BOOLEAN
)
BEGIN
    DECLARE v_jenis_id INT;
    
    -- Ambil ID jenis alamat
    SELECT id INTO v_jenis_id 
    FROM alamat_jenis 
    WHERE nama_jenis = p_jenis_alamat;
    
    -- Jika primary, set yang lain menjadi non-primary
    IF p_is_primary THEN
        UPDATE orang_alamat 
        SET is_primary = FALSE 
        WHERE orang_id = p_orang_id AND alamat_jenis_id = v_jenis_id;
    END IF;
    
    -- Insert alamat baru
    INSERT INTO orang_alamat (
        orang_id, 
        alamat_jenis_id, 
        alamat_lengkap, 
        rt, 
        rw, 
        kode_pos, 
        negara_id,
        provinsi_id,
        kabupaten_kota_id,
        kecamatan_id,
        desa_id,
        is_primary
    )
    VALUES (
        p_orang_id, 
        v_jenis_id, 
        p_alamat_lengkap, 
        p_rt, 
        p_rw, 
        p_kode_pos, 
        p_negara_id,
        p_provinsi_id,
        p_kabupaten_kota_id,
        p_kecamatan_id,
        p_desa_id,
        p_is_primary
    );
    
END //

DELIMITER ;

-- 4. Update view_orang_alamat_lengkap untuk menggunakan data dari sistem_alamat
-- Note: View ini akan diupdate setelah kita memiliki koneksi cross-database yang proper
DROP VIEW IF EXISTS view_orang_alamat_lengkap;

CREATE VIEW view_orang_alamat_lengkap AS
SELECT 
    oa.id,
    oa.orang_id,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) AS nama_lengkap,
    aj.nama_jenis AS jenis_alamat,
    oa.alamat_lengkap,
    oa.rt,
    oa.rw,
    oa.kode_pos,
    -- Placeholder untuk data dari sistem_alamat
    'Data dari sistem_alamat' AS desa_nama,
    'Data dari sistem_alamat' AS kecamatan_nama,
    'Data dari sistem_alamat' AS kabupaten_nama,
    'Data dari sistem_alamat' AS provinsi_nama,
    'Data dari sistem_alamat' AS negara_nama,
    oa.is_primary,
    oa.is_verified,
    oa.created_at
FROM orang_alamat oa
JOIN orang o ON oa.orang_id = o.id
JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id;

-- 5. Commit perubahan
COMMIT;

-- Pesan konfirmasi
SELECT 'Referensi lama berhasil dibersihkan' AS status;
SELECT 'Stored procedure baru telah dibuat' AS status;
SELECT 'View telah diupdate' AS status; 