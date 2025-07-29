-- Database Sistem Tebakan Angka - Versi Lengkap dan Bersih
-- File ini berisi database, tabel, view, dan data awal tanpa trigger

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================
CREATE DATABASE IF NOT EXISTS sistem_tebakan_angka;
USE sistem_tebakan_angka;

-- =====================================================
-- 2. CREATE TABLES
-- =====================================================

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

-- Tabel Orang
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
    agama VARCHAR(20),
    status_perkawinan ENUM('Belum Menikah','Menikah','Cerai','Janda/Duda'),
    no_telepon VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    kode_pos VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id) ON DELETE RESTRICT,
    UNIQUE KEY (kecamatan_id, nama)
) ENGINE=InnoDB;

-- Tabel Server
CREATE TABLE server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_server VARCHAR(100) NOT NULL,
    singkatan_server VARCHAR(10) NOT NULL UNIQUE,
    hari_buka VARCHAR(20) NOT NULL COMMENT 'Contoh: Senin-Sabtu',
    hari_tutup VARCHAR(20) NOT NULL COMMENT 'Contoh: Minggu',
    jam_buka TIME NOT NULL,
    jam_tutup TIME NOT NULL,
    bos_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (bos_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Tipe Tebakan
CREATE TABLE tipe_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    kode VARCHAR(10) NOT NULL COMMENT '4D, 3D, 2D, CE, CK, CB',
    nama VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE,
    UNIQUE KEY (server_id, kode)
) ENGINE=InnoDB;

