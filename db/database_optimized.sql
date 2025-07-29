-- Database Sistem Tebakan Angka - Versi Optimized dengan Normalisasi
-- File ini berisi database yang dioptimalkan dengan normalisasi yang lebih baik

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================
CREATE DATABASE IF NOT EXISTS sistem_angka;
USE sistem_angka;

-- =====================================================
-- 2. CREATE TABLES - MASTER DATA
-- =====================================================

-- Tabel Master Agama
CREATE TABLE master_agama (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_agama VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Master Status Perkawinan
CREATE TABLE master_status_perkawinan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_status VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Master Jenis Identitas
CREATE TABLE master_jenis_identitas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_jenis VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Role
CREATE TABLE role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT,
    parent_role_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_role_id) REFERENCES role(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 3. CREATE TABLES - CORE DATA
-- =====================================================

-- Tabel Orang (Core Data)
CREATE TABLE orang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nik VARCHAR(16) UNIQUE,
    nama_depan VARCHAR(50) NOT NULL,
    nama_tengah VARCHAR(50),
    nama_belakang VARCHAR(50),
    nama_panggilan VARCHAR(30),
    jenis_kelamin ENUM('L','P') NOT NULL,
    tempat_lahir VARCHAR(50),
    tanggal_lahir DATE,
    golongan_darah ENUM('A','B','AB','O'),
    agama_id INT,
    status_perkawinan_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (agama_id) REFERENCES master_agama(id) ON DELETE SET NULL,
    FOREIGN KEY (status_perkawinan_id) REFERENCES master_status_perkawinan(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Orang Identitas (Multiple Contact Info)
CREATE TABLE orang_identitas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_id INT NOT NULL,
    jenis_identitas_id INT NOT NULL,
    nilai_identitas VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orang_id) REFERENCES orang(id) ON DELETE CASCADE,
    FOREIGN KEY (jenis_identitas_id) REFERENCES master_jenis_identitas(id) ON DELETE RESTRICT,
    UNIQUE KEY (orang_id, jenis_identitas_id, nilai_identitas)
) ENGINE=InnoDB;

-- Tabel User
CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_id INT NOT NULL,
    role_id INT NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orang_id) REFERENCES orang(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE SET NULL,
    UNIQUE KEY (orang_id, role_id)
) ENGINE=InnoDB;

-- Tabel User Ownership
CREATE TABLE user_ownership (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    owned_id INT NOT NULL,
    relationship_type ENUM('SuperAdmin-Bos','Bos-AdminBos','Bos-Transporter','Transporter-Penjual','Penjual-Pembeli') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (owned_id) REFERENCES user(id) ON DELETE CASCADE,
    UNIQUE KEY (owner_id, owned_id, relationship_type)
) ENGINE=InnoDB;

-- =====================================================
-- 4. CREATE TABLES - LOCATION DATA
-- =====================================================

-- Tabel Negara
CREATE TABLE negara (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_iso VARCHAR(3) UNIQUE,
    nama VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Provinsi
CREATE TABLE provinsi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    negara_id INT NOT NULL,
    kode VARCHAR(10) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (negara_id) REFERENCES negara(id) ON DELETE RESTRICT,
    UNIQUE KEY (negara_id, nama)
) ENGINE=InnoDB;

-- Tabel Kabupaten/Kota
CREATE TABLE kabupaten_kota (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provinsi_id INT NOT NULL,
    kode VARCHAR(10) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    jenis ENUM('Kabupaten','Kota') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provinsi_id) REFERENCES provinsi(id) ON DELETE RESTRICT,
    UNIQUE KEY (provinsi_id, nama)
) ENGINE=InnoDB;

-- Tabel Kecamatan
CREATE TABLE kecamatan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kabupaten_kota_id INT NOT NULL,
    kode VARCHAR(10) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kabupaten_kota_id) REFERENCES kabupaten_kota(id) ON DELETE RESTRICT,
    UNIQUE KEY (kabupaten_kota_id, nama)
) ENGINE=InnoDB;

-- Tabel Kelurahan/Desa
CREATE TABLE kelurahan_desa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kecamatan_id INT NOT NULL,
    kode VARCHAR(10) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    jenis ENUM('Kelurahan','Desa') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id) ON DELETE RESTRICT,
    UNIQUE KEY (kecamatan_id, nama)
) ENGINE=InnoDB;

