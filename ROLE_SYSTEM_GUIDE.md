# Sistem Role dan Login - Panduan Lengkap

## Overview
Aplikasi Luna menggunakan sistem role-based access control (RBAC) untuk mengatur akses user ke berbagai dashboard dan fitur berdasarkan peran mereka dalam sistem.

## Struktur Role

### 1. **Super Admin**
- **Dashboard**: `super_admin_dashboard.html`
- **Akses**: Kontrol penuh atas seluruh sistem
- **Fitur**: Manajemen user, monitoring sistem, konfigurasi global

### 2. **Bos**
- **Dashboard**: `bos_dashboard.html`
- **Akses**: Manajemen level Bos
- **Fitur**: Monitoring server, manajemen admin bos, laporan keuangan

### 3. **Admin Bos**
- **Dashboard**: `mobile_dashboard.html`
- **Akses**: Manajemen level operasional
- **Fitur**: Input tebakan, monitoring transaksi, laporan harian

### 4. **Transporter**
- **Dashboard**: `mobile_dashboard.html`
- **Akses**: Operasional transportasi
- **Fitur**: Input tebakan, monitoring pengiriman

### 5. **Penjual**
- **Dashboard**: `mobile_dashboard.html`
- **Akses**: Operasional penjualan
- **Fitur**: Input tebakan, laporan penjualan

### 6. **Pembeli**
- **Dashboard**: `mobile_dashboard.html`
- **Akses**: Konsumen
- **Fitur**: Melihat tebakan, riwayat transaksi

## Alur Login dan Redirect

### 1. **Proses Login**
```javascript
// User memasukkan username dan password
// Sistem memanggil API /api/login.php
// API memverifikasi credentials dan mengembalikan data user
// Sistem menyimpan data user di localStorage
// Sistem redirect berdasarkan role user
```

### 2. **Role-Based Redirect**
```javascript
function redirectBasedOnRole(role) {
    switch(role) {
        case 'Super Admin':
            redirect('super_admin_dashboard.html');
            break;
        case 'Bos':
            redirect('bos_dashboard.html');
            break;
        case 'Admin Bos':
        case 'Transporter':
        case 'Penjual':
        case 'Pembeli':
            redirect('mobile_dashboard.html');
            break;
        default:
            redirect('mobile_dashboard.html');
    }
}
```

### 3. **Access Control**
Setiap halaman memiliki pengecekan role:
```javascript
// Contoh untuk Super Admin Dashboard
if (!LunaAuth.checkRoleAccess(['Super Admin'])) {
    return; // Redirect ke halaman yang sesuai
}
```

## Implementasi Teknis

### 1. **API Login (`/api/login.php`)**
- Validasi input username dan password
- Pengecekan rate limiting (5 percobaan per 15 menit)
- Verifikasi password menggunakan `password_verify()`
- Pengecekan status akun (aktif/locked)
- Generate session token
- Return data user dengan role information

### 2. **Frontend Authentication (`js/app.js`)**
- `LunaAuth.login()`: Handle login process
- `LunaAuth.checkAuth()`: Cek status login
- `LunaAuth.checkRoleAccess()`: Cek akses berdasarkan role
- `LunaAuth.redirectBasedOnRole()`: Redirect berdasarkan role

### 3. **User Data Storage**
```javascript
// Data user disimpan di localStorage
{
    id: user_id,
    username: username,
    role: role_name,
    name: full_name,
    last_login: timestamp,
    session_token: token,
    expires: expiration_time
}
```

## Keamanan

### 1. **Password Security**
- Password di-hash menggunakan `PASSWORD_ARGON2ID`
- Auto rehash jika diperlukan
- Rate limiting untuk mencegah brute force

### 2. **Session Management**
- Session token dengan expiration (4 jam)
- Session disimpan di database
- Auto logout jika session expired

### 3. **Access Control**
- Role-based access control di setiap halaman
- Redirect otomatis jika tidak memiliki akses
- Validasi role di frontend dan backend

## Database Schema

### Tabel `user`
```sql
CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    failed_login_attempts INT DEFAULT 0,
    locked_until DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabel `role`
```sql
CREATE TABLE role (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama_role VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabel `user_sessions`
```sql
CREATE TABLE user_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Testing

### 1. **Test Login dengan Role Berbeda**
```bash
# Super Admin
username: admin
password: admin123

# Bos
username: bos1
password: password123

# Admin Bos
username: adminbos1
password: password123
```

### 2. **Test Access Control**
- Coba akses `super_admin_dashboard.html` dengan role Bos
- Coba akses `bos_dashboard.html` dengan role Admin Bos
- Verifikasi redirect otomatis ke dashboard yang sesuai

## Troubleshooting

### 1. **Login Gagal**
- Cek koneksi database
- Cek credentials user di database
- Cek log error di console browser

### 2. **Redirect Tidak Berfungsi**
- Cek role user di database
- Cek fungsi `redirectBasedOnRole()`
- Cek localStorage untuk data user

### 3. **Access Denied**
- Cek role user
- Cek fungsi `checkRoleAccess()`
- Verifikasi allowed roles di setiap halaman

## Maintenance

### 1. **Regular Tasks**
- Monitor failed login attempts
- Clean expired sessions
- Update password hashes jika diperlukan

### 2. **Security Updates**
- Update password hashing algorithm
- Implement additional security measures
- Monitor for suspicious activities

## Kesimpulan

Sistem role yang diimplementasikan memberikan:
- **Keamanan**: Access control berdasarkan role
- **Fleksibilitas**: Mudah menambah/mengubah role
- **User Experience**: Redirect otomatis ke dashboard yang sesuai
- **Maintainability**: Kode yang terstruktur dan mudah dipahami

Sistem ini siap untuk digunakan dan dapat dikembangkan lebih lanjut sesuai kebutuhan bisnis. 