-- Script untuk membersihkan tabel geografis dari sistem_angka
-- dan memodifikasi tabel orang_alamat untuk menggunakan referensi ke sistem_alamat

USE sistem_angka;

-- 1. Hapus view yang bergantung pada tabel geografis
DROP VIEW IF EXISTS view_orang_alamat;

-- 2. Hapus tabel geografis dari sistem_angka
DROP TABLE IF EXISTS kelurahan_desa;
DROP TABLE IF EXISTS kecamatan;
DROP TABLE IF EXISTS kabupaten_kota;
DROP TABLE IF EXISTS provinsi;
DROP TABLE IF EXISTS negara;

-- 3. Modifikasi tabel orang_alamat untuk menggunakan referensi ke sistem_alamat
-- Tambahkan kolom untuk menyimpan ID dari sistem_alamat (dengan pengecekan)

-- Cek dan tambah kolom negara_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'negara_id') = 0,
    'ALTER TABLE orang_alamat ADD COLUMN negara_id INT NULL COMMENT ''ID dari tabel cbo_negara di sistem_alamat''',
    'SELECT ''negara_id column already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cek dan tambah kolom provinsi_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'provinsi_id') = 0,
    'ALTER TABLE orang_alamat ADD COLUMN provinsi_id INT NULL COMMENT ''ID dari tabel cbo_propinsi di sistem_alamat''',
    'SELECT ''provinsi_id column already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cek dan tambah kolom kabupaten_kota_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'kabupaten_kota_id') = 0,
    'ALTER TABLE orang_alamat ADD COLUMN kabupaten_kota_id INT NULL COMMENT ''ID dari tabel cbo_kab_kota di sistem_alamat''',
    'SELECT ''kabupaten_kota_id column already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cek dan tambah kolom kecamatan_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'kecamatan_id') = 0,
    'ALTER TABLE orang_alamat ADD COLUMN kecamatan_id INT NULL COMMENT ''ID dari tabel cbo_kecamatan di sistem_alamat''',
    'SELECT ''kecamatan_id column already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cek dan tambah kolom desa_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'desa_id') = 0,
    'ALTER TABLE orang_alamat ADD COLUMN desa_id INT NULL COMMENT ''ID dari tabel cbo_desa di sistem_alamat''',
    'SELECT ''desa_id column already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Hapus foreign key constraint lama yang terkait dengan kelurahan_desa_id
-- Cek dan hapus constraint orang_alamat_ibfk_3
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND CONSTRAINT_NAME = 'orang_alamat_ibfk_3') > 0,
    'ALTER TABLE orang_alamat DROP FOREIGN KEY orang_alamat_ibfk_3',
    'SELECT ''orang_alamat_ibfk_3 constraint does not exist'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cek dan hapus constraint fk_orang_alamat_kelurahan_desa jika ada
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND CONSTRAINT_NAME = 'fk_orang_alamat_kelurahan_desa') > 0,
    'ALTER TABLE orang_alamat DROP FOREIGN KEY fk_orang_alamat_kelurahan_desa',
    'SELECT ''fk_orang_alamat_kelurahan_desa constraint does not exist'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Hapus kolom kelurahan_desa_id yang lama (dengan pengecekan)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND COLUMN_NAME = 'kelurahan_desa_id') > 0,
    'ALTER TABLE orang_alamat DROP COLUMN kelurahan_desa_id',
    'SELECT ''kelurahan_desa_id column does not exist'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Tambahkan index untuk performa query (dengan pengecekan)
