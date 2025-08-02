# 🌙 Luna - Sistem Manajemen Multi-Role

Sistem manajemen berbasis web dengan hierarki user yang kompleks, mendukung Super Admin, Bos, Admin Bos, Transporter, Penjual, dan Pembeli.

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Hierarki User](#-hierarki-user)
- [Teknologi](#-teknologi)
- [Instalasi](#-instalasi)
- [Struktur Database](#-struktur-database)
- [Struktur Kode](#-struktur-kode)
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

### 🏗️ Arsitektur Modular
- **JavaScript Modular**: Fungsi terpisah berdasarkan role
- **CSS Modular**: Style terpisah berdasarkan role
- **Reusable Components**: Komponen umum yang dapat digunakan ulang
- **Event-Driven**: Event delegation untuk performa optimal

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
- **JavaScript (ES6+)**: Client-side logic dengan modular architecture
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

## 📁 Struktur Kode

### JavaScript Architecture (Modular)

```
js/
├── core.js              # Fungsi umum (API calls, utilities, UI)
├── super-admin.js       # Fungsi khusus Super Admin
├── bos.js              # Fungsi khusus BOS
├── admin-bos.js        # Fungsi khusus Admin BOS (future)
├── transporter.js      # Fungsi khusus Transporter (future)
├── penjual.js          # Fungsi khusus Penjual (future)
└── pembeli.js          # Fungsi khusus Pembeli (future)
```

#### Core Functions (`js/core.js`)
- **LunaCore**: API calls, user data, address functions, utilities
- **LunaUI**: Modal, table, form, dropdown functions

#### Role-Specific Functions
- **LunaSuperAdmin**: Dashboard, user management, BOS management
- **LunaBos**: Dashboard, Admin BOS/Transporter/Penjual management
- **LunaAdminBos**: Dashboard, user management (future)
- **LunaTransporter**: Dashboard, delivery management (future)
- **LunaPenjual**: Dashboard, product management (future)
- **LunaPembeli**: Dashboard, order management (future)

### CSS Architecture (Modular)

```
css/
├── core.css            # Style umum (layout, components, utilities)
├── super-admin.css     # Style khusus Super Admin
├── bos.css            # Style khusus BOS (future)
├── admin-bos.css      # Style khusus Admin BOS (future)
├── transporter.css    # Style khusus Transporter (future)
├── penjual.css        # Style khusus Penjual (future)
└── pembeli.css        # Style khusus Pembeli (future)
```

#### Core Styles (`css/core.css`)
- Global styles, header, cards, forms, buttons, tables
- Responsive design, animations, utilities

#### Role-Specific Styles
- Color schemes, custom components, role-specific layouts
- Responsive adjustments, animations

### File Structure

```
luna/
├── api/                    # Backend API endpoints
├── css/                    # Stylesheets (modular)
│   ├── core.css
│   ├── super-admin.css
│   └── [role-specific].css
├── js/                     # JavaScript modules
│   ├── core.js
│   ├── super-admin.js
│   └── [role-specific].js
├── dashboards/             # Role-specific dashboards
│   ├── super_admin/
│   ├── bos/
│   ├── admin_bos/
│   ├── transporter/
│   ├── penjual/
│   └── pembeli/
├── db/                     # Database schemas
├── index.html              # Login page
└── README.md
```

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
- **Scripts**: `core.js`, `super-admin.js`
- **Styles**: `core.css`, `super-admin.css`
- **Fitur**:
  - Statistik BOS (Aktif/Total)
  - Manajemen User (semua role)
  - Tambah BOS
  - Filter dan search user

### Bos Dashboard
- **Path**: `/dashboards/bos/index.html`
- **Scripts**: `core.js`, `bos.js`
- **Styles**: `core.css`, `bos.css` (future)
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

#### 2. JavaScript Module Error
```
Uncaught ReferenceError: LunaCore is not defined
```
**Solution**: Pastikan `core.js` dimuat sebelum role-specific scripts

#### 3. CSS Not Loading
```
GET http://localhost/luna/css/core.css 404 (Not Found)
```
**Solution**: Periksa struktur folder dan path relatif

#### 4. API Error 500
```
POST /api/auth_login.php 500 (Internal Server Error)
```
**Solution**: Periksa error log PHP dan konfigurasi database

#### 5. Login Failed
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

### Browser Console Debugging

Untuk debugging frontend:
```javascript
// Cek apakah modules ter-load
console.log('LunaCore:', typeof LunaCore);
console.log('LunaSuperAdmin:', typeof LunaSuperAdmin);

// Cek role detection
console.log('Current role:', document.querySelector('[data-role]')?.getAttribute('data-role'));
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

## 🚀 Development Guidelines

### Adding New Role

1. **Create JavaScript Module**
   ```javascript
   // js/new-role.js
   const LunaNewRole = {
       init: function() {
           this.loadDashboard();
           this.bindEvents();
       },
       // ... role-specific functions
   };
   ```

2. **Create CSS Module**
   ```css
   /* css/new-role.css */
   .new-role .dashboard-header {
       background: linear-gradient(135deg, #your-color 0%, #your-color2 100%);
   }
   ```

3. **Update HTML**
   ```html
   <body data-role="new-role">
   <div class="dashboard-container new-role">
   <script src="../../js/core.js"></script>
   <script src="../../js/new-role.js"></script>
   <link href="../../css/core.css" rel="stylesheet">
   <link href="../../css/new-role.css" rel="stylesheet">
   ```

### Code Organization

- **Separation of Concerns**: Fungsi umum di `core.js`, role-specific di file terpisah
- **Event Delegation**: Gunakan `data-action` attributes untuk event handling
- **Modular CSS**: Style umum di `core.css`, role-specific di file terpisah
- **Consistent Naming**: Gunakan prefix `Luna` untuk semua modules

## 📝 Changelog

### v2.1.0 - Modular Architecture
- ✅ Refactored JavaScript into modular structure
- ✅ Separated CSS by role
- ✅ Improved code organization and maintainability
- ✅ Added event delegation for better performance
- ✅ Enhanced role-based styling

### v2.0.0 - Multi-Role System
- ✅ Implemented complete multi-role hierarchy
- ✅ Added BOS statistics and management
- ✅ Enhanced user management features
- ✅ Improved address system

Lihat [CHANGELOG.md](CHANGELOG.md) untuk detail perubahan versi lengkap.

## 🔐 Security Guidelines

Lihat [security_guidelines.md](security_guidelines.md) untuk panduan keamanan lengkap.

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Follow modular architecture guidelines
4. Commit changes
5. Push to branch
6. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

Untuk bantuan dan dukungan:
- Buat issue di repository
- Hubungi tim development
- Dokumentasi lengkap tersedia di folder docs/

---

**Luna v2.1** - Sistem Manajemen Multi-Role dengan Arsitektur Modular 🌙