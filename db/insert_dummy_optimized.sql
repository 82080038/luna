-- Data Dummy untuk Database Optimized Luna System
-- File ini berisi data dummy untuk database yang sudah dinormalisasi

USE sistem_angka;

-- =====================================================
-- 1. INSERT DATA ORANG
-- =====================================================

-- Insert data orang untuk Super Admin
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('1234567890123456', 'Ahmad', 'Rizki', 'Pratama', 'Rizki', 'L', 'Jakarta', '1990-05-15', 'O', 1, 2);

-- Insert data orang untuk Bos
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('2345678901234567', 'Budi', 'Santoso', 'Wijaya', 'Budi', 'L', 'Surabaya', '1985-08-20', 'A', 1, 2);

-- Insert data orang untuk Admin Bos
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('3456789012345678', 'Citra', 'Dewi', 'Sari', 'Citra', 'P', 'Bandung', '1988-12-10', 'B', 1, 2);

-- Insert data orang untuk Transporter
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('4567890123456789', 'Dedi', 'Kurniawan', 'Setiawan', 'Dedi', 'L', 'Semarang', '1992-03-25', 'AB', 1, 1);

-- Insert data orang untuk Penjual
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('5678901234567890', 'Eka', 'Putri', 'Ningsih', 'Eka', 'P', 'Yogyakarta', '1995-07-08', 'O', 1, 1);

-- Insert data orang untuk Pembeli
INSERT INTO orang (nik, nama_depan, nama_tengah, nama_belakang, nama_panggilan, jenis_kelamin, tempat_lahir, tanggal_lahir, golongan_darah, agama_id, status_perkawinan_id) VALUES
('6789012345678901', 'Fajar', 'Ramadhan', 'Hidayat', 'Fajar', 'L', 'Malang', '1993-11-30', 'A', 1, 1);

-- =====================================================
-- 2. INSERT DATA ORANG IDENTITAS
-- =====================================================

-- Identitas untuk Super Admin (Ahmad Rizki Pratama)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(1, 1, 'admin@luna.com', TRUE, TRUE),
(1, 2, '08123456789', FALSE, FALSE),
(1, 3, '08123456789', FALSE, FALSE);

-- Identitas untuk Bos (Budi Santoso Wijaya)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(2, 1, 'bos@luna.com', TRUE, TRUE),
(2, 2, '08234567890', FALSE, FALSE),
(2, 3, '08234567890', FALSE, FALSE),
(2, 4, '@bosluna', FALSE, FALSE);

-- Identitas untuk Admin Bos (Citra Dewi Sari)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(3, 1, 'adminbos@luna.com', TRUE, TRUE),
(3, 2, '08345678901', FALSE, FALSE),
(3, 3, '08345678901', FALSE, FALSE),
(3, 5, '@citra_admin', FALSE, FALSE);

-- Identitas untuk Transporter (Dedi Kurniawan Setiawan)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(4, 1, 'transporter@luna.com', TRUE, TRUE),
(4, 2, '08456789012', FALSE, FALSE),
(4, 3, '08456789012', FALSE, FALSE);

-- Identitas untuk Penjual (Eka Putri Ningsih)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(5, 1, 'penjual@luna.com', TRUE, TRUE),
(5, 2, '08567890123', FALSE, FALSE),
(5, 3, '08567890123', FALSE, FALSE),
(5, 5, '@eka_penjual', FALSE, FALSE);

-- Identitas untuk Pembeli (Fajar Ramadhan Hidayat)
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
(6, 1, 'pembeli@luna.com', TRUE, TRUE),
(6, 2, '08678901234', FALSE, FALSE),
(6, 3, '08678901234', FALSE, FALSE);

-- =====================================================
-- 3. INSERT DATA ORANG ALAMAT
-- =====================================================

-- Alamat untuk Super Admin (Ahmad Rizki Pratama)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(1, 1, 'Jl. Sudirman No. 123, Menteng', '001', '002', '10310', NULL, TRUE, TRUE),
(1, 3, 'Jl. Thamrin No. 456, Jakarta Pusat', '003', '004', '10350', NULL, FALSE, FALSE);

-- Alamat untuk Bos (Budi Santoso Wijaya)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(2, 1, 'Jl. Darmo No. 789, Surabaya', '005', '006', '60241', NULL, TRUE, TRUE),
(2, 2, 'Jl. Basuki Rahmat No. 321, Surabaya', '007', '008', '60271', NULL, FALSE, FALSE),
(2, 3, 'Jl. Pemuda No. 654, Surabaya', '009', '010', '60272', NULL, FALSE, FALSE);