-- Tabel Hadiah
CREATE TABLE hadiah (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipe_tebakan_id INT NOT NULL,
    nama_hadiah VARCHAR(100) NOT NULL,
    nilai DECIMAL(10,2) NOT NULL COMMENT 'Nilai hadiah dalam persen',
    minimal_angka INT COMMENT 'Minimal angka untuk memenangkan hadiah ini',
    maksimal_angka INT COMMENT 'Maksimal angka untuk memenangkan hadiah ini',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tipe_tebakan_id) REFERENCES tipe_tebakan(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabel Sesi Server
CREATE TABLE sesi_server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    nama_sesi VARCHAR(50) NOT NULL,
    tanggal DATE NOT NULL,
    jam_buka TIME NOT NULL,
    jam_tutup TIME NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    diaktifkan_oleh INT COMMENT 'User yang mengaktifkan sesi',
    created_by INT NOT NULL COMMENT 'User yang membuat sesi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE,
    FOREIGN KEY (diaktifkan_oleh) REFERENCES user(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    UNIQUE KEY (server_id, tanggal, nama_sesi)
) ENGINE=InnoDB;

-- Tabel Deposit Member
CREATE TABLE deposit_member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    bos_id INT NOT NULL COMMENT 'Bos pemilik deposit',
    saldo DECIMAL(15,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (bos_id) REFERENCES user(id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, bos_id)
) ENGINE=InnoDB;

-- Tabel Metode Pembayaran
CREATE TABLE metode_pembayaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    kode VARCHAR(10) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabel Transaksi Tebakan
CREATE TABLE transaksi_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_transaksi VARCHAR(20) UNIQUE,
    user_id INT NOT NULL COMMENT 'Penjual/Pembeli yang input',
    sesi_server_id INT NOT NULL,
    data_tebakan JSON NOT NULL COMMENT 'Format: {"4D":[{"angka":"1234","jumlah":1}],"3D":[{"angka":"123","jumlah":2}]}',
    harga_total DECIMAL(15,2) NOT NULL,
    status ENUM('pending','disetujui','ditolak','dibatalkan') DEFAULT 'pending',
    created_by INT NOT NULL,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (sesi_server_id) REFERENCES sesi_server(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (updated_by) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Hasil Tebakan
CREATE TABLE hasil_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sesi_server_id INT NOT NULL,
    angka_keluar JSON NOT NULL COMMENT 'Format: {"4D":"1234","3D":"234","2D":"34","CE":"3","CK":"1","CB":"5"}',
    created_by INT NOT NULL COMMENT 'Hanya Super Admin/Bos',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sesi_server_id) REFERENCES sesi_server(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    UNIQUE KEY (sesi_server_id)
) ENGINE=InnoDB;

-- Tabel Detail Kemenangan
CREATE TABLE detail_kemenangan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaksi_id INT NOT NULL,
    tipe_tebakan VARCHAR(10) NOT NULL COMMENT '4D,3D,2D,CE,CK,CB',
    angka_menang VARCHAR(10) NOT NULL,
    jumlah_kemenangan INT NOT NULL,
    nilai_hadiah DECIMAL(15,2) NOT NULL,
    total_menang DECIMAL(15,2) NOT NULL COMMENT 'jumlah_kemenangan × nilai_hadiah',
    FOREIGN KEY (transaksi_id) REFERENCES transaksi_tebakan(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabel Pembayaran Hadiah
CREATE TABLE pembayaran_hadiah (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_pembayaran VARCHAR(20) UNIQUE,
    transaksi_id INT NOT NULL,
    total_menang DECIMAL(15,2) NOT NULL,
    status ENUM('pending','dibayar','ditolak') DEFAULT 'pending',
    metode_pembayaran ENUM('tunai','deposit','transfer'),
    transporter_id INT COMMENT 'Jika perlu diantarkan',
    dibayar_oleh INT COMMENT 'Penjual/Bos',
    diterima_oleh INT NOT NULL COMMENT 'Pembeli yang menang',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (transaksi_id) REFERENCES transaksi_tebakan(id) ON DELETE RESTRICT,
    FOREIGN KEY (transporter_id) REFERENCES user(id) ON DELETE SET NULL,
    FOREIGN KEY (dibayar_oleh) REFERENCES user(id) ON DELETE SET NULL,
    FOREIGN KEY (diterima_oleh) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabel Transaksi Pembayaran
CREATE TABLE transaksi_pembayaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_transaksi VARCHAR(20) UNIQUE,
    jenis_transaksi ENUM(
        'pembeli_ke_penjual',
        'pembeli_ke_bos',
        'penjual_ke_transporter',
        'transporter_ke_bos',
        'bos_ke_super_admin',
        'bos_ke_admin',
        'pembayaran_hadiah',
        'topup_deposit',
        'penyesuaian'
    ) NOT NULL,
    dari_user_id INT NOT NULL,
    ke_user_id INT NOT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    metode_pembayaran_id INT,
    status ENUM('pending','sukses','gagal','ditolak') DEFAULT 'pending',
    keterangan TEXT,
    bukti_pembayaran VARCHAR(255),
    created_by INT NOT NULL,
    verified_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (dari_user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (ke_user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (metode_pembayaran_id) REFERENCES metode_pembayaran(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (verified_by) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabel Komisi Aturan
CREATE TABLE komisi_aturan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bos_id INT NOT NULL,
    role_penerima VARCHAR(50) NOT NULL COMMENT 'Super Admin, Admin Bos, Transporter, Penjual',
    persentase DECIMAL(5,2) NOT NULL COMMENT 'Dalam persen',
    min_omset DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bos_id) REFERENCES user(id) ON DELETE CASCADE,
    UNIQUE KEY (bos_id, role_penerima, min_omset)
) ENGINE=InnoDB;

-- Tabel Komisi Transaksi
CREATE TABLE komisi_transaksi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaksi_id INT NOT NULL,
    user_id INT NOT NULL COMMENT 'Penerima komisi',
    role_penerima VARCHAR(50) NOT NULL,
    jumlah_komisi DECIMAL(15,2) NOT NULL,
    persentase_komisi DECIMAL(5,2) NOT NULL,
    tanggal_dibayar TIMESTAMP NULL,
    status ENUM('pending','dibayar') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaksi_id) REFERENCES transaksi_tebakan(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- 3. CREATE INDEXES
-- =====================================================
CREATE INDEX idx_user_role ON user(role_id);
CREATE INDEX idx_user_orang ON user(orang_id);
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
-- 4. CREATE VIEWS
-- =====================================================

-- View Laba Rugi Harian
CREATE VIEW view_laba_rugi_harian AS
SELECT 
    DATE(t.created_at) AS tanggal,
    s.bos_id,
    COUNT(t.id) AS jumlah_transaksi,
    SUM(t.harga_total) AS omset,
    SUM(COALESCE(dk.total_menang, 0)) AS total_hadiah,
    SUM(t.harga_total) - SUM(COALESCE(dk.total_menang, 0)) AS laba_kotor,
    SUM(COALESCE(k.komisi, 0)) AS total_komisi,
    (SUM(t.harga_total) - SUM(COALESCE(dk.total_menang, 0)) - SUM(COALESCE(k.komisi, 0))) AS laba_bersih
FROM 
    transaksi_tebakan t
JOIN 
    sesi_server ss ON t.sesi_server_id = ss.id
JOIN 
    server s ON ss.server_id = s.id
LEFT JOIN (
    SELECT transaksi_id, SUM(total_menang) AS total_menang
    FROM detail_kemenangan
    GROUP BY transaksi_id
) dk ON t.id = dk.transaksi_id
LEFT JOIN (
    SELECT transaksi_id, SUM(jumlah_komisi) AS komisi
    FROM komisi_transaksi
    GROUP BY transaksi_id
) k ON t.id = k.transaksi_id
GROUP BY 
    DATE(t.created_at), s.bos_id;

-- View Arus Kas
CREATE VIEW view_arus_kas AS
SELECT 
    s.bos_id,
    tp.jenis_transaksi,
    DATE(tp.created_at) AS tanggal,
    SUM(CASE WHEN tp.jenis_transaksi IN ('pembeli_ke_bos','penjual_ke_transporter','transporter_ke_bos','topup_deposit') 
             THEN tp.jumlah ELSE 0 END) AS pemasukan,
    SUM(CASE WHEN tp.jenis_transaksi IN ('pembayaran_hadiah','bos_ke_super_admin','bos_ke_admin','pembeli_ke_penjual') 
             THEN tp.jumlah ELSE 0 END) AS pengeluaran,
    SUM(CASE WHEN tp.jenis_transaksi IN ('pembeli_ke_bos','penjual_ke_transporter','transporter_ke_bos','topup_deposit') 
             THEN tp.jumlah 
             ELSE -tp.jumlah END) AS saldo
FROM 
    transaksi_pembayaran tp
LEFT JOIN 
    user u ON tp.ke_user_id = u.id
LEFT JOIN 
    server s ON u.id = s.bos_id
WHERE 
    tp.status = 'sukses'
GROUP BY 
    s.bos_id, tp.jenis_transaksi, DATE(tp.created_at);

-- View Penyerahan Dana
CREATE VIEW view_penyerahan_dana AS
SELECT 
    tp.kode_transaksi,
    tp.jenis_transaksi,
    CONCAT(odu.nama_depan, ' ', odu.nama_belakang) AS dari,
    CONCAT(oku.nama_depan, ' ', oku.nama_belakang) AS ke,
    tp.jumlah,
    mp.nama AS metode,
    tp.status,
    tp.created_at,
    CONCAT(ovu.nama_depan, ' ', ovu.nama_belakang) AS verifikator,
    s.bos_id
FROM 
    transaksi_pembayaran tp
JOIN 
    user du ON tp.dari_user_id = du.id
JOIN 
    orang odu ON du.orang_id = odu.id
JOIN 
    user ku ON tp.ke_user_id = ku.id
JOIN 
    orang oku ON ku.orang_id = oku.id
LEFT JOIN 
    user vu ON tp.verified_by = vu.id
LEFT JOIN 
    orang ovu ON vu.orang_id = ovu.id
LEFT JOIN 
    metode_pembayaran mp ON tp.metode_pembayaran_id = mp.id
LEFT JOIN 
    server s ON ku.id = s.bos_id OR du.id = s.bos_id;

-- =====================================================
-- 5. INSERT INITIAL DATA
-- =====================================================

-- Insert data role
INSERT INTO role (nama_role, deskripsi, parent_role_id) VALUES 
('Super Admin', 'Administrator dengan hak akses penuh', NULL),
('Bos', 'Pemilik/pimpinan tertinggi sistem', 1),
('Admin Bos', 'Administrator khusus untuk Bos', 2),
('Transporter', 'Pengangkut/pengirim barang', 2),
('Penjual', 'Staff penjual yang bertugas melayani pembeli', 4),
('Pembeli', 'Role untuk user yang melakukan pembelian', 5);

-- Insert data user awal (super admin)
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin, email) 
VALUES ('Super', 'Admin', 'L', 'superadmin@system.com');

SET @super_admin_id = LAST_INSERT_ID();

INSERT INTO user (orang_id, role_id, username, password_hash) 
VALUES (@super_admin_id, 1, 'superadmin', SHA2('admin123', 256));

-- Insert metode pembayaran
INSERT INTO metode_pembayaran (nama, kode) VALUES 
('Tunai', 'CASH'),
('Transfer Bank', 'TRF'),
('Deposit', 'DEP'),
('E-Wallet', 'EWAL');

-- =====================================================
-- 6. SUCCESS MESSAGE
-- =====================================================
SELECT 'Database sistem_tebakan_angka berhasil dibuat!' AS message;