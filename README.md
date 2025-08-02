# 🌙 Luna - Sistem Manajemen Multi-Role

Sistem manajemen berbasis web dengan hierarki user yang kompleks, mendukung Super Admin, Bos, Admin Bos, Transporter, Penjual, dan Pembeli.

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Hierarki User](#-hierarki-user)
- [Teknologi](#-teknologi)
- [Instalasi](#-instalasi)
- [Struktur Database](#-struktur-database)
- [API Endpoints](#-api-endpoints)
- [Dashboard](#-dashboard)
- [Sistem Keamanan](#-sistem-keamanan)
- [Alur Sistem](#-alur-sistem)
- [Cara Penggunaan](#-cara-penggunaan)
- [Troubleshooting](#-troubleshooting)

## ✨ Fitur Utama

### 🔐 Sistem Autentikasi
- **Login Multi-Role**: Mendukung 6 role berbeda
- **Login Pertama Kali**: Deteksi dan ganti password wajib
- **Kelengkapan Data**: Validasi kelengkapan profil user
- **Session Management**: Token-based authentication

### 👥 Manajemen User
- **Hierarki Mutlak**: Super Admin > Bos > Admin Bos > Transporter > Penjual > Pembeli
- **Multi-Bos**: Mendukung multiple Bos per wilayah
- **Status Management**: Aktif/Nonaktif user
- **Data Validation**: Validasi data pribadi, kontak, dan alamat

### 📊 Dashboard
- **Role-Based Dashboard**: Dashboard khusus untuk setiap role
- **Statistics Real-time**: Statistik user aktif/total
- **User Management**: Manajemen user dengan filter dan search
- **Quick Actions**: Aksi cepat untuk setiap role

### 🗺️ Sistem Alamat
- **Cascading Dropdown**: Provinsi → Kabupaten → Kecamatan → Desa
- **Database Terpisah**: Sistem alamat menggunakan database terpisah
- **Address Validation**: Validasi alamat lengkap

## 👑 Hierarki User

```
Super Admin
├── Bos (Multiple)
│   ├── Admin Bos
│   ├── Transporter
│   └── Penjual
│       └── Pembeli
```

### 🔑 Permissions

| Role | Add Bos | Add Admin Bos | Add Transporter | Add Penjual | Add Pembeli | Manage Users |
|------|---------|---------------|-----------------|-------------|-------------|--------------|
| **Super Admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Bos** | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Admin Bos** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔄 |
| **Transporter** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Penjual** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Pembeli** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

*🔄 = Dengan izin dari Bos*

## 🛠️ Teknologi

### Backend
- **PHP 8.0+**: Server-side scripting
- **MySQL 8.0+**: Database management
- **PDO**: Database abstraction layer
- **JSON API**: RESTful API endpoints

### Frontend
- **HTML5**: Semantic markup
- **CSS3**: Styling dan responsive design
- **JavaScript (ES6+)**: Client-side logic
- **Bootstrap 5.1.3**: UI framework
- **Font Awesome 6.0.0**: Icons

### Database
- **sistem_angka**: Database utama (user, role, data pribadi)
- **sistem_alamat**: Database alamat (provinsi, kabupaten, kecamatan, desa)

## 🚀 Instalasi

### Prerequisites
- XAMPP/WAMP/LAMP server
- PHP 8.0 atau lebih tinggi
- MySQL 8.0 atau lebih tinggi
- Web browser modern

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone [repository-url]
   cd luna
   ```

2. **Setup Database**
   ```bash
   # Import database utama
   mysql -u root -p < db/sistem_angka.sql
   
   # Import database alamat
   mysql -u root -p < db/sistem_alamat.sql
   
   # Setup constraints (opsional)
   mysql -u root -p < safe_constraint_setup.sql
   ```

3. **Konfigurasi Database**
   - Edit `api/config.php`
   - Sesuaikan host, username, password database

4. **Akses Aplikasi**
   ```
   http://localhost/luna/
   ```

### Default Credentials

#### Super Admin
- **Username**: `admin`
- **Password**: `admin123`

#### User BOS (untuk testing)
- **Username**: `081910457868`
- **Password**: `081910457868`
- **Username**: `08123456788`
- **Password**: `08123456788`
- **Username**: `081265511982`
- **Password**: `081265511982`

## 🗄️ Struktur Database

### Database: sistem_angka

#### Tabel Utama
- **user**: Data user dan autentikasi
- **role**: Definisi role dan permissions
- **orang**: Data pribadi user
- **orang_identitas**: Data kontak (email, telepon, NIK, WhatsApp)
- **orang_alamat**: Data alamat user
- **user_ownership**: Relasi kepemilikan user

#### Tabel Master
- **master_jenis_identitas**: Jenis identitas (Email, Telepon, NIK, WhatsApp)

### Database: sistem_alamat

#### Tabel Alamat
- **cbo_propinsi**: Data provinsi Indonesia
- **cbo_kab_kota**: Data kabupaten/kota
- **cbo_kecamatan**: Data kecamatan
- **cbo_desa**: Data desa/kelurahan

## 🔌 API Endpoints

### Authentication
- `POST /api/auth_login.php` - Login user
- `POST /api/change_password.php` - Ganti password
- `POST /api/check_first_login.php` - Cek login pertama kali

### User Management
- `POST /api/add_bos.php` - Tambah user Bos (Super Admin only)
- `POST /api/add_admin_bos.php` - Tambah Admin Bos (Bos only)
- `POST /api/add_transporter.php` - Tambah Transporter (Bos only)
- `POST /api/add_penjual.php` - Tambah Penjual (Bos only)
- `GET /api/get_all_users.php` - Ambil semua user
- `POST /api/toggle_user_status.php` - Toggle status user
- `POST /api/delete_user.php` - Hapus user

### Data Management
- `POST /api/check_user_completeness.php` - Cek kelengkapan data user
- `GET /api/get_bos_statistics.php` - Statistik user per role
- `GET /api/get_bos_users.php` - User yang dapat dikelola Bos

### Address Management
- `GET /api/get_provinsi.php` - Daftar provinsi
- `GET /api/get_kabupaten.php` - Daftar kabupaten
- `GET /api/get_kecamatan.php` - Daftar kecamatan
- `GET /api/get_kelurahan.php` - Daftar desa
- `POST /api/validate_address.php` - Validasi alamat
- `GET /api/get_user_address.php` - Alamat user

### Validation
- `POST /api/check_telepon.php` - Cek duplikasi telepon

## 📊 Dashboard

### Super Admin Dashboard
- **Path**: `/dashboards/super_admin/index.html`
- **Fitur**:
  - Statistik BOS (Aktif/Total)
  - Manajemen User (semua role)
  - Tambah BOS
  - Filter dan search user

### Bos Dashboard
- **Path**: `/dashboards/bos/index.html`
- **Fitur**:
  - Statistik Admin Bos, Transporter, Penjual, Pembeli
  - Manajemen User (Admin Bos, Transporter, Penjual, Pembeli)
  - Tambah Admin Bos, Transporter, Penjual
  - Penugasan Transporter (placeholder)

### Dashboard Lainnya
- **Admin Bos**: `/dashboards/admin_bos/index.html`
- **Transporter**: `/dashboards/transporter/index.html`
- **Penjual**: `/dashboards/penjual/index.html`
- **Pembeli**: `/dashboards/pembeli/index.html`

## 🔒 Sistem Keamanan

### Password Security
- **Hashing**: Menggunakan `PASSWORD_DEFAULT` (bcrypt)
- **First Login**: Wajib ganti password saat login pertama
- **Validation**: Minimal 6 karakter, konfirmasi password

### Data Validation
- **Input Sanitization**: Validasi input user
- **SQL Injection Protection**: Menggunakan prepared statements
- **XSS Protection**: Output encoding

### Access Control
- **Role-Based Access**: Setiap role memiliki permission berbeda
- **Session Management**: Token-based authentication
- **Database Constraints**: Foreign key constraints

## 🔄 Alur Sistem

### 1. Login Pertama Kali
```
User Login → Deteksi First Login → Ganti Password → Cek Kelengkapan Data → Dashboard
```

### 2. Login Normal
```
User Login → Cek Kelengkapan Data → Dashboard
```

### 3. Manajemen User
```
Super Admin → Tambah BOS → BOS → Tambah Admin Bos/Transporter/Penjual → Penjual → Tambah Pembeli
```

### 4. Kelengkapan Data
```
Cek Data → < 90% → Halaman Kelengkapan → Edit Data → Dashboard
Cek Data → ≥ 90% → Dashboard Langsung
```

## 📖 Cara Penggunaan

### Untuk Super Admin

1. **Login dengan credentials default**
   ```
   Username: admin
   Password: admin123
   ```

2. **Ganti password saat login pertama kali**

3. **Tambah BOS**
   - Klik tombol "+" di card "BOS (Aktif/Total)"
   - Isi form data BOS
   - Password default: username (nomor telepon)

4. **Manajemen User**
   - Klik "Manajemen User"
   - Filter berdasarkan role dan status
   - Search berdasarkan nama atau telepon

### Untuk BOS

1. **Login dengan credentials yang diberikan Super Admin**
   ```
   Username: [nomor telepon]
   Password: [nomor telepon] (pertama kali)
   ```

2. **Ganti password dan lengkapi data profil**

3. **Tambah Admin Bos, Transporter, Penjual**
   - Klik tombol "+" di card masing-masing
   - Isi form data lengkap

4. **Manajemen User**
   - Lihat semua user yang dapat dikelola
   - Toggle status aktif/nonaktif
   - Hapus user jika diperlukan

### Kelengkapan Data

#### Data Wajib
- **Pribadi**: Nama depan, jenis kelamin, tanggal lahir, tempat lahir
- **Kontak**: Email, telepon, NIK, WhatsApp
- **Alamat**: Alamat lengkap, provinsi, kabupaten, kecamatan, desa

#### Data Opsional
- **Pribadi**: Nama tengah, nama belakang

## 🔧 Troubleshooting

### Common Issues

#### 1. Database Connection Error
```
Error: SQLSTATE[HY000] [1045] Access denied for user
```
**Solution**: Periksa konfigurasi database di `api/config.php`

#### 2. File Not Found Error
```
GET http://localhost/luna/css/styles.css 404 (Not Found)
```
**Solution**: Periksa struktur folder dan path relatif

#### 3. API Error 500
```
POST /api/auth_login.php 500 (Internal Server Error)
```
**Solution**: Periksa error log PHP dan konfigurasi database

#### 4. Login Failed
```
Username atau password salah
```
**Solution**: 
- Periksa credentials yang digunakan
- Pastikan user aktif di database
- Reset password jika diperlukan

### Debug Mode

Untuk debugging, tambahkan di `api/config.php`:
```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

### Database Reset

Jika perlu reset database:
```sql
-- Backup data penting terlebih dahulu
-- Drop dan recreate database
DROP DATABASE sistem_angka;
CREATE DATABASE sistem_angka;
-- Import ulang dari file SQL
```

## 📝 Changelog

Lihat [CHANGELOG.md](CHANGELOG.md) untuk detail perubahan versi.

## 🔐 Security Guidelines

Lihat [security_guidelines.md](security_guidelines.md) untuk panduan keamanan lengkap.

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

Untuk bantuan dan dukungan:
- Buat issue di repository
- Hubungi tim development
- Dokumentasi lengkap tersedia di folder docs/

---

**Luna v2.0** - Sistem Manajemen Multi-Role yang Powerful dan Aman 🌙