# Panduan Optimasi Database Luna System

## Overview

Dokumen ini menjelaskan optimasi database yang telah dilakukan pada Luna System untuk meningkatkan efisiensi penyimpanan, konsistensi data, dan fleksibilitas sistem.

## Perubahan Utama

### 1. Normalisasi Master Data

#### Sebelum Optimasi:
```sql
-- Tabel orang dengan data yang berulang
CREATE TABLE orang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_depan VARCHAR(50),
    agama VARCHAR(50),           -- Data berulang
    status_perkawinan VARCHAR(50), -- Data berulang
    no_telepon VARCHAR(15),      -- Hanya 1 nomor
    email VARCHAR(100)           -- Hanya 1 email
);
```

#### Setelah Optimasi:
```sql
-- Master tables untuk data yang berulang
CREATE TABLE master_agama (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_agama VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE master_status_perkawinan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_status VARCHAR(50) NOT NULL UNIQUE
);

-- Tabel orang yang dinormalisasi
CREATE TABLE orang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_depan VARCHAR(50),
    agama_id INT,                -- Foreign key
    status_perkawinan_id INT     -- Foreign key
);
```

### 2. Multiple Identitas

#### Tabel Baru: `orang_identitas`
```sql
CREATE TABLE orang_identitas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_id INT NOT NULL,
    jenis_identitas_id INT NOT NULL,
    nilai_identitas VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE
);
```

**Keuntungan:**
- Satu orang bisa punya multiple email/telepon
- Tracking primary dan verified status
- Fleksibilitas untuk jenis identitas baru

### 3. Multiple Alamat

#### Tabel Baru: `alamat_jenis` dan `orang_alamat`
```sql
CREATE TABLE alamat_jenis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_jenis VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE orang_alamat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_id INT NOT NULL,
    alamat_jenis_id INT NOT NULL,
    alamat_lengkap TEXT NOT NULL,
    rt VARCHAR(3),
    rw VARCHAR(3),
    kode_pos VARCHAR(10),
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE
);
```

**Keuntungan:**
- Satu orang bisa punya berbagai jenis alamat (rumah, kerja, kantor, dll)
- Integrasi dengan data lokasi administratif
- Tracking primary dan verified status

## Stored Procedures

### 1. Identitas Management
```sql
-- Tambah identitas baru
CALL sp_tambah_identitas_orang(1, 'Email', 'john@example.com', TRUE);
CALL sp_tambah_identitas_orang(1, 'Telepon', '08123456789', FALSE);

-- Ambil semua identitas
CALL sp_get_identitas_orang(1);
```

### 2. Alamat Management
```sql
-- Tambah alamat baru
CALL sp_tambah_alamat_orang(1, 'Rumah Tinggal', 'Jl. Sudirman No. 123', '001', '002', '10310', NULL, TRUE);
CALL sp_tambah_alamat_orang(1, 'Tempat Kerja', 'Jl. Thamrin No. 456', '003', '004', '10350', NULL, FALSE);

-- Ambil semua alamat
CALL sp_get_alamat_orang(1);
```

## Views

### 1. Data Lengkap
```sql
-- View untuk data orang lengkap
SELECT * FROM view_orang_lengkap;

-- View untuk identitas orang
SELECT * FROM view_orang_identitas WHERE orang_id = 1;

-- View untuk alamat orang
SELECT * FROM view_orang_alamat WHERE orang_id = 1;
```

### 2. User Management
```sql
-- View untuk user dengan data lengkap
SELECT * FROM view_user_lengkap WHERE nama_role = 'Penjual';
```

## Performance Improvements

### 1. Index Optimization
```sql
-- Index untuk query yang sering digunakan
CREATE INDEX idx_orang_agama ON orang(agama_id);
CREATE INDEX idx_orang_status_perkawinan ON orang(status_perkawinan_id);
CREATE INDEX idx_orang_identitas_orang ON orang_identitas(orang_id);
CREATE INDEX idx_orang_alamat_orang ON orang_alamat(orang_id);
```

### 2. Data Integrity
```sql
-- Triggers untuk konsistensi data
CREATE TRIGGER tr_orang_identitas_before_insert
BEFORE INSERT ON orang_identitas
FOR EACH ROW
BEGIN
    IF NEW.is_primary = TRUE THEN
        UPDATE orang_identitas 
        SET is_primary = FALSE 
        WHERE orang_id = NEW.orang_id 
        AND jenis_identitas_id = NEW.jenis_identitas_id;
    END IF;
END;
```

## Perbandingan Penyimpanan

### Sebelum Normalisasi:
- 1000 user dengan 4 status perkawinan yang sama
- 1000 x 20 bytes = 20,000 bytes untuk status perkawinan

### Setelah Normalisasi:
- 4 x 20 bytes = 80 bytes untuk status perkawinan
- **Penghematan: 99.6%**

## Keuntungan Optimasi

1. **Hemat Penyimpanan**: 99%+ penghematan untuk data yang berulang
2. **Konsistensi Data**: Tidak ada typo atau variasi
3. **Maintenance Mudah**: Ubah sekali, berlaku di semua tempat
4. **Fleksibilitas**: Mudah tambah jenis identitas dan alamat baru
5. **Data Integrity**: Foreign key constraints
6. **Performance**: Index yang tepat untuk query yang sering digunakan
7. **Multiple Addresses**: Satu orang bisa punya berbagai jenis alamat
8. **Address Tracking**: Primary dan verified status untuk alamat

## File Database

### 1. `database_optimized.sql`
- Schema database yang sudah dioptimasi
- Master tables, stored procedures, triggers, views
- Index optimization

### 2. `insert_dummy_optimized.sql`
- Data dummy untuk testing
- Contoh penggunaan stored procedures
- Test queries untuk validasi

## Cara Penggunaan

### 1. Import Database
```sql
-- Import schema
SOURCE database_optimized.sql;

-- Import data dummy
SOURCE insert_dummy_optimized.sql;
```

### 2. Testing
```sql
-- Test identitas
CALL sp_get_identitas_orang(1);

-- Test alamat
CALL sp_get_alamat_orang(1);

-- Test views
SELECT * FROM view_user_lengkap;
```

## Migration Guide

### Dari Database Lama ke Baru:
1. Backup database lama
2. Export data yang diperlukan
3. Import schema baru
4. Migrate data menggunakan stored procedures
5. Validate data integrity

## Support

Untuk pertanyaan atau bantuan lebih lanjut, silakan hubungi tim development Luna System.

---

**Versi**: 2.0  
**Tanggal**: 2024  
**Status**: Production Ready