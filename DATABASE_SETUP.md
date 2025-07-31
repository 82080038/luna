# Database Setup Guide - Luna System

## Overview
Luna System menggunakan dua database terpisah:
- **sistem_angka**: Database utama untuk aplikasi (user, server, transaksi, dll)
- **sistem_alamat**: Database untuk data geografis (provinsi, kabupaten, kecamatan, kelurahan)

## Database Configuration

### 1. Environment Variables
Buat file `.env` di root project dengan konfigurasi berikut:

```env
# Database Configuration
DB_HOST=localhost
DB_NAME_ANGKA=sistem_angka
DB_NAME_ALAMAT=sistem_alamat
DB_USER=root
DB_PASS=

# Application Environment
APP_ENV=development
```

### 2. Database Connection Functions

#### Main Database (sistem_angka)
```php
// Untuk data aplikasi utama
$pdo = getDatabaseConnection();
```

#### Geographical Database (sistem_alamat)
```php
// Untuk data geografis
$pdo = getAlamatDatabaseConnection();
```

## Database Schema

### sistem_angka Database
Tabel utama untuk aplikasi:
- `user` - Data pengguna
- `server` - Data server
- `sesi_server` - Sesi server
- `transaksi` - Transaksi
- `user_ownership` - Hierarki user
- `financial_transactions` - Transaksi keuangan
- `audit_logs` - Log audit

### sistem_alamat Database
Tabel untuk data geografis:
- `provinsi` - Data provinsi
- `kabupaten_kota` - Data kabupaten/kota
- `kecamatan` - Data kecamatan
- `kelurahan_desa` - Data kelurahan/desa

## API Endpoints

### Geographical Data APIs
Semua API geografis menggunakan `sistem_alamat` database:

1. **GET /api/get_provinsi.php**
   - Mengambil semua provinsi
   - Database: sistem_alamat

2. **GET /api/get_kabupaten.php?provinsi_id={id}**
   - Mengambil kabupaten berdasarkan provinsi
   - Database: sistem_alamat

3. **GET /api/get_kecamatan.php?kabupaten_id={id}**
   - Mengambil kecamatan berdasarkan kabupaten
   - Database: sistem_alamat

4. **GET /api/get_kelurahan.php?kecamatan_id={id}**
   - Mengambil kelurahan berdasarkan kecamatan
   - Database: sistem_alamat

## Setup Instructions

### 1. Create Databases
```sql
-- Buat database sistem_angka
CREATE DATABASE sistem_angka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Buat database sistem_alamat
CREATE DATABASE sistem_alamat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. Import Schema
```bash
# Import schema sistem_angka
mysql -u root -p sistem_angka < db/schema.sql

# Import schema sistem_alamat
mysql -u root -p sistem_alamat < db/alamat_schema.sql
```

### 3. Import Data
```bash
# Import data geografis ke sistem_alamat
mysql -u root -p sistem_alamat < db/alamat_data.sql
```

## Troubleshooting

### Error: "Database connection failed"
1. Periksa konfigurasi database di `.env`
2. Pastikan MySQL server berjalan
3. Periksa username dan password database

### Error: "Geographical database connection failed"
1. Pastikan database `sistem_alamat` sudah dibuat
2. Periksa tabel `provinsi`, `kabupaten_kota`, `kecamatan`, `kelurahan_desa`
3. Pastikan data geografis sudah diimport

### Error: "Failed to fetch" di frontend
1. Periksa apakah API endpoints dapat diakses
2. Periksa error log PHP
3. Pastikan CORS dikonfigurasi dengan benar

## Security Considerations

1. **Environment Variables**: Jangan hardcode database credentials
2. **Database Permissions**: Gunakan user dengan minimal privileges
3. **Connection Security**: Gunakan SSL untuk koneksi database di production
4. **Input Validation**: Semua input harus divalidasi dan disanitasi

## Performance Optimization

1. **Indexing**: Pastikan foreign key columns ter-index
2. **Connection Pooling**: Gunakan connection pooling untuk performa
3. **Caching**: Implementasikan caching untuk data geografis
4. **Query Optimization**: Optimasi query untuk performa maksimal

## Monitoring

1. **Database Logs**: Monitor database error logs
2. **Application Logs**: Monitor application error logs
3. **Performance Metrics**: Monitor query performance
4. **Connection Monitoring**: Monitor database connections 