-- Alamat untuk Admin Bos (Citra Dewi Sari)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(3, 1, 'Jl. Asia Afrika No. 111, Bandung', '011', '012', '40262', NULL, TRUE, TRUE),
(3, 3, 'Jl. Merdeka No. 222, Bandung', '013', '014', '40111', NULL, FALSE, FALSE);

-- Alamat untuk Transporter (Dedi Kurniawan Setiawan)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(4, 1, 'Jl. Pandanaran No. 333, Semarang', '015', '016', '50241', NULL, TRUE, TRUE),
(4, 2, 'Jl. Gajah Mada No. 444, Semarang', '017', '018', '50134', NULL, FALSE, FALSE);

-- Alamat untuk Penjual (Eka Putri Ningsih)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(5, 1, 'Jl. Malioboro No. 555, Yogyakarta', '019', '020', '55213', NULL, TRUE, TRUE),
(5, 3, 'Jl. Solo No. 666, Yogyakarta', '021', '022', '55222', NULL, FALSE, FALSE);

-- Alamat untuk Pembeli (Fajar Ramadhan Hidayat)
INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary, is_verified) VALUES
(6, 1, 'Jl. Ijen No. 777, Malang', '023', '024', '65111', NULL, TRUE, TRUE),
(6, 6, 'Jl. Soekarno Hatta No. 888, Malang', '025', '026', '65144', NULL, FALSE, FALSE);

-- =====================================================
-- 4. INSERT DATA USER
-- =====================================================

-- User untuk Super Admin
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(1, 1, 'admin', SHA2('admin123', 256), TRUE, NULL);

-- User untuk Bos
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(2, 2, 'bos', SHA2('bos123', 256), TRUE, 1);

-- User untuk Admin Bos
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(3, 3, 'adminbos', SHA2('adminbos123', 256), TRUE, 1);

-- User untuk Transporter
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(4, 4, 'transporter', SHA2('transporter123', 256), TRUE, 1);

-- User untuk Penjual
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(5, 5, 'penjual', SHA2('penjual123', 256), TRUE, 1);

-- User untuk Pembeli
INSERT INTO user (orang_id, role_id, username, password_hash, is_active, created_by) VALUES
(6, 6, 'pembeli', SHA2('pembeli123', 256), TRUE, 1);

-- =====================================================
-- 5. INSERT DATA USER OWNERSHIP
-- =====================================================

-- Super Admin memiliki Bos
INSERT INTO user_ownership (owner_id, owned_id, relationship_type) VALUES
(1, 2, 'SuperAdmin-Bos');

-- Bos memiliki Admin Bos
INSERT INTO user_ownership (owner_id, owned_id, relationship_type) VALUES
(2, 3, 'Bos-AdminBos');

-- Bos memiliki Transporter
INSERT INTO user_ownership (owner_id, owned_id, relationship_type) VALUES
(2, 4, 'Bos-Transporter');

-- Transporter memiliki Penjual
INSERT INTO user_ownership (owner_id, owned_id, relationship_type) VALUES
(4, 5, 'Transporter-Penjual');

-- Penjual memiliki Pembeli
INSERT INTO user_ownership (owner_id, owned_id, relationship_type) VALUES
(5, 6, 'Penjual-Pembeli');

-- =====================================================
-- 6. INSERT DATA SERVER
-- =====================================================

-- Server Jakarta Pusat
INSERT INTO server (nama_server, kode_server, lokasi, owner_id, is_active) VALUES
('Server Jakarta Pusat', 'JKT-PST', 'Jakarta Pusat, DKI Jakarta', 2, TRUE);

-- =====================================================
-- 7. INSERT DATA HADIAH
-- =====================================================

-- Hadiah untuk 4D
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(1, 'Hadiah 4D', 'Hadiah untuk tebakan 4 digit', 9000000.00, TRUE);

-- Hadiah untuk 3D
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(2, 'Hadiah 3D', 'Hadiah untuk tebakan 3 digit', 900000.00, TRUE);

-- Hadiah untuk 2D
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(3, 'Hadiah 2D', 'Hadiah untuk tebakan 2 digit', 90000.00, TRUE);

-- Hadiah untuk CE
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(4, 'Hadiah CE', 'Hadiah untuk colok bebas', 9000.00, TRUE);

-- Hadiah untuk CK
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(5, 'Hadiah CK', 'Hadiah untuk colok kembang', 9000.00, TRUE);

-- Hadiah untuk CB
INSERT INTO hadiah (tipe_tebakan_id, nama_hadiah, deskripsi, jumlah_hadiah, is_active) VALUES
(6, 'Hadiah CB', 'Hadiah untuk colok buntut', 9000.00, TRUE);

-- =====================================================
-- 8. INSERT DATA DEPOSIT MEMBER
-- =====================================================