-- Tabel Master Jenis Alamat
CREATE TABLE alamat_jenis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_jenis VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Orang Alamat
CREATE TABLE orang_alamat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_id INT NOT NULL,
    alamat_jenis_id INT NOT NULL,
    kelurahan_desa_id INT,
    alamat_lengkap TEXT NOT NULL,
    rt VARCHAR(3),
    rw VARCHAR(3),
    kode_pos VARCHAR(10),
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orang_id) REFERENCES orang(id) ON DELETE CASCADE,
    FOREIGN KEY (alamat_jenis_id) REFERENCES alamat_jenis(id) ON DELETE RESTRICT,
    FOREIGN KEY (kelurahan_desa_id) REFERENCES kelurahan_desa(id) ON DELETE SET NULL,
    UNIQUE KEY (orang_id, alamat_jenis_id, alamat_lengkap(100))
) ENGINE=InnoDB;

-- =====================================================
-- 5. CREATE TABLES - BUSINESS LOGIC
-- =====================================================

-- Tabel Server
CREATE TABLE server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_server VARCHAR(100) NOT NULL,
    kode_server VARCHAR(10) UNIQUE NOT NULL,
    lokasi VARCHAR(255),
    owner_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Tipe Tebakan
CREATE TABLE tipe_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_tipe VARCHAR(10) NOT NULL UNIQUE,
    deskripsi TEXT,
    jumlah_digit INT NOT NULL,
    harga_dasar DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Hadiah
CREATE TABLE hadiah (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipe_tebakan_id INT NOT NULL,
    nama_hadiah VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    jumlah_hadiah DECIMAL(15,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tipe_tebakan_id) REFERENCES tipe_tebakan(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Sesi Server
CREATE TABLE sesi_server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    tanggal DATE NOT NULL,
    waktu_buka TIME NOT NULL,
    waktu_tutup TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    UNIQUE KEY (server_id, tanggal)
) ENGINE=InnoDB;

-- Tabel Deposit Member
CREATE TABLE deposit_member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    bos_id INT NOT NULL,
    saldo DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (bos_id) REFERENCES user(id) ON DELETE RESTRICT,
    UNIQUE KEY (user_id, bos_id)
) ENGINE=InnoDB;

-- Tabel Metode Pembayaran
CREATE TABLE metode_pembayaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_metode VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Transaksi Tebakan
CREATE TABLE transaksi_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_transaksi VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    sesi_server_id INT NOT NULL,
    total_bayar DECIMAL(15,2) NOT NULL,
    status ENUM('Pending','Dibayar','Dibatalkan','Selesai') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (sesi_server_id) REFERENCES sesi_server(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Hasil Tebakan
CREATE TABLE hasil_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sesi_server_id INT NOT NULL,
    tipe_tebakan_id INT NOT NULL,
    angka_hasil VARCHAR(10) NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sesi_server_id) REFERENCES sesi_server(id) ON DELETE RESTRICT,
    FOREIGN KEY (tipe_tebakan_id) REFERENCES tipe_tebakan(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    UNIQUE KEY (sesi_server_id, tipe_tebakan_id)
) ENGINE=InnoDB;