-- Index untuk negara_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND INDEX_NAME = 'idx_orang_alamat_negara') = 0,
    'ALTER TABLE orang_alamat ADD INDEX idx_orang_alamat_negara (negara_id)',
    'SELECT ''idx_orang_alamat_negara index already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Index untuk provinsi_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND INDEX_NAME = 'idx_orang_alamat_provinsi') = 0,
    'ALTER TABLE orang_alamat ADD INDEX idx_orang_alamat_provinsi (provinsi_id)',
    'SELECT ''idx_orang_alamat_provinsi index already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Index untuk kabupaten_kota_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND INDEX_NAME = 'idx_orang_alamat_kabupaten') = 0,
    'ALTER TABLE orang_alamat ADD INDEX idx_orang_alamat_kabupaten (kabupaten_kota_id)',
    'SELECT ''idx_orang_alamat_kabupaten index already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Index untuk kecamatan_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND INDEX_NAME = 'idx_orang_alamat_kecamatan') = 0,
    'ALTER TABLE orang_alamat ADD INDEX idx_orang_alamat_kecamatan (kecamatan_id)',
    'SELECT ''idx_orang_alamat_kecamatan index already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Index untuk desa_id
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = 'sistem_angka' 
     AND TABLE_NAME = 'orang_alamat' 
     AND INDEX_NAME = 'idx_orang_alamat_desa') = 0,
    'ALTER TABLE orang_alamat ADD INDEX idx_orang_alamat_desa (desa_id)',
    'SELECT ''idx_orang_alamat_desa index already exists'' AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Buat view baru untuk orang_alamat yang menggunakan sistem_alamat
CREATE OR REPLACE VIEW view_orang_alamat AS
SELECT 
    oa.id,
    oa.orang_id,
    o.nama_depan,
    o.nama_belakang,
    aj.nama_jenis AS jenis_alamat,
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
    oa.is_verified,
    oa.created_at
FROM orang_alamat oa
JOIN orang o ON oa.orang_id = o.id
JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id;

-- 5. Buat view untuk alamat lengkap dengan data dari sistem_alamat
-- Note: View ini akan diupdate setelah kita memiliki koneksi cross-database
CREATE OR REPLACE VIEW view_orang_alamat_lengkap AS
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

-- 6. Update data existing (set semua ID geografis ke NULL untuk sementara)
UPDATE orang_alamat SET 
    negara_id = NULL,
    provinsi_id = NULL,
    kabupaten_kota_id = NULL,
    kecamatan_id = NULL,
    desa_id = NULL;

-- 7. Buat stored procedure untuk mendapatkan alamat lengkap
DELIMITER //

DROP PROCEDURE IF EXISTS sp_get_alamat_lengkap //

CREATE PROCEDURE sp_get_alamat_lengkap(IN orang_id_param INT)
BEGIN
    SELECT 
        oa.id,
        oa.orang_id,
        CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) AS nama_lengkap,
        aj.nama_jenis AS jenis_alamat,
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
        oa.created_at
    FROM orang_alamat oa
    JOIN orang o ON oa.orang_id = o.id
    JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
    WHERE oa.orang_id = orang_id_param
    ORDER BY oa.is_primary DESC, oa.created_at ASC;
END //

DELIMITER ;

-- 8. Buat fungsi untuk validasi ID geografis
DELIMITER //

DROP FUNCTION IF EXISTS fn_validate_geographic_id //

CREATE FUNCTION fn_validate_geographic_id(
    table_name VARCHAR(50),
    id_value INT
) RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE result BOOLEAN DEFAULT FALSE;
    
    -- Validasi akan dilakukan di aplikasi dengan cross-database query
    -- Untuk sementara return TRUE
    SET result = TRUE;
    
    RETURN result;
END //

DELIMITER ;

-- 9. Buat trigger untuk validasi data
DELIMITER //

DROP TRIGGER IF EXISTS tr_orang_alamat_before_insert //

CREATE TRIGGER tr_orang_alamat_before_insert 
BEFORE INSERT ON orang_alamat
FOR EACH ROW
BEGIN
    -- Validasi data geografis (akan diimplementasikan nanti)
    -- Untuk sementara tidak ada validasi
    SET NEW.created_at = CURRENT_TIMESTAMP;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DROP TRIGGER IF EXISTS tr_orang_alamat_before_update //

CREATE TRIGGER tr_orang_alamat_before_update 
BEFORE UPDATE ON orang_alamat
FOR EACH ROW
BEGIN
    -- Validasi data geografis (akan diimplementasikan nanti)
    -- Untuk sementara tidak ada validasi
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- 10. Commit perubahan
COMMIT;

-- Pesan konfirmasi
SELECT 'Tabel geografis berhasil dihapus dari sistem_angka' AS status;
SELECT 'Tabel orang_alamat berhasil dimodifikasi untuk menggunakan referensi ke sistem_alamat' AS status;
SELECT 'View dan stored procedure baru telah dibuat' AS status; 