-- Deposit untuk Penjual
INSERT INTO deposit_member (user_id, bos_id, saldo) VALUES
(5, 2, 5000000.00);

-- Deposit untuk Pembeli
INSERT INTO deposit_member (user_id, bos_id, saldo) VALUES
(6, 2, 1000000.00);

-- =====================================================
-- 9. INSERT DATA KOMISI ATURAN
-- =====================================================

-- Aturan komisi untuk Bos
INSERT INTO komisi_aturan (role_id, persentase_komisi, minimum_transaksi, is_active) VALUES
(2, 5.00, 100000.00, TRUE);

-- Aturan komisi untuk Admin Bos
INSERT INTO komisi_aturan (role_id, persentase_komisi, minimum_transaksi, is_active) VALUES
(3, 3.00, 50000.00, TRUE);

-- Aturan komisi untuk Transporter
INSERT INTO komisi_aturan (role_id, persentase_komisi, minimum_transaksi, is_active) VALUES
(4, 2.00, 25000.00, TRUE);

-- Aturan komisi untuk Penjual
INSERT INTO komisi_aturan (role_id, persentase_komisi, minimum_transaksi, is_active) VALUES
(5, 1.50, 10000.00, TRUE);

-- =====================================================
-- 10. TEST QUERIES
-- =====================================================

-- Test query untuk melihat data lengkap user
SELECT 
    u.username,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
    r.nama_role,
    ma.nama_agama,
    msp.nama_status as status_perkawinan
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN role r ON u.role_id = r.id
LEFT JOIN master_agama ma ON o.agama_id = ma.id
LEFT JOIN master_status_perkawinan msp ON o.status_perkawinan_id = msp.id
ORDER BY r.id;

-- Test query untuk melihat identitas user
SELECT 
    u.username,
    CONCAT(o.nama_depan, ' ', o.nama_belakang) as nama,
    mji.nama_jenis as jenis_identitas,
    oi.nilai_identitas,
    oi.is_primary,
    oi.is_verified
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN orang_identitas oi ON o.id = oi.orang_id
JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
ORDER BY u.username, oi.is_primary DESC, mji.nama_jenis;

-- Test query untuk melihat alamat user
SELECT 
    u.username,
    CONCAT(o.nama_depan, ' ', o.nama_belakang) as nama,
    aj.nama_jenis as jenis_alamat,
    oa.alamat_lengkap,
    oa.rt,
    oa.rw,
    oa.kode_pos,
    oa.is_primary,
    oa.is_verified
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN orang_alamat oa ON o.id = oa.orang_id
JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
ORDER BY u.username, oa.is_primary DESC, aj.nama_jenis;

-- Test query untuk melihat struktur ownership
SELECT 
    owner.username as owner_username,
    CONCAT(owner_o.nama_depan, ' ', owner_o.nama_belakang) as owner_nama,
    owned.username as owned_username,
    CONCAT(owned_o.nama_depan, ' ', owned_o.nama_belakang) as owned_nama,
    uo.relationship_type
FROM user_ownership uo
JOIN user owner ON uo.owner_id = owner.id
JOIN user owned ON uo.owned_id = owned.id
JOIN orang owner_o ON owner.orang_id = owner_o.id
JOIN orang owned_o ON owned.orang_id = owned_o.id
ORDER BY uo.relationship_type;

-- =====================================================
-- 11. PERFORMANCE COMPARISON
-- =====================================================

/*
PERBANDINGAN PENYIMPANAN DATA:

SEBELUM NORMALISASI (database_complete.sql):
- Setiap record orang menyimpan string agama dan status_perkawinan
- Jika ada 1000 user dengan 4 status perkawinan yang sama:
  - 1000 x 20 bytes = 20,000 bytes untuk status perkawinan
  - Dengan normalisasi: 4 x 20 bytes = 80 bytes (hemat 99.6%)

SETELAH NORMALISASI (database_optimized.sql):
- Agama dan status perkawinan disimpan di master table
- Satu orang bisa punya multiple email/telepon
- Satu orang bisa punya multiple alamat (rumah, kerja, kantor, dll)
- Data lebih konsisten dan mudah maintenance
- Performa query lebih baik dengan index yang tepat

KEUNTUNGAN NORMALISASI:
1. Hemat penyimpanan: 99%+ penghematan untuk data yang berulang
2. Konsistensi data: Tidak ada typo atau variasi
3. Maintenance mudah: Ubah sekali, berlaku di semua tempat
4. Fleksibilitas: Mudah tambah jenis identitas dan alamat baru
5. Data integrity: Foreign key constraints
6. Performance: Index yang tepat untuk query yang sering digunakan
7. Multiple addresses: Satu orang bisa punya berbagai jenis alamat
8. Address tracking: Primary dan verified status untuk alamat
*/