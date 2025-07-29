# 🌙 Luna - Sistem Tebakan Angka Mobile-First

## 📱 **Deskripsi Sistem**

Luna adalah sistem manajemen tebakan angka yang dioptimalkan untuk penggunaan mobile dengan fokus pada angka dan transaksi keuangan. Sistem ini dirancang dengan arsitektur multi-level user hierarchy dan keamanan tingkat tinggi.

## 🎯 **Fitur Utama**

### **📊 Dashboard Mobile**
- **Statistik Real-time** - Omset, transaksi, komisi, target
- **Quick Actions** - Input tebakan, cek saldo, laporan
- **Recent Transactions** - Riwayat transaksi terbaru
- **Floating Action Button** - Akses cepat untuk input tebakan

### **🖥️ Super Admin Dashboard**
- **System Overview** - Total users, servers, revenue, growth rate
- **System Alerts** - Maintenance alerts, pending registrations, failed transactions
- **Recent Transactions** - All system transactions with detailed info
- **Server Status** - Real-time server monitoring and management
- **Quick Actions** - Manage users, servers, reports, system settings
- **Recent Users** - Latest user registrations and status
- **System Info** - Database status, backup info, uptime, active sessions

### **🎲 Input Tebakan Mobile**
- **Number-Focused Design** - Input angka yang besar dan mudah
- **Quick Numbers** - Tombol cepat untuk angka populer (0000, 1111, dll)
- **Collapsible Sections** - 4D, 3D, 2D, CE, CK, CB
- **Real-time Calculation** - Kalkulasi harga otomatis
- **Validation** - Validasi format dan batas angka

### **👥 Hierarki User**
```
Super Admin (Desktop)
├── Bos (Mobile + Desktop)
│   ├── Admin Bos (Mobile)
│   └── Transporter (Mobile)
│       └── Penjual (Mobile)
│           └── Pembeli (Mobile)
```

### **💰 Sistem Keuangan**
- **Deposit Management** - Topup, cek saldo, transfer
- **Commission System** - Komisi otomatis berdasarkan role
- **Transaction History** - Riwayat lengkap semua transaksi
- **Financial Reports** - Laporan keuangan real-time

## 🛡️ **Keamanan & Best Practices**

### **Authentication & Authorization**
- **Multi-Factor Authentication (MFA)** untuk role penting
- **Session Management** dengan timeout berdasarkan role
- **Role-Based Access Control (RBAC)** yang ketat
- **Password Policy** yang kuat

### **Data Protection**
- **Input Validation** ketat untuk semua input angka
- **SQL Injection Prevention** dengan parameterized queries
- **XSS Prevention** dengan sanitasi output
- **CSRF Protection** untuk semua form

### **Financial Security**
- **Transaction Validation** dengan multiple checks
- **Audit Trail** lengkap untuk semua transaksi
- **Suspicious Activity Detection** otomatis
- **Daily Limits** berdasarkan role user

## 📱 **UI/UX Mobile-First**

### **Design Principles**
- **Touch-Friendly** - Minimal 44px touch target
- **Large Numbers** - Font size 2rem untuk angka
- **Quick Actions** - Tombol akses cepat
- **Responsive** - Optimized untuk semua ukuran layar

### **User Experience**
- **Loading States** - Feedback visual untuk operasi
- **Error Handling** - Pesan error yang user-friendly
- **Confirmation Dialogs** - Konfirmasi untuk aksi penting
- **Offline Support** - Cache data untuk koneksi lambat

### **📱 Responsive Design dengan Bootstrap Container**

Semua halaman Luna menggunakan **Bootstrap 5.3.0** dengan container system yang responsif:

#### **🖥️ Super Admin Dashboard:**
- **Container System** - `.container` untuk layout responsif
- **Grid System** - `.row` dan `.col-*` untuk responsive columns
- **Breakpoints** - `col-12 col-sm-6 col-lg-3` untuk statistik cards
- **Main Content** - `col-12 col-lg-8` untuk main section, `col-12 col-lg-4` untuk sidebar

#### **📱 Mobile Dashboard:**
- **Container System** - `.container` untuk semua content
- **Grid Layout** - `.row g-3` untuk spacing yang konsisten
- **Responsive Stats** - `col-6` untuk 2x2 grid stats
- **Action Buttons** - `col-6` untuk 2x2 grid buttons
- **Mobile Optimized** - Floating button dan bottom navigation

#### **🎲 Input Tebakan Mobile:**
- **Container System** - `.container` untuk form content
- **Responsive Grid** - `col-6` untuk action buttons
- **Sticky Elements** - Header dan action buttons tetap di posisi
- **Mobile First** - Optimized untuk touch interface

#### **🔐 Login/Register Page:**
- **Centered Layout** - `.justify-content-center` untuk centering
- **Responsive Card** - `col-12 col-sm-8 col-md-6 col-lg-4` untuk card sizing
- **Form Layout** - Bootstrap form classes untuk consistency
- **Mobile Friendly** - Responsive padding dan spacing

#### **📐 Bootstrap Features yang Digunakan:**
- **Grid System** - Responsive breakpoints (xs, sm, md, lg, xl)
- **Utility Classes** - Spacing, flexbox, text, background, borders
- **Components** - Buttons, forms, cards, tables
- **CDN Links** - Bootstrap 5.3.0 via CDN untuk performance

#### **📱 Responsive Breakpoints:**
- **Mobile (<576px)** - Single column layout, full width cards
- **Tablet (576px - 991px)** - 2-column grid, sidebar stacks
- **Desktop (≥992px)** - Multi-column layouts, sidebar alongside main

## 🗄️ **Database Structure**

### **Core Tables**
- `user` - User management dengan role hierarchy
- `orang` - Data personal user
- `role` - Role dan permission
- `server` - Server management
- `sesi_server` - Session management
- `tipe_tebakan` - Jenis tebakan (4D, 3D, 2D, dll)
- `hadiah` - Konfigurasi hadiah
- `transaksi_tebakan` - Transaksi tebakan
- `detail_kemenangan` - Detail kemenangan
- `hasil_tebakan` - Hasil tebakan per sesi
- `deposit_member` - Saldo deposit user
- `transaksi_pembayaran` - Transaksi keuangan
- `metode_pembayaran` - Metode pembayaran
- `user_ownership` - Relasi ownership

### **Views & Reports**
- `view_penyerahan_dana` - Laporan penyerahan dana
- `view_arus_kas` - Laporan arus kas
- `view_laporan_tebakan` - Laporan tebakan
- `view_laporan_kemenangan` - Laporan kemenangan

### **Stored Procedures**
- `input_tebakan` - Input tebakan dengan validasi
- `proses_kalkulasi_kemenangan` - Kalkulasi kemenangan
- `topup_deposit` - Topup deposit
- `cek_saldo_deposit` - Cek saldo deposit
- Helper procedures untuk 4D, 3D, 2D, CE, CK, CB

## 📁 **Struktur File (Optimized)**

```
luna/
├── index.html                     # Halaman login/register
├── super_admin_dashboard.html     # Dashboard Super Admin
├── mobile_dashboard.html          # Dashboard mobile
├── input_tebakan_mobile.html      # Form input tebakan
├── database_complete.sql          # Database lengkap + stored procedures
├── security_guidelines.md         # Panduan keamanan
├── README.md                      # Dokumentasi ini
├── css/
│   └── styles.css                 # CSS utama (gabungan semua styling)
└── js/
    └── app.js                     # JavaScript utama (gabungan semua logic)
```

### **File yang Dihapus (Sudah Digabung):**
- ❌ `stored_procedures.sql` → ✅ Digabung ke `database_complete.sql`
- ❌ `database_procedures.sql` → ✅ Digabung ke `database_complete.sql`
- ❌ `js/script.js` → ✅ Digabung ke `js/app.js`
- ❌ `js/validation.js` → ✅ Digabung ke `js/app.js`
- ❌ `css/style.css` → ✅ Digabung ke `css/styles.css`
- ❌ `README_awal.md` → ✅ Digabung ke `README.md`

## 🚀 **Panduan Instalasi**

### **1. Setup Database**
```sql
-- Jalankan di phpMyAdmin
-- Copy-paste seluruh isi database_complete.sql
-- Centang "Perbolehkan cek foreign key"
-- Klik Go
```

### **2. Setup Web Server**
```bash
# Pastikan XAMPP/WAMP sudah running
# Copy semua file ke folder htdocs
# Akses via browser: http://localhost/luna/
```

## 🔧 **Teknologi yang Digunakan**

### **Frontend**
- **HTML5** - Semantic markup
- **CSS3** - Modern styling dengan CSS Grid & Flexbox
- **Bootstrap 5** - Responsive framework
- **JavaScript ES6+** - Modern JavaScript
- **jQuery** - DOM manipulation dan AJAX
- **Font Awesome** - Icon library

### **Backend**
- **PHP** - Server-side scripting
- **MySQL/MariaDB** - Database management
- **Apache** - Web server

### **Security**
- **HTTPS** - Secure communication
- **Password Hashing** - bcrypt/Argon2
- **Session Management** - Secure session handling
- **Input Validation** - Client & server-side validation

## 📊 **Data Format**

### **Tebakan JSON Format**
```json
{
  "4D": [
    {"angka": "1234", "jumlah": 1},
    {"angka": "5678", "jumlah": 2}
  ],
  "3D": [
    {"angka": "123", "jumlah": 1}
  ],
  "2D": [
    {"angka": "12", "jumlah": 1}
  ],
  "CE": [
    {"angka": "1", "jumlah": 1}
  ],
  "CK": [
    {"angka": "2", "jumlah": 1}
  ],
  "CB": [
    {"angka": "3", "jumlah": 1}
  ]
}
```

### **Hasil Tebakan JSON Format**
```json
{
  "4D": "1234",
  "3D": "234",
  "2D": "34",
  "CE": "4",
  "CK": "5",
  "CB": "6"
}
```

## 👥 **User Hierarchy & Permissions**

### **Super Admin**
- Akses penuh ke semua fitur
- Manajemen user dan role
- Konfigurasi sistem
- Backup dan restore

### **Bos**
- Manajemen server dan sesi
- View laporan keuangan
- Manajemen user di bawahnya
- Konfigurasi hadiah

### **Admin Bos**
- View laporan
- Manajemen user di bawahnya
- Monitoring transaksi

### **Transporter**
- View transaksi
- Update status transaksi
- Manajemen penjual

### **Penjual**
- Input tebakan
- View saldo dan komisi
- Riwayat transaksi

### **Pembeli**
- Input tebakan
- View riwayat
- Cek saldo deposit

## 💰 **Sistem Keuangan**

### **Deposit System**
- Topup deposit via berbagai metode
- Transfer antar user
- Riwayat transaksi lengkap
- Notifikasi real-time

### **Commission System**
- Komisi otomatis berdasarkan role
- Perhitungan real-time
- Laporan komisi detail
- Payout management

### **Financial Reports**
- Arus kas harian/bulanan
- Laporan penyerahan dana
- Analisis profitabilitas
- Export ke Excel/PDF

## 🔍 **Monitoring & Analytics**

### **Error Tracking**
- Log error otomatis
- Error notification
- Performance monitoring
- User behavior tracking

### **User Analytics**
- User activity tracking
- Feature usage analytics
- Performance metrics
- Conversion tracking

## 🔄 **Backup & Recovery**

### **Automated Backup**
- Daily database backup
- File backup otomatis
- Cloud backup integration
- 30-day retention policy

### **Disaster Recovery**
- Automated recovery procedures
- Data integrity checks
- Rollback capabilities
- Business continuity plan

## 📋 **Compliance & Legal**

### **Data Privacy**
- GDPR compliance
- Data encryption
- User consent management
- Data retention policies

### **Audit Requirements**
- Complete audit trail
- Financial audit support
- Compliance reporting
- Legal documentation

## 🎯 **Roadmap Development**

### **Phase 1: Core Features** ✅
- [x] Database structure
- [x] Basic authentication
- [x] Mobile dashboard
- [x] Input tebakan form
- [x] Basic security
- [x] File optimization

### **Phase 2: Advanced Features** 🚧
- [ ] Multi-factor authentication
- [ ] Advanced reporting
- [ ] Real-time notifications
- [ ] API integration
- [ ] Performance optimization

### **Phase 3: Enterprise Features** 📋
- [ ] Advanced analytics
- [ ] Multi-tenant support
- [ ] Advanced security
- [ ] Compliance features
- [ ] Mobile app development

### **Phase 4: Scale & Optimize** 📋
- [ ] Microservices architecture
- [ ] Cloud deployment
- [ ] Advanced monitoring
- [ ] AI/ML integration
- [ ] Internationalization

## 🤝 **Support & Maintenance**

### **Technical Support**
- Documentation updates
- Bug fixes
- Feature requests
- Performance optimization

### **Training & Onboarding**
- User training materials
- Admin documentation
- Video tutorials
- Best practices guide

---

## 📞 **Kontak & Support**

**Email:** support@luna-system.com  
**Documentation:** https://docs.luna-system.com  
**GitHub:** https://github.com/luna-system  

---

**Luna System - Mobile-First Tebakan Angka Platform** 🌙✨