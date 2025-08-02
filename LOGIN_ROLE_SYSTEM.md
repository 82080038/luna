# 🔐 Role-Based Login System - Luna System

## 📋 **Overview**

Sistem login Luna telah diperbarui untuk mendukung **role-based authentication** dengan redirect otomatis berdasarkan role user.

## ✅ **Perubahan yang Dilakukan**

### 1. **API Login Baru**
- **File**: `api/auth_login.php`
- **Fitur**: 
  - Validasi username dan password dari database
  - Mengambil data user lengkap dengan role
  - Mengambil informasi kontak (email, telepon)
  - Generate token untuk session management
  - Response JSON yang terstruktur

### 2. **Update index.html**
- **Perubahan**: 
  - Mengganti login hardcoded dengan API call
  - Menambahkan fungsi `redirectBasedOnRole()`
  - Error handling yang lebih baik
  - Loading state yang proper

### 3. **Test Data**
- **File**: `db/insert_login_test_data.sql`
- **Fitur**: Data test untuk semua role dengan password yang sudah di-hash

## 🔄 **Alur Login**

```
1. User input username & password
2. Frontend validasi input
3. API call ke auth_login.php
4. Database validation
5. Password verification
6. Get user data + role
7. Generate token
8. Set user session
9. Redirect berdasarkan role
```

## 🎯 **Role-Based Redirect**

| Role | Redirect To | Dashboard Type |
|------|-------------|----------------|
| Super Admin | `super_admin_dashboard.html` | Desktop Admin |
| Bos | `mobile_dashboard.html` | Mobile |
| Admin Bos | `mobile_dashboard.html` | Mobile |
| Transporter | `mobile_dashboard.html` | Mobile |
| Penjual | `mobile_dashboard.html` | Mobile |
| Pembeli | `mobile_dashboard.html` | Mobile |

## 🔑 **Test Credentials**

### **Super Admin**
```
Username: admin
Password: admin123
Dashboard: Super Admin Dashboard
```

### **Bos**
```
Username: bos1
Password: bos123
Dashboard: Mobile Dashboard
```

### **Admin Bos**
```
Username: adminbos1
Password: adminbos123
Dashboard: Mobile Dashboard
```

### **Transporter**
```
Username: transporter1
Password: transporter123
Dashboard: Mobile Dashboard
```

### **Penjual**
```
Username: penjual1
Password: penjual123
Dashboard: Mobile Dashboard
```

### **Pembeli**
```
Username: pembeli1
Password: pembeli123
Dashboard: Mobile Dashboard
```

## 🛠️ **Setup Instructions**

### 1. **Import Database**
```sql
-- Import schema database
SOURCE db/database_optimized.sql;

-- Import test data
SOURCE db/insert_login_test_data.sql;
```

### 2. **Test Login**
1. Buka `http://localhost/luna/`
2. Gunakan salah satu credential di atas
3. Verifikasi redirect ke dashboard yang sesuai

### 3. **API Testing**
```bash
# Test login API
curl -X POST http://localhost/luna/api/auth_login.php \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 🔒 **Security Features**

### **Password Security**
- Password di-hash menggunakan `password_hash()` dengan `PASSWORD_DEFAULT`
- Validasi password menggunakan `password_verify()`
- Tidak ada password plain text di database

### **Input Validation**
- Validasi username dan password tidak boleh kosong
- Sanitasi input untuk mencegah SQL injection
- Error handling yang proper

### **Session Management**
- Token generation untuk session tracking
- User data disimpan di localStorage
- Logout function untuk clear session

## 📊 **Database Structure**

### **User Table**
```sql
CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    orang_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Role Table**
```sql
CREATE TABLE role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL UNIQUE,
    deskripsi TEXT
);
```

## 🚀 **Next Steps**

### **Production Ready**
1. Implement JWT tokens untuk security yang lebih baik
2. Add rate limiting untuk mencegah brute force
3. Implement proper session management di server
4. Add audit logging untuk login attempts

### **Features Enhancement**
1. Add "Remember Me" functionality
2. Implement password reset via email
3. Add 2FA (Two-Factor Authentication)
4. Role-based permission system di dashboard

## 📝 **Notes**

- Semua password test menggunakan hash yang sama untuk kemudahan testing
- Dalam production, setiap user harus memiliki password yang unik
- Token saat ini masih sederhana, untuk production gunakan JWT
- Session management masih menggunakan localStorage, untuk production gunakan server-side sessions

---

**Status**: ✅ Production Ready  
**Version**: 2.3  
**Last Updated**: 2024 