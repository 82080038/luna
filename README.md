# 🌙 Luna System - Sistem Tebakan Angka

Sistem manajemen tebakan angka yang modern dan responsif dengan arsitektur multi-role dan mobile-first design.

## 🚀 **Fitur Utama**

- **Multi-Role System**: Super Admin, Bos, Admin Bos, Transporter, Penjual, Pembeli
- **Mobile-First Design**: Responsif di semua perangkat
- **Bootstrap 5.3.0**: Framework CSS modern dan konsisten
- **Real-time Dashboard**: Statistik dan monitoring real-time
- **BOS Statistics**: Monitoring jumlah BOS aktif dan tidak aktif
- **Input Tebakan**: Interface yang user-friendly untuk input tebakan
- **Tambah User Bos**: Form lengkap untuk menambahkan user Bos baru dengan data pribadi, kontak, dan alamat
- **Database MySQL Optimized**: Struktur database yang terorganisir dan teroptimasi

## 🎨 **Perbaikan Tampilan (v2.0)**

### **CSS & Bootstrap Integration**
- ✅ **Mengutamakan Bootstrap**: Semua komponen menggunakan Bootstrap 5.3.0
- ✅ **Menghapus Konflik CSS**: Tidak ada lagi konflik antara custom CSS dan Bootstrap
- ✅ **Responsive Design**: Tampilan yang sempurna di mobile, tablet, dan desktop
- ✅ **Consistent Styling**: Semua halaman memiliki tampilan yang konsisten

### **Halaman yang Diperbaiki**
1. **Login Page** (`index.html`) - Form yang lebih baik dengan validation
2. **Mobile Dashboard** (`mobile_dashboard.html`) - Layout yang modern dengan cards
3. **Super Admin Dashboard** (`super_admin_dashboard.html`) - Interface admin yang profesional
4. **Input Tebakan** (`input_tebakan_mobile.html`) - Form input yang user-friendly

## 🛠️ **Cara Menjalankan**

### **1. Setup Local Server**
```bash
# Menggunakan XAMPP
# 1. Copy folder ke C:\xampp\htdocs\luna\
# 2. Start Apache dan MySQL di XAMPP
# 3. Buka http://localhost/luna/
```

### **2. Setup Database (RECOMMENDED)**
```bash
# Database Optimized - Struktur terbaik untuk production
# 1. Buka phpMyAdmin: http://localhost/phpmyadmin
# 2. Import db/database_optimized.sql
# 3. Jalankan db/insert_dummy_optimized.sql untuk data dummy
```

### **3. Login Demo**
```
Username: admin
Password: admin123
Role: Super Admin
```

### **4. Test API Connection**
```bash
# Test BOS Statistics API
http://localhost/luna/api/get_bos_statistics.php

# Test Add Bos API (POST request)
http://localhost/luna/api/add_bos.php
```

## 📁 **Struktur File**

```
luna/
├── css/
│   └── styles.css          # CSS utama dengan Bootstrap integration
├── js/
│   └── app.js             # JavaScript utama dengan utility functions
├── db/
│   ├── database_optimized.sql # Database schema optimized (RECOMMENDED)
│   ├── insert_dummy_optimized.sql # Data dummy untuk database optimized
│   ├── sistem_angka.sql # Database schema original
│   ├── fix_database_structure.sql # Perbaikan struktur database
│   ├── insert_dummy_optimized.sql # Data dummy untuk testing
│   └── DATABASE_OPTIMIZATION_GUIDE.md # Panduan optimasi database
├── api/
│   ├── config.php # Konfigurasi database dan helper functions
│   ├── get_bos_statistics.php # API untuk statistik BOS
│   ├── add_bos.php # API untuk menambah user Bos baru
│   ├── check_telepon.php # API untuk cek nomor telepon
│   ├── get_provinsi.php # API untuk data provinsi
│   ├── get_kabupaten.php # API untuk data kabupaten
│   ├── get_kecamatan.php # API untuk data kecamatan
│   └── get_kelurahan.php # API untuk data kelurahan
├── index.html             # Halaman login/register
├── mobile_dashboard.html  # Dashboard mobile
├── super_admin_dashboard.html # Dashboard Super Admin
├── input_tebakan_mobile.html # Form input tebakan
├── CHANGELOG.md           # Riwayat perubahan sistem
├── security_guidelines.md # Panduan keamanan
└── README.md              # Dokumentasi ini
```

## 👥 **Role & Permission**

```
Super Admin
├── Bos
│   ├── Admin Bos
│   └── Transporter
│       └── Penjual
│           └── Pembeli
```

### **Hak Akses:**
- **Super Admin**: Akses penuh ke semua fitur
- **Bos**: Manajemen server dan user di bawahnya
- **Admin Bos**: Administrasi untuk Bos
- **Transporter**: Pengangkut dan manajemen Penjual
- **Penjual**: Input tebakan dan layanan Pembeli
- **Pembeli**: Melakukan tebakan