-- Tabel Detail Kemenangan
CREATE TABLE detail_kemenangan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaksi_id INT NOT NULL,
    tipe_tebakan_id INT NOT NULL,
    angka_tebakan VARCHAR(10) NOT NULL,
    jumlah_tebakan INT NOT NULL,
    hadiah_per_tebakan DECIMAL(15,2) NOT NULL,
    total_hadiah DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaksi_id) REFERENCES transaksi_tebakan(id) ON DELETE CASCADE,
    FOREIGN KEY (tipe_tebakan_id) REFERENCES tipe_tebakan(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Pembayaran Hadiah
CREATE TABLE pembayaran_hadiah (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detail_kemenangan_id INT NOT NULL,
    jumlah_dibayar DECIMAL(15,2) NOT NULL,
    status ENUM('Pending','Dibayar','Dibatalkan') DEFAULT 'Pending',
    dibayar_oleh INT,
    tanggal_pembayaran DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (detail_kemenangan_id) REFERENCES detail_kemenangan(id) ON DELETE RESTRICT,
    FOREIGN KEY (dibayar_oleh) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Transaksi Pembayaran
CREATE TABLE transaksi_pembayaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_transaksi VARCHAR(20) UNIQUE NOT NULL,
    dari_user_id INT NOT NULL,
    ke_user_id INT NOT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    metode_pembayaran_id INT,
    keterangan TEXT,
    status ENUM('Pending','Berhasil','Gagal','Dibatalkan') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (dari_user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (ke_user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (metode_pembayaran_id) REFERENCES metode_pembayaran(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Komisi Aturan
CREATE TABLE komisi_aturan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    persentase_komisi DECIMAL(5,2) NOT NULL,
    minimum_transaksi DECIMAL(15,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Komisi Transaksi
CREATE TABLE komisi_transaksi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaksi_id INT NOT NULL,
    user_id INT NOT NULL,
    jumlah_komisi DECIMAL(15,2) NOT NULL,
    persentase_komisi DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaksi_id) REFERENCES transaksi_tebakan(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 6. CREATE INDEXES
-- =====================================================

-- Indexes untuk optimasi query
CREATE INDEX idx_user_role ON user(role_id);
CREATE INDEX idx_user_orang ON user(orang_id);
CREATE INDEX idx_orang_agama ON orang(agama_id);
CREATE INDEX idx_orang_status_perkawinan ON orang(status_perkawinan_id);
CREATE INDEX idx_orang_identitas_orang ON orang_identitas(orang_id);
CREATE INDEX idx_orang_identitas_jenis ON orang_identitas(jenis_identitas_id);
CREATE INDEX idx_orang_alamat_orang ON orang_alamat(orang_id);
CREATE INDEX idx_orang_alamat_jenis ON orang_alamat(alamat_jenis_id);
CREATE INDEX idx_orang_alamat_kelurahan ON orang_alamat(kelurahan_desa_id);
CREATE INDEX idx_transaksi_sesi ON transaksi_tebakan(sesi_server_id);
CREATE INDEX idx_transaksi_user ON transaksi_tebakan(user_id);
CREATE INDEX idx_transaksi_status ON transaksi_tebakan(status);
CREATE INDEX idx_sesi_server_date ON sesi_server(tanggal);
CREATE INDEX idx_sesi_server_active ON sesi_server(is_active);
CREATE INDEX idx_deposit_user_bos ON deposit_member(user_id, bos_id);
CREATE INDEX idx_pembayaran_status ON transaksi_pembayaran(status);
CREATE INDEX idx_pembayaran_date ON transaksi_pembayaran(created_at);
CREATE INDEX idx_komisi_transaksi ON komisi_transaksi(transaksi_id);
CREATE INDEX idx_hasil_sesi ON hasil_tebakan(sesi_server_id);
CREATE INDEX idx_detail_transaksi ON detail_kemenangan(transaksi_id);

-- =====================================================
-- 7. INSERT MASTER DATA
-- =====================================================

-- Insert Master Agama
INSERT INTO master_agama (nama_agama, deskripsi) VALUES
('Islam', 'Agama Islam'),
('Kristen', 'Agama Kristen'),
('Katolik', 'Agama Katolik'),
('Hindu', 'Agama Hindu'),
('Buddha', 'Agama Buddha'),
('Konghucu', 'Agama Konghucu'),
('Lainnya', 'Agama lainnya');

-- Insert Master Status Perkawinan
INSERT INTO master_status_perkawinan (nama_status, deskripsi) VALUES
('Belum Menikah', 'Status belum menikah'),
('Menikah', 'Status sudah menikah'),
('Cerai', 'Status cerai'),
('Janda/Duda', 'Status janda atau duda');

-- Insert Master Jenis Identitas
INSERT INTO master_jenis_identitas (nama_jenis, deskripsi) VALUES
('Email', 'Alamat email'),
('Telepon', 'Nomor telepon'),
('WhatsApp', 'Nomor WhatsApp'),
('Telegram', 'Username Telegram'),
('Instagram', 'Username Instagram'),
('Facebook', 'Username Facebook'),
('LinkedIn', 'Username LinkedIn');

-- Insert Master Jenis Alamat
INSERT INTO alamat_jenis (nama_jenis, deskripsi) VALUES
('Rumah Tinggal', 'Alamat tempat tinggal utama'),
('Tempat Kerja', 'Alamat tempat bekerja'),
('Alamat Kantor', 'Alamat kantor atau tempat usaha'),
('Alamat Domisili', 'Alamat domisili resmi'),
('Alamat Korespondensi', 'Alamat untuk korespondensi'),
('Alamat Darurat', 'Alamat darurat atau kontak darurat');

-- Insert Role
INSERT INTO role (nama_role, deskripsi) VALUES
('Super Admin', 'Administrator tertinggi sistem'),
('Bos', 'Pemilik server dan bisnis'),
('Admin Bos', 'Administrator untuk Bos'),
('Transporter', 'Pengangkut dan distributor'),
('Penjual', 'Penjual tebakan'),
('Pembeli', 'Pembeli tebakan');

-- Insert Tipe Tebakan
INSERT INTO tipe_tebakan (nama_tipe, deskripsi, jumlah_digit, harga_dasar) VALUES
('4D', 'Tebakan 4 digit', 4, 1000.00),
('3D', 'Tebakan 3 digit', 3, 500.00),
('2D', 'Tebakan 2 digit', 2, 200.00),
('CE', 'Colok Bebas', 1, 100.00),
('CK', 'Colok Kembang', 1, 100.00),
('CB', 'Colok Buntut', 1, 100.00);

-- Insert Metode Pembayaran
INSERT INTO metode_pembayaran (nama_metode, deskripsi) VALUES
('Tunai', 'Pembayaran tunai'),
('Transfer Bank', 'Transfer antar bank'),
('E-Wallet', 'Pembayaran via e-wallet'),
('QRIS', 'Pembayaran via QRIS');

-- =====================================================
-- 8. CREATE VIEWS
-- =====================================================

-- View untuk data orang lengkap dengan identitas
CREATE VIEW view_orang_lengkap AS
SELECT 
    o.id,
    o.nik,
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

-- View untuk identitas orang
CREATE VIEW view_orang_identitas AS
SELECT 
    oi.id,
    oi.orang_id,
    o.nama_depan,
    o.nama_belakang,
    mji.nama_jenis as jenis_identitas,
    oi.nilai_identitas,
    oi.is_primary,
    oi.is_verified,
    oi.created_at
FROM orang_identitas oi
JOIN orang o ON oi.orang_id = o.id
JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id;

-- View untuk alamat orang
CREATE VIEW view_orang_alamat AS
SELECT 
    oa.id,
    oa.orang_id,
    o.nama_depan,
    o.nama_belakang,
    aj.nama_jenis as jenis_alamat,
    oa.alamat_lengkap,
    oa.rt,
    oa.rw,
    oa.kode_pos,
    kd.nama as kelurahan_desa,
    kk.nama as kabupaten_kota,
    p.nama as provinsi,
    n.nama as negara,
    oa.is_primary,
    oa.is_verified,
    oa.created_at
FROM orang_alamat oa
JOIN orang o ON oa.orang_id = o.id
JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
LEFT JOIN kelurahan_desa kd ON oa.kelurahan_desa_id = kd.id
LEFT JOIN kecamatan k ON kd.kecamatan_id = k.id
LEFT JOIN kabupaten_kota kk ON k.kabupaten_kota_id = kk.id
LEFT JOIN provinsi p ON kk.provinsi_id = p.id
LEFT JOIN negara n ON p.negara_id = n.id;

-- View untuk user dengan data lengkap
CREATE VIEW view_user_lengkap AS
SELECT 
    u.id,
    u.username,
    u.is_active,
    u.last_login,
    o.nik,
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

-- View untuk laba rugi harian
CREATE VIEW view_laba_rugi_harian AS
SELECT 
    DATE(tt.created_at) as tanggal,
    COUNT(tt.id) as total_transaksi,
    SUM(tt.total_bayar) as total_pendapatan,
    SUM(CASE WHEN dk.id IS NOT NULL THEN dk.total_hadiah ELSE 0 END) as total_hadiah_dibayar,
    SUM(tt.total_bayar) - SUM(CASE WHEN dk.id IS NOT NULL THEN dk.total_hadiah ELSE 0 END) as laba_bersih
FROM transaksi_tebakan tt
LEFT JOIN detail_kemenangan dk ON tt.id = dk.transaksi_id
WHERE tt.status = 'Selesai'
GROUP BY DATE(tt.created_at)
ORDER BY tanggal DESC;

-- View untuk arus kas
CREATE VIEW view_arus_kas AS
SELECT 
    'Pendapatan Tebakan' as jenis,
    DATE(created_at) as tanggal,
    SUM(total_bayar) as jumlah,
    'Masuk' as arah
FROM transaksi_tebakan 
WHERE status = 'Dibayar'
GROUP BY DATE(created_at)

UNION ALL

SELECT 
    'Pembayaran Hadiah' as jenis,
    DATE(created_at) as tanggal,
    SUM(jumlah_dibayar) as jumlah,
    'Keluar' as arah
FROM pembayaran_hadiah 
WHERE status = 'Dibayar'
GROUP BY DATE(created_at)

UNION ALL

SELECT 
    'Transfer Antar User' as jenis,
    DATE(created_at) as tanggal,
    SUM(jumlah) as jumlah,
    CASE WHEN dari_user_id = 1 THEN 'Keluar' ELSE 'Masuk' END as arah
FROM transaksi_pembayaran 
WHERE status = 'Berhasil'
GROUP BY DATE(created_at), arah;

-- View untuk penyerahan dana
CREATE VIEW view_penyerahan_dana AS
SELECT 
    u.username,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_tengah, ''), ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
    r.nama_role,
    dm.saldo as saldo_deposit,
    COUNT(tt.id) as total_transaksi,
    SUM(tt.total_bayar) as total_omset,
    SUM(CASE WHEN dk.id IS NOT NULL THEN dk.total_hadiah ELSE 0 END) as total_hadiah
FROM user u
JOIN orang o ON u.orang_id = o.id
JOIN role r ON u.role_id = r.id
LEFT JOIN deposit_member dm ON u.id = dm.user_id
LEFT JOIN transaksi_tebakan tt ON u.id = tt.user_id
LEFT JOIN detail_kemenangan dk ON tt.id = dk.transaksi_id
WHERE r.nama_role IN ('Penjual', 'Pembeli')
GROUP BY u.id, u.username, o.nama_depan, o.nama_tengah, o.nama_belakang, r.nama_role, dm.saldo;

-- =====================================================
-- 9. CREATE STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure untuk menambah identitas orang
CREATE PROCEDURE sp_tambah_identitas_orang(
    IN p_orang_id INT,
    IN p_jenis_identitas VARCHAR(50),
    IN p_nilai_identitas VARCHAR(255),
    IN p_is_primary BOOLEAN
)
BEGIN
    DECLARE v_jenis_id INT;
    
    -- Ambil ID jenis identitas
    SELECT id INTO v_jenis_id 
    FROM master_jenis_identitas 
    WHERE nama_jenis = p_jenis_identitas;
    
    -- Jika primary, set yang lain menjadi non-primary
    IF p_is_primary THEN
        UPDATE orang_identitas 
        SET is_primary = FALSE 
        WHERE orang_id = p_orang_id AND jenis_identitas_id = v_jenis_id;
    END IF;
    
    -- Insert identitas baru
    INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary)
    VALUES (p_orang_id, v_jenis_id, p_nilai_identitas, p_is_primary);
    
END //

-- Procedure untuk mendapatkan semua identitas orang
CREATE PROCEDURE sp_get_identitas_orang(IN p_orang_id INT)
BEGIN
    SELECT 
        mji.nama_jenis as jenis,
        oi.nilai_identitas as nilai,
        oi.is_primary,
        oi.is_verified
    FROM orang_identitas oi
    JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
    WHERE oi.orang_id = p_orang_id
    ORDER BY oi.is_primary DESC, mji.nama_jenis;
END //

-- Procedure untuk menambah alamat orang
CREATE PROCEDURE sp_tambah_alamat_orang(
    IN p_orang_id INT,
    IN p_jenis_alamat VARCHAR(50),
    IN p_alamat_lengkap TEXT,
    IN p_rt VARCHAR(3),
    IN p_rw VARCHAR(3),
    IN p_kode_pos VARCHAR(10),
    IN p_kelurahan_desa_id INT,
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
    INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary)
    VALUES (p_orang_id, v_jenis_id, p_alamat_lengkap, p_rt, p_rw, p_kode_pos, p_kelurahan_desa_id, p_is_primary);
    
END //

-- Procedure untuk mendapatkan semua alamat orang
CREATE PROCEDURE sp_get_alamat_orang(IN p_orang_id INT)
BEGIN
    SELECT 
        aj.nama_jenis as jenis,
        oa.alamat_lengkap,
        oa.rt,
        oa.rw,
        oa.kode_pos,
        kd.nama as kelurahan_desa,
        kk.nama as kabupaten_kota,
        p.nama as provinsi,
        oa.is_primary,
        oa.is_verified
    FROM orang_alamat oa
    JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
    LEFT JOIN kelurahan_desa kd ON oa.kelurahan_desa_id = kd.id
    LEFT JOIN kecamatan k ON kd.kecamatan_id = k.id
    LEFT JOIN kabupaten_kota kk ON k.kabupaten_kota_id = kk.id
    LEFT JOIN provinsi p ON kk.provinsi_id = p.id
    WHERE oa.orang_id = p_orang_id
    ORDER BY oa.is_primary DESC, aj.nama_jenis;
END //

DELIMITER ;

-- =====================================================
-- 10. CREATE TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger untuk memastikan hanya satu primary identitas per jenis
-- DIPINDAHKAN KE STORED PROCEDURE untuk menghindari konflik
-- CREATE TRIGGER tr_orang_identitas_before_insert
-- BEFORE INSERT ON orang_identitas
-- FOR EACH ROW
-- BEGIN
--     IF NEW.is_primary = TRUE THEN
--         UPDATE orang_identitas 
--         SET is_primary = FALSE 
--         WHERE orang_id = NEW.orang_id 
--         AND jenis_identitas_id = NEW.jenis_identitas_id;
--     END IF;
-- END //

-- Trigger untuk update timestamp
CREATE TRIGGER tr_orang_identitas_before_update
BEFORE UPDATE ON orang_identitas
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

-- Trigger untuk memastikan hanya satu primary alamat per jenis
-- DIPINDAHKAN KE STORED PROCEDURE untuk menghindari konflik
-- CREATE TRIGGER tr_orang_alamat_before_insert
-- BEFORE INSERT ON orang_alamat
-- FOR EACH ROW
-- BEGIN
--     IF NEW.is_primary = TRUE THEN
--         UPDATE orang_alamat 
--         SET is_primary = FALSE 
--         WHERE orang_id = NEW.orang_id 
--         AND alamat_jenis_id = NEW.alamat_jenis_id;
--     END IF;
-- END //

-- Trigger untuk update timestamp alamat
CREATE TRIGGER tr_orang_alamat_before_update
BEFORE UPDATE ON orang_alamat
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- =====================================================
-- 11. COMMENTS & DOCUMENTATION
-- =====================================================

/*
OPTIMASI DATABASE LUNA SYSTEM

KEUNTUNGAN NORMALISASI YANG DITERAPKAN:

1. MASTER TABLES (master_agama, master_status_perkawinan, master_jenis_identitas, alamat_jenis):
   - Menghemat penyimpanan (tidak ada duplikasi data)
   - Konsistensi data (tidak ada typo atau variasi)
   - Mudah maintenance (ubah sekali, berlaku di semua tempat)
   - Referential integrity yang lebih baik

2. ORANG_IDENTITAS TABLE:
   - Satu orang bisa punya multiple email/telepon
   - Fleksibilitas untuk jenis identitas baru
   - Tracking primary dan verified status
   - History perubahan identitas

3. ORANG_ALAMAT TABLE:
   - Satu orang bisa punya multiple alamat (rumah, kerja, kantor, dll)
   - Fleksibilitas untuk jenis alamat baru
   - Tracking primary dan verified status
   - Integrasi dengan data lokasi administratif (RT/RW, Kelurahan, dll)
   - Support untuk alamat lengkap dan terstruktur

4. PERFORMANCE IMPROVEMENTS:
   - Index yang tepat untuk query yang sering digunakan
   - Views untuk query kompleks
   - Stored procedures untuk operasi yang sering dilakukan
   - Triggers untuk data consistency

5. SCALABILITY:
   - Mudah menambah jenis identitas baru
   - Mudah menambah jenis alamat baru
   - Mudah menambah agama atau status perkawinan baru
   - Struktur yang mendukung pertumbuhan data

6. DATA INTEGRITY:
   - Foreign key constraints
   - Unique constraints yang tepat
   - Triggers untuk business rules
   - Validasi di level database

CONTOH PENGGUNAAN:

-- Tambah identitas baru
CALL sp_tambah_identitas_orang(1, 'Email', 'john@example.com', TRUE);
CALL sp_tambah_identitas_orang(1, 'Telepon', '08123456789', FALSE);
CALL sp_tambah_identitas_orang(1, 'WhatsApp', '08123456789', FALSE);

-- Tambah alamat baru
CALL sp_tambah_alamat_orang(1, 'Rumah Tinggal', 'Jl. Sudirman No. 123', '001', '002', '12345', 1, TRUE);
CALL sp_tambah_alamat_orang(1, 'Tempat Kerja', 'Jl. Thamrin No. 456', '003', '004', '67890', 2, FALSE);

-- Ambil semua identitas
CALL sp_get_identitas_orang(1);

-- Ambil semua alamat
CALL sp_get_alamat_orang(1);

-- Query dengan view
SELECT * FROM view_user_lengkap WHERE nama_role = 'Penjual';
SELECT * FROM view_orang_identitas WHERE orang_id = 1;
SELECT * FROM view_orang_alamat WHERE orang_id = 1;
*/