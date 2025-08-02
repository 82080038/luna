-- Script untuk memperbaiki struktur tabel orang_alamat
-- Database: sistem_angka

USE sistem_angka;

-- 1. Backup data existing (jika ada)
CREATE TABLE IF NOT EXISTS orang_alamat_backup AS SELECT * FROM orang_alamat;

-- 2. Drop foreign key constraints yang ada
ALTER TABLE orang_alamat DROP FOREIGN KEY IF EXISTS orang_alamat_ibfk_1;
ALTER TABLE orang_alamat DROP FOREIGN KEY IF EXISTS orang_alamat_ibfk_2;
ALTER TABLE orang_alamat DROP FOREIGN KEY IF EXISTS orang_alamat_ibfk_3;

-- 3. Drop tabel lama
DROP TABLE IF EXISTS orang_alamat;

-- 4. Buat tabel baru dengan struktur yang benar
CREATE TABLE orang_alamat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orang INT NOT NULL,
    id_jenis_alamat INT NOT NULL,
    id_negara INT DEFAULT 1, -- Default Indonesia
    id_propinsi INT,
    id_kab_kota INT,
    id_kecamatan INT,
    id_desa INT,
    nama_alamat TEXT,
    kode_pos VARCHAR(10),
    lat_long VARCHAR(50),
    alamat_utama ENUM('Y', 'N') DEFAULT 'N',
    aktif ENUM('Y', 'N') DEFAULT 'Y',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (id_orang) REFERENCES orang(id) ON DELETE CASCADE,
    FOREIGN KEY (id_jenis_alamat) REFERENCES alamat_jenis(id) ON DELETE RESTRICT,
    
    -- Indexes untuk performa
    INDEX idx_orang (id_orang),
    INDEX idx_alamat_utama (alamat_utama),
    INDEX idx_aktif (aktif),
    INDEX idx_propinsi (id_propinsi),
    INDEX idx_kab_kota (id_kab_kota),
    INDEX idx_kecamatan (id_kecamatan),
    INDEX idx_desa (id_desa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Insert data default untuk alamat_jenis jika belum ada
INSERT IGNORE INTO alamat_jenis (id, nama_jenis, deskripsi) VALUES 
(1, 'Rumah', 'Alamat tempat tinggal utama'),
(2, 'Kantor', 'Alamat kantor/tempat kerja'),
(3, 'Kos', 'Alamat tempat kos'),
(4, 'Lainnya', 'Alamat lainnya');

-- 6. Insert data default untuk negara jika belum ada
INSERT IGNORE INTO negara (id, nama, kode) VALUES 
(1, 'Indonesia', 'ID');

-- 7. Verifikasi struktur
DESCRIBE orang_alamat;

-- 8. Tampilkan status
SELECT 'Tabel orang_alamat berhasil diperbaiki!' as status; 