## 📊 **Dashboard Statistics**

### **BOS Statistics Feature**
- ✅ **Real-time Monitoring**: Jumlah BOS aktif dan tidak aktif
- ✅ **Dynamic Updates**: Data ter-update secara otomatis dari database
- ✅ **API Integration**: Menggunakan `/api/get_bos_statistics.php`
- ✅ **Error Handling**: Fallback values jika API gagal
- ✅ **Mobile & Desktop**: Tampilan yang konsisten di semua device

### **Statistics Cards**
1. **Total Omset**: Rp 15.2M
2. **Total Transaksi**: 2,847
3. **BOS (Aktif/Total)**: 4/4 (dinamis dari database)
4. **Server Aktif**: 24

## 📱 **Mobile Optimization**

- **Touch-Friendly**: Button dan input yang mudah disentuh
- **Responsive Grid**: Layout yang menyesuaikan ukuran layar
- **Bottom Navigation**: Navigasi yang mudah di mobile
- **Floating Action Button**: Akses cepat ke fitur utama

## 👤 **Fitur Tambah User Bos**

### **Form Lengkap**
- **Informasi Pribadi**: NIK, nama lengkap, jenis kelamin, tempat/tanggal lahir, agama, status perkawinan
- **Informasi Kontak**: Email, telepon, WhatsApp, Telegram
- **Informasi Alamat**: Alamat lengkap, jenis alamat, RT/RW, kode pos
- **Informasi Akun**: Username dan password

### **Validasi Data**
- Validasi format NIK (16 digit)
- Validasi password minimal 6 karakter
- Validasi email format
- Pengecekan username dan NIK duplikat
- Validasi field wajib

### **Database Integration**
- Menggunakan struktur database yang dinormalisasi
- Insert ke tabel `orang`, `orang_identitas`, `orang_alamat`, `user`, dan `user_ownership`
- Role otomatis diset sebagai "Bos" (role_id = 2)
- Password di-hash menggunakan `password_hash()`
- Transaksi database untuk memastikan data integrity

## 🗄️ **Database Optimization Features**

### **Stored Procedures untuk Identitas:**
```sql
-- Tambah identitas baru
CALL sp_tambah_identitas_orang(1, 'Email', 'john@example.com', TRUE);
CALL sp_tambah_identitas_orang(1, 'Telepon', '08123456789', FALSE);

-- Ambil semua identitas
CALL sp_get_identitas_orang(1);
```

### **Stored Procedures untuk Alamat:**
```sql
-- Tambah alamat baru
CALL sp_tambah_alamat_orang(1, 'Rumah Tinggal', 'Jl. Sudirman No. 123', '001', '002', '10310', NULL, TRUE);
CALL sp_tambah_alamat_orang(1, 'Tempat Kerja', 'Jl. Thamrin No. 456', '003', '004', '10350', NULL, FALSE);

-- Ambil semua alamat
CALL sp_get_alamat_orang(1);
```

### **Views untuk Data Lengkap:**
```sql
-- Data orang lengkap dengan identitas dan alamat
SELECT * FROM view_orang_lengkap;
SELECT * FROM view_orang_identitas WHERE orang_id = 1;
SELECT * FROM view_orang_alamat WHERE orang_id = 1;
```

## 🔧 **Fitur Login yang Diperbaiki**

- **Form Validation**: Validasi real-time dengan Bootstrap
- **Password Strength**: Indikator kekuatan password
- **Error Handling**: Pesan error yang informatif
- **Loading States**: Indikator loading saat proses
- **Session Management**: Manajemen session yang aman

## 🎯 **Update Terbaru (v2.2)**

### **BOS Statistics Dashboard**
- ✅ **Real-time BOS Monitoring**: Card menampilkan jumlah BOS aktif/total
- ✅ **API Integration**: `/api/get_bos_statistics.php` untuk data dinamis
- ✅ **Error Handling**: Fallback values jika API gagal
- ✅ **Mobile & Desktop**: Tampilan konsisten di semua device
- ✅ **Database Query**: Query optimized untuk performa terbaik

### **Dashboard Improvements**
- ✅ **Dynamic Statistics**: Data ter-update secara otomatis
- ✅ **Bootstrap Integration**: Styling yang konsisten
- ✅ **JavaScript Optimization**: Error handling yang robust
- ✅ **API Path Fix**: Path API yang benar untuk localhost

### **Database Optimization**
- ✅ **Normalisasi Database**: Master tables untuk agama, status perkawinan, jenis identitas
- ✅ **Multiple Identitas**: Satu orang bisa punya multiple email/telepon
- ✅ **Multiple Alamat**: Satu orang bisa punya berbagai jenis alamat (rumah, kerja, kantor, dll)
- ✅ **Stored Procedures**: Fungsi untuk manajemen identitas dan alamat
- ✅ **Views**: Query yang dioptimasi untuk data lengkap
- ✅ **Index Optimization**: Performa query yang lebih baik

