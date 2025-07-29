-- Script untuk memperbaiki struktur database
-- Menghapus NIK dari tabel orang dan memindahkannya ke master_jenis_identitas

USE sistem_angka;

-- 1. Tambahkan NIK ke master_jenis_identitas jika belum ada
INSERT IGNORE INTO master_jenis_identitas (nama_jenis, deskripsi) VALUES
('NIK', 'Nomor Induk Kependudukan');

-- 2. Pindahkan data NIK dari tabel orang ke orang_identitas
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified)
SELECT 
    o.id,
    (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'NIK'),
    o.nik,
    TRUE,
    TRUE
FROM orang o
WHERE o.nik IS NOT NULL AND o.nik != '';

-- 3. Hapus kolom NIK dari tabel orang
ALTER TABLE orang DROP COLUMN nik;

-- 4. Update view_orang_lengkap untuk menghilangkan referensi ke NIK
DROP VIEW IF EXISTS view_orang_lengkap;
CREATE VIEW view_orang_lengkap AS
SELECT 
    o.id,
    o.nama_depan,
    o.nama_tengah,
    o.nama_belakang,
    o.nama_panggilan,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
    o.jenis_kelamin,
    o.tempat_lahir,
    o.tanggal_lahir,
    o.golongan_darah,
    ma.nama_agama,
    msp.nama_status as status_perkawinan,
    o.created_at,
    o.updated_at
FROM orang o
LEFT JOIN master_agama ma ON o.agama_id = ma.id
LEFT JOIN master_status_perkawinan msp ON o.status_perkawinan_id = msp.id;

-- 5. Update view_user_lengkap untuk menghilangkan referensi ke NIK
DROP VIEW IF EXISTS view_user_lengkap;
CREATE VIEW view_user_lengkap AS
SELECT 
    u.id,
    u.username,
    u.is_active,
    u.last_login,
    o.nama_depan,
    o.nama_tengah,
    o.nama_belakang,
    o.nama_panggilan,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
    o.jenis_kelamin,
    o.tempat_lahir,
    o.tanggal_lahir,
    o.golongan_darah,
    ma.nama_agama,
    msp.nama_status as status_perkawinan,
    r.nama_role,
    u.created_at
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN role r ON u.role_id = r.id
LEFT JOIN master_agama ma ON o.agama_id = ma.id
LEFT JOIN master_status_perkawinan msp ON o.status_perkawinan_id = msp.id;

-- 6. Buat view untuk mendapatkan NIK dari orang_identitas
CREATE VIEW view_orang_nik AS
SELECT 
    o.id as orang_id,
    o.nama_depan,
    o.nama_belakang,
    oi.nilai_identitas as nik
FROM orang o
JOIN orang_identitas oi ON o.id = oi.orang_id
JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
WHERE mji.nama_jenis = 'NIK' AND oi.is_primary = TRUE;

-- 7. Update view_penyerahan_dana untuk menghilangkan referensi ke NIK
DROP VIEW IF EXISTS view_penyerahan_dana;
CREATE VIEW view_penyerahan_dana AS
SELECT 
    u.username,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) AS nama_lengkap,
    r.nama_role,
    dm.saldo AS saldo_deposit,
    COUNT(tt.id) AS total_transaksi,
    SUM(tt.total_bayar) AS total_omset,
    SUM(CASE WHEN dk.id IS NOT NULL THEN dk.total_hadiah ELSE 0 END) AS total_hadiah
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN role r ON u.role_id = r.id
LEFT JOIN deposit_member dm ON u.id = dm.user_id
LEFT JOIN transaksi_tebakan tt ON u.id = tt.user_id
LEFT JOIN detail_kemenangan dk ON tt.id = dk.transaksi_id
WHERE r.nama_role IN ('Penjual', 'Pembeli')
GROUP BY u.id, u.username, o.nama_depan, o.nama_tengah, o.nama_belakang, r.nama_role, dm.saldo;

-- Verifikasi perubahan
SELECT 'Database structure updated successfully!' as status; 