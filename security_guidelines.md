# 🔐 Panduan Keamanan & Best Practices - Luna System

## 🛡️ **Keamanan Aplikasi**

### **1. Authentication & Authorization**

#### **Multi-Factor Authentication (MFA)**
```javascript
// Implementasi MFA untuk role penting
const MFA_REQUIRED_ROLES = ['Super Admin', 'Bos', 'Admin Bos'];

function requireMFA(userRole) {
    return MFA_REQUIRED_ROLES.includes(userRole);
}
```

#### **Session Management**
```javascript
// Session timeout berdasarkan role
const SESSION_TIMEOUTS = {
    'Super Admin': 30 * 60 * 1000, // 30 menit
    'Bos': 60 * 60 * 1000,         // 1 jam
    'Admin Bos': 60 * 60 * 1000,   // 1 jam
    'Transporter': 120 * 60 * 1000, // 2 jam
    'Penjual': 120 * 60 * 1000,    // 2 jam
    'Pembeli': 180 * 60 * 1000     // 3 jam
};
```

#### **Role-Based Access Control (RBAC)**
```javascript
// Validasi akses berdasarkan role
const ACCESS_MATRIX = {
    'Super Admin': ['*'], // Akses penuh
    'Bos': ['manage_server', 'view_reports', 'manage_users'],
    'Admin Bos': ['view_reports', 'manage_users'],
    'Transporter': ['view_transactions', 'update_status'],
    'Penjual': ['input_tebakan', 'view_saldo'],
    'Pembeli': ['input_tebakan', 'view_history']
};
```

### **2. Data Protection**

#### **Input Validation**
```javascript
// Validasi input tebakan
function validateTebakanInput(data) {
    const rules = {
        '4d': { pattern: /^\d{4}$/, max: 9999 },
        '3d': { pattern: /^\d{3}$/, max: 999 },
        '2d': { pattern: /^\d{2}$/, max: 99 },
        'ce': { pattern: /^\d{1}$/, max: 9 },
        'ck': { pattern: /^\d{1}$/, max: 9 },
        'cb': { pattern: /^\d{1}$/, max: 9 }
    };

    for (let type in data) {
        if (!rules[type].pattern.test(data[type].angka)) {
            throw new Error(`Format ${type} tidak valid`);
        }
        if (parseInt(data[type].angka) > rules[type].max) {
            throw new Error(`Angka ${type} melebihi batas`);
        }
    }
}
```

#### **SQL Injection Prevention**
```javascript
// Gunakan parameterized queries
const query = `
    INSERT INTO transaksi_tebakan 
    (user_id, sesi_server_id, data_tebakan, harga_total, created_by) 
    VALUES (?, ?, ?, ?, ?)
`;

// Jangan gunakan string concatenation
// ❌ BAD: `SELECT * FROM user WHERE username = '${username}'`
// ✅ GOOD: `SELECT * FROM user WHERE username = ?`
```

#### **XSS Prevention**
```javascript
// Sanitasi output
function sanitizeOutput(text) {
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
}
```

### **3. Financial Security**

#### **Transaction Validation**
```javascript
// Validasi transaksi keuangan
function validateTransaction(amount, fromUser, toUser) {
    // Cek saldo
    if (getUserBalance(fromUser) < amount) {
        throw new Error('Saldo tidak mencukupi');
    }
    
    // Cek limit transaksi
    const dailyLimit = getDailyLimit(fromUser);
    const dailyTotal = getDailyTransactionTotal(fromUser);
    
    if (dailyTotal + amount > dailyLimit) {
        throw new Error('Melebihi limit harian');
    }
    
    // Cek suspicious activity
    if (isSuspiciousActivity(fromUser, amount)) {
        flagForReview(fromUser, amount);
    }
}
```

#### **Audit Trail**
```javascript
// Log semua transaksi penting
function logTransaction(type, userId, amount, details) {
    const log = {
        timestamp: new Date(),
        type: type,
        user_id: userId,
        amount: amount,
        details: details,
        ip_address: getClientIP(),
        user_agent: getUserAgent(),
        session_id: getSessionId()
    };
    
    // Simpan ke audit log
    saveAuditLog(log);
}
```

## 📱 **UX/UI Best Practices**

### **1. Mobile-First Design**

#### **Touch-Friendly Interface**
```css
/* Minimal touch target size */
.touch-target {
    min-width: 44px;
    min-height: 44px;
    padding: 12px;
}

/* Spacing untuk jari */
.touch-spacing {
    margin: 8px;
    padding: 16px;
}
```

#### **Responsive Typography**
```css
/* Font size yang mudah dibaca di mobile */
.mobile-text {
    font-size: 16px; /* Minimal untuk mencegah zoom */
    line-height: 1.5;
}

.number-display {
    font-size: 2rem;
    font-weight: bold;
    color: var(--primary-color);
}
```

### **2. Number-Focused Design**

#### **Large Number Inputs**
```css
.number-input {
    font-size: 2rem;
    font-weight: bold;
    text-align: center;
    height: 60px;
    border: 3px solid #e5e7eb;
    border-radius: 12px;
    background: #f9fafb;
}

.number-input:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
}
```

#### **Quick Number Buttons**
```css
.quick-number {
    background: var(--primary-color);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 16px;
    font-size: 1.2rem;
    font-weight: bold;
    min-height: 60px;
    transition: all 0.3s ease;
}

.quick-number:active {
    transform: scale(0.95);
}
```

### **3. User Experience**

#### **Loading States**
```javascript
// Show loading untuk operasi penting
function showLoading(operation) {
    const loadingEl = document.getElementById('loading');
    loadingEl.innerHTML = `
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-2">${operation}...</p>
    `;
    loadingEl.style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loading').style.display = 'none';
}
```

#### **Error Handling**
```javascript
// User-friendly error messages
function showError(message, type = 'error') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <div class="toast-header">
            <i class="fas fa-exclamation-triangle"></i>
            <strong>Error</strong>
        </div>
        <div class="toast-body">${message}</div>
    `;
    
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 5000);
}
```

#### **Confirmation Dialogs**
```javascript
// Konfirmasi untuk aksi penting
function confirmAction(message, callback) {
    const modal = document.createElement('div');
    modal.className = 'confirmation-modal';
    modal.innerHTML = `
        <div class="modal-content">
            <h5>Konfirmasi</h5>
            <p>${message}</p>
            <div class="modal-actions">
                <button class="btn btn-secondary" onclick="this.closest('.confirmation-modal').remove()">Batal</button>
                <button class="btn btn-primary" onclick="executeAction()">Ya, Lanjutkan</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    function executeAction() {
        modal.remove();
        callback();
    }
}
```

## 🚀 **Performance Optimization**

### **1. Database Optimization**

#### **Indexing Strategy**
```sql
-- Index untuk query yang sering digunakan
CREATE INDEX idx_transaksi_date_user ON transaksi_tebakan(created_at, user_id);
CREATE INDEX idx_transaksi_sesi_status ON transaksi_tebakan(sesi_server_id, status);
CREATE INDEX idx_deposit_user_bos ON deposit_member(user_id, bos_id);
CREATE INDEX idx_pembayaran_date_status ON transaksi_pembayaran(created_at, status);
```

#### **Query Optimization**
```sql
-- Gunakan LIMIT untuk pagination
SELECT * FROM transaksi_tebakan 
WHERE user_id = ? 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 0;

-- Gunakan EXPLAIN untuk analisis query
EXPLAIN SELECT * FROM transaksi_tebakan WHERE sesi_server_id = 1;
```

### **2. Frontend Optimization**

#### **Lazy Loading**
```javascript
// Lazy load untuk data besar
function loadTransactions(page = 1) {
    showLoading('Memuat transaksi...');
    
    fetch(`/api/transactions?page=${page}&limit=20`)
        .then(response => response.json())
        .then(data => {
            renderTransactions(data.transactions);
            updatePagination(data.total, data.page);
        })
        .finally(() => hideLoading());
}
```

#### **Caching Strategy**
```javascript
// Cache data yang sering diakses
const cache = new Map();

function getCachedData(key, fetchFunction, ttl = 5 * 60 * 1000) {
    const cached = cache.get(key);
    
    if (cached && Date.now() - cached.timestamp < ttl) {
        return cached.data;
    }
    
    const data = fetchFunction();
    cache.set(key, { data, timestamp: Date.now() });
    return data;
}
```

## 📊 **Monitoring & Analytics**

### **1. Error Tracking**
```javascript
// Track error untuk debugging
function trackError(error, context) {
    const errorLog = {
        message: error.message,
        stack: error.stack,
        context: context,
        timestamp: new Date(),
        user_id: getCurrentUserId(),
        user_agent: navigator.userAgent,
        url: window.location.href
    };
    
    // Send to error tracking service
    fetch('/api/log/error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(errorLog)
    });
}
```

### **2. User Analytics**
```javascript
// Track user behavior
function trackUserAction(action, data) {
    const analytics = {
        action: action,
        data: data,
        timestamp: new Date(),
        user_id: getCurrentUserId(),
        session_id: getSessionId()
    };
    
    // Send to analytics service
    fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(analytics)
    });
}
```

## 🔄 **Backup & Recovery**

### **1. Database Backup**
```sql
-- Automated backup script
-- Backup setiap hari jam 2 pagi
-- Retensi 30 hari

-- Backup database
mysqldump -u username -p sistem_tebakan_angka > backup_$(date +%Y%m%d).sql

-- Backup dengan compression
mysqldump -u username -p sistem_tebakan_angka | gzip > backup_$(date +%Y%m%d).sql.gz
```

### **2. Disaster Recovery**
```javascript
// Recovery procedures
const RECOVERY_PROCEDURES = {
    'database_corruption': [
        'Stop application',
        'Restore from latest backup',
        'Apply transaction logs',
        'Verify data integrity',
        'Restart application'
    ],
    'server_failure': [
        'Switch to backup server',
        'Update DNS records',
        'Verify connectivity',
        'Monitor performance'
    ]
};
```

## 📋 **Compliance & Legal**

### **1. Data Privacy**
```javascript
// GDPR compliance
function handleDataRequest(userId, requestType) {
    switch(requestType) {
        case 'export':
            return exportUserData(userId);
        case 'delete':
            return deleteUserData(userId);
        case 'rectify':
            return rectifyUserData(userId);
    }
}
```

### **2. Audit Requirements**
```javascript
// Audit log untuk compliance
function createAuditLog(action, userId, details) {
    const audit = {
        action: action,
        user_id: userId,
        details: details,
        timestamp: new Date(),
        ip_address: getClientIP(),
        user_agent: getUserAgent()
    };
    
    // Simpan ke audit table
    saveAuditLog(audit);
    
    // Backup ke external system
    backupAuditLog(audit);
}
```

---

## 🎯 **Kesimpulan**

### **Prioritas Keamanan:**
1. **Authentication & Authorization** - Multi-factor, session management
2. **Data Protection** - Input validation, SQL injection prevention
3. **Financial Security** - Transaction validation, audit trail
4. **Mobile UX** - Touch-friendly, number-focused design
5. **Performance** - Database optimization, caching
6. **Monitoring** - Error tracking, user analytics
7. **Compliance** - Data privacy, audit requirements

### **Implementasi Bertahap:**
1. **Phase 1**: Basic security (auth, validation)
2. **Phase 2**: Financial security (transactions, audit)
3. **Phase 3**: Advanced features (MFA, monitoring)
4. **Phase 4**: Compliance & optimization

**Sistem yang aman, performant, dan user-friendly!** 🚀