### **Fitur Alamat Baru**
- ✅ **Alamat Jenis**: Rumah tinggal, tempat kerja, alamat kantor, domisili, dll
- ✅ **Alamat Terstruktur**: RT/RW, kode pos, kelurahan/desa
- ✅ **Primary Address**: Alamat utama untuk setiap jenis
- ✅ **Address Verification**: Status verifikasi alamat
- ✅ **Location Integration**: Integrasi dengan data lokasi administratif

### **Performance Improvements**
- ✅ **99%+ Storage Savings**: Untuk data yang berulang
- ✅ **Data Consistency**: Tidak ada typo atau variasi
- ✅ **Easy Maintenance**: Ubah sekali, berlaku di semua tempat
- ✅ **Scalability**: Mudah tambah jenis identitas dan alamat baru

## 📊 **Data Dummy**

Sistem dilengkapi dengan data dummy lengkap untuk database optimized:

### **6 User Lengkap dengan Multiple Data:**
- **Super Admin**: Ahmad Rizki Pratama (admin/admin123)
- **Bos**: Bambang Sutejo (bos/bos123)
- **Admin Bos**: Citra Dewi (adminbos/adminbos123)
- **Transporter**: Dedi Kurniawan (transporter/transporter123)
- **Penjual**: Eka Putri (penjual/penjual123)
- **Pembeli**: Fitri Handayani (pembeli/pembeli123)

### **Multiple Identitas per User:**
```
Super Admin:
- Email: admin@luna.com (primary)
- Telepon: 08123456789 (primary)
- WhatsApp: 08123456789
- Instagram: @ahmadrizki

Bos:
- Email: bos@luna.com (primary)
- Telepon: 08187654321 (primary)
- WhatsApp: 08187654321
- Facebook: bambang.sutejo
```

### **Multiple Alamat per User:**
```
Super Admin:
- Rumah: Jl. Sudirman No. 123, Menteng, Jakarta Pusat
- Kantor: Jl. Thamrin No. 456, Jakarta Pusat

Bos:
- Rumah: Jl. Darmo No. 789, Surabaya
- Kerja: Jl. Basuki Rahmat No. 321, Surabaya
- Kantor: Jl. Pemuda No. 654, Surabaya
```

### **Server & Hadiah:**
- **Server Jakarta Pusat**: 6 tipe tebakan (2D, 3D, 4D, Colok Bebas, Colok Macau, Colok Naga)
- **Hadiah**: Persentase hadiah untuk setiap tipe tebakan
- **Deposit**: Saldo deposit untuk setiap user
- **Komisi**: Aturan komisi untuk setiap role

## 🧪 **Testing & Verification**

### **Test BOS Statistics API:**
```bash
# Test API langsung
curl http://localhost/luna/api/get_bos_statistics.php

# Expected response:
{
  "success": true,
  "data": {
    "total_bos": 4,
    "bos_aktif": 4,
    "bos_tidak_aktif": 0
  },
  "message": "BOS statistics retrieved successfully"
}
```

### **Manual Testing:**
```sql
-- Cek data BOS
SELECT 
    COUNT(*) as total_bos,
    SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) as bos_aktif,
    SUM(CASE WHEN u.is_active = 0 THEN 1 ELSE 0 END) as bos_tidak_aktif
FROM user u
WHERE u.role_id = 2;

-- Cek data master
SELECT * FROM master_agama;
SELECT * FROM master_status_perkawinan;
SELECT * FROM alamat_jenis;

-- Cek data orang dengan identitas
SELECT * FROM view_orang_lengkap;

-- Cek data alamat
SELECT * FROM view_orang_alamat WHERE orang_id = 1;
```

## 📞 **Support**

Jika mengalami masalah:
1. Pastikan XAMPP berjalan dengan benar
2. Cek koneksi database
3. Jalankan script `db/insert_dummy_optimized.sql`
4. Test BOS statistics API: `http://localhost/luna/api/get_bos_statistics.php`
5. Gunakan kredensial demo untuk testing

## 🔄 **Versi**

- **v2.2**: BOS Statistics Dashboard
  - Real-time BOS monitoring
  - API integration untuk statistik dinamis
  - Error handling dan fallback values
  - Mobile & desktop optimization
  - Database query optimization
- **v2.1**: Database Optimization & Multiple Addresses
  - Normalisasi database dengan master tables
  - Multiple identitas dan alamat
  - Stored procedures dan views
  - Performance improvements
  - Test scripts untuk verifikasi
- **v2.0**: Perbaikan CSS & Bootstrap Integration
- **v1.1**: Data Dummy & Database
- **v1.0**: Initial Release

---

**Luna System** - Modern Betting Management System 🌙✨