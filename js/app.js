// =====================================================
// LUNA SYSTEM - MAIN JAVASCRIPT FILE
// Sistem Tebakan Angka
// =====================================================

// Global variables
let currentUser = null;
let currentSession = null;

// =====================================================
// UTILITY FUNCTIONS
// =====================================================

const LunaUtils = {
    // Format currency
    formatCurrency: function(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR'
        }).format(amount);
    },

    // Format date
    formatDate: function(date) {
        return new Intl.DateTimeFormat('id-ID', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date(date));
    },

    // Show toast notification
    showToast: function(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <div class="toast-header">
                <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-triangle' : 'info-circle'}"></i>
                <strong>${type.charAt(0).toUpperCase() + type.slice(1)}</strong>
            </div>
            <div class="toast-body">${message}</div>
        `;
        
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 5000);
    },

    // Show loading
    showLoading: function(element, text = 'Loading...') {
        if (typeof element === 'string') {
            element = document.getElementById(element);
        }
        
        element.innerHTML = `
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">${text}</span>
            </div>
        `;
        element.style.display = 'flex';
    },

    // Hide loading
    hideLoading: function(element) {
        if (typeof element === 'string') {
            element = document.getElementById(element);
        }
        element.style.display = 'none';
    },

    // Confirm action
    confirmAction: function(message, callback) {
        if (confirm(message)) {
            callback();
        }
    },

    // Get current user
    getCurrentUser: function() {
        return JSON.parse(localStorage.getItem('luna_user')) || null;
    },

    // Set current user
    setCurrentUser: function(user) {
        localStorage.setItem('luna_user', JSON.stringify(user));
        currentUser = user;
    },

    // Clear current user
    clearCurrentUser: function() {
        localStorage.removeItem('luna_user');
        currentUser = null;
    },

    // Check if user is logged in
    isLoggedIn: function() {
        return currentUser !== null;
    },

    // Redirect to page
    redirect: function(page) {
        window.location.href = page;
    },

    // Logout function
    logout: function() {
        this.clearCurrentUser();
        localStorage.removeItem('luna_token');
        this.redirect('index.html');
    },

    // API call helper
    apiCall: async function(url, options = {}) {
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${localStorage.getItem('luna_token')}`
            }
        };

        try {
            // Ensure URL has correct path for localhost
            let fullUrl = url;
            if (!url.startsWith('http')) {
                fullUrl = url.startsWith('/') ? `/luna${url}` : `/luna/${url}`;
            }
            
            const response = await fetch(fullUrl, { ...defaultOptions, ...options });
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'API Error');
            }
            
            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }
};

// =====================================================
// VALIDATION FUNCTIONS
// =====================================================

const LunaValidation = {
    // Validasi pembuatan user berdasarkan role
    validateUserCreation: function(creatorRole, targetRole) {
        const validRoles = {
            'Super Admin': ['Bos', 'Admin Bos', 'Transporter', 'Penjual', 'Pembeli'],
            'Bos': ['Admin Bos', 'Transporter'],
            'Transporter': ['Penjual'],
            'Penjual': ['Pembeli']
        };

        if (!validRoles[creatorRole]) {
            return { valid: false, message: 'Role creator tidak valid' };
        }

        if (!validRoles[creatorRole].includes(targetRole)) {
            return { valid: false, message: 'Role creator tidak memiliki izin untuk membuat user dengan role ini' };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi sesi server
    validateSessionCreation: function(creatorRole, serverOwnerId, creatorId) {
        if (creatorRole === 'Super Admin') {
            return { valid: true, message: 'Super Admin dapat membuat sesi untuk semua server' };
        }

        if (creatorRole === 'Bos' && serverOwnerId === creatorId) {
            return { valid: true, message: 'Bos dapat membuat sesi untuk server miliknya' };
        }

        return { valid: false, message: 'Tidak memiliki izin untuk membuat sesi server' };
    },

    // Validasi input hasil tebakan
    validateResultInput: function(creatorRole) {
        const allowedRoles = ['Super Admin', 'Bos', 'Admin Bos'];
        
        if (!allowedRoles.includes(creatorRole)) {
            return { valid: false, message: 'Hanya Super Admin, Bos, dan Admin Bos yang dapat input hasil tebakan' };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi deposit tidak boleh negatif
    validateDeposit: function(amount) {
        if (amount <= 0) {
            return { valid: false, message: 'Jumlah deposit harus lebih dari 0' };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi transaksi pembayaran
    validatePayment: function(amount, fromUserId, toUserId) {
        if (amount <= 0) {
            return { valid: false, message: 'Jumlah pembayaran harus lebih dari 0' };
        }

        if (fromUserId === toUserId) {
            return { valid: false, message: 'Tidak dapat melakukan pembayaran ke diri sendiri' };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi transaksi tebakan
    validateBetting: function(amount, bettingData) {
        if (amount <= 0) {
            return { valid: false, message: 'Jumlah tebakan harus lebih dari 0' };
        }

        if (!bettingData || Object.keys(bettingData).length === 0) {
            return { valid: false, message: 'Data tebakan tidak boleh kosong' };
        }

        // Validasi format JSON
        for (let type in bettingData) {
            if (!Array.isArray(bettingData[type])) {
                return { valid: false, message: `Format data ${type} tidak valid` };
            }

            for (let item of bettingData[type]) {
                if (!item.angka || !item.jumlah) {
                    return { valid: false, message: `Data ${type} tidak lengkap` };
                }

                if (item.jumlah <= 0) {
                    return { valid: false, message: `Jumlah untuk ${type} harus lebih dari 0` };
                }
            }
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi user ownership
    validateOwnership: function(ownerRole, ownedRole, relationshipType) {
        const validRelationships = {
            'Super Admin': {
                'Bos': ['parent'],
                'Admin Bos': ['parent'],
                'Transporter': ['parent'],
                'Penjual': ['parent'],
                'Pembeli': ['parent']
            },
            'Bos': {
                'Admin Bos': ['parent'],
                'Transporter': ['parent'],
                'Penjual': ['parent'],
                'Pembeli': ['parent']
            },
            'Transporter': {
                'Penjual': ['parent'],
                'Pembeli': ['parent']
            },
            'Penjual': {
                'Pembeli': ['parent']
            }
        };

        if (!validRelationships[ownerRole] || !validRelationships[ownerRole][ownedRole]) {
            return { valid: false, message: 'Relasi ownership tidak valid' };
        }

        if (!validRelationships[ownerRole][ownedRole].includes(relationshipType)) {
            return { valid: false, message: 'Tipe relasi tidak valid' };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi input angka tebakan
    validateNumberInput: function(type, number) {
        const rules = {
            '4D': { pattern: /^\d{4}$/, max: 9999 },
            '3D': { pattern: /^\d{3}$/, max: 999 },
            '2D': { pattern: /^\d{2}$/, max: 99 },
            'CE': { pattern: /^\d{1}$/, max: 9 },
            'CK': { pattern: /^\d{1}$/, max: 9 },
            'CB': { pattern: /^\d{1}$/, max: 9 }
        };

        if (!rules[type]) {
            return { valid: false, message: `Tipe tebakan ${type} tidak valid` };
        }

        if (!rules[type].pattern.test(number)) {
            return { valid: false, message: `Format ${type} tidak valid` };
        }

        if (parseInt(number) > rules[type].max) {
            return { valid: false, message: `Angka ${type} melebihi batas` };
        }

        return { valid: true, message: 'Validasi berhasil' };
    },

    // Validasi password strength
    validatePassword: function(password) {
        let strength = 0;
        let messages = [];

        if (password.length >= 8) strength++;
        else messages.push('Minimal 8 karakter');

        if (/[a-z]/.test(password)) strength++;
        else messages.push('Harus ada huruf kecil');

        if (/[A-Z]/.test(password)) strength++;
        else messages.push('Harus ada huruf besar');

        if (/[0-9]/.test(password)) strength++;
        else messages.push('Harus ada angka');

        if (/[^A-Za-z0-9]/.test(password)) strength++;
        else messages.push('Harus ada karakter khusus');

        const strengthLevels = {
            0: 'Sangat Lemah',
            1: 'Lemah',
            2: 'Cukup',
            3: 'Baik',
            4: 'Kuat',
            5: 'Sangat Kuat'
        };

        return {
            valid: strength >= 3,
            strength: strength,
            level: strengthLevels[strength],
            messages: messages
        };
    }
};

// =====================================================
// AUTHENTICATION FUNCTIONS
// =====================================================

const LunaAuth = {
    // Login
    login: async function(username, password) {
        try {
            LunaUtils.showLoading('loading-container', 'Logging in...');
            
            const response = await LunaUtils.apiCall('/api/auth/login', {
                method: 'POST',
                body: JSON.stringify({ username, password })
            });

            LunaUtils.setCurrentUser(response.user);
            localStorage.setItem('luna_token', response.token);
            
            LunaUtils.showToast('Login berhasil!', 'success');
            
            // Redirect based on user role
            setTimeout(() => {
                this.redirectBasedOnRole(response.user.role);
            }, 1500);
            
        } catch (error) {
            LunaUtils.showToast(error.message, 'error');
        } finally {
            LunaUtils.hideLoading('loading-container');
        }
    },

    // Register
    register: async function(userData) {
        try {
            LunaUtils.showLoading('loading-container', 'Registering...');
            
            const response = await LunaUtils.apiCall('/api/auth/register', {
                method: 'POST',
                body: JSON.stringify(userData)
            });

            LunaUtils.showToast('Registrasi berhasil! Silakan login.', 'success');
            return response;
            
        } catch (error) {
            LunaUtils.showToast(error.message, 'error');
            throw error;
        } finally {
            LunaUtils.hideLoading('loading-container');
        }
    },

    // Logout
    logout: function() {
        LunaUtils.confirmAction('Yakin ingin logout?', () => {
            LunaUtils.clearCurrentUser();
            localStorage.removeItem('luna_token');
            LunaUtils.redirect('index.html');
        });
    },

    // Forgot password
    forgotPassword: async function(email) {
        try {
            LunaUtils.showLoading('loading-container', 'Sending reset link...');
            
            await LunaUtils.apiCall('/api/auth/forgot-password', {
                method: 'POST',
                body: JSON.stringify({ email })
            });

            LunaUtils.showToast('Link reset password telah dikirim ke email Anda', 'success');
            
        } catch (error) {
            LunaUtils.showToast(error.message, 'error');
        } finally {
            LunaUtils.hideLoading('loading-container');
        }
    },

    // Check authentication
    checkAuth: function() {
        if (!LunaUtils.isLoggedIn()) {
            LunaUtils.redirect('index.html');
            return false;
        }
        return true;
    },

    // Redirect based on user role
    redirectBasedOnRole: function(role) {
        switch(role) {
            case 'Super Admin':
                LunaUtils.redirect('dashboards/super_admin/index.html');
                break;
            case 'Bos':
                LunaUtils.redirect('dashboards/bos/index.html');
                break;
            case 'Admin Bos':
                LunaUtils.redirect('dashboards/admin_bos/index.html');
                break;
            case 'Transporter':
                LunaUtils.redirect('dashboards/transporter/index.html');
                break;
            case 'Penjual':
                LunaUtils.redirect('dashboards/penjual/index.html');
                break;
            case 'Pembeli':
                LunaUtils.redirect('dashboards/pembeli/index.html');
                break;
            default:
                LunaUtils.redirect('dashboards/super_admin/index.html');
        }
    }
};

// =====================================================
// DASHBOARD FUNCTIONS
// =====================================================

const LunaDashboard = {
    // Load dashboard data
    loadDashboard: async function() {
        try {
            const user = LunaUtils.getCurrentUser();

            // Load user info if user exists
            if (user) {
                this.updateUserInfo(user);
            }

            // Load statistics
            await this.loadStatistics();

            // Load recent transactions
            await this.loadRecentTransactions();

        } catch (error) {
            console.error('Error loading dashboard:', error);
            LunaUtils.showToast('Error loading dashboard data', 'error');
        }
    },

    // Update user info
    updateUserInfo: function(user) {
        const userInfoEl = document.querySelector('.user-info');
        if (userInfoEl) {
            userInfoEl.innerHTML = `
                <div class="avatar">
                    <i class="fas fa-user"></i>
                </div>
                <div>
                    <h6 class="mb-0">${user.nama_lengkap || user.username}</h6>
                    <small>${user.role}</small>
                </div>
            `;
        }
    },

    // Load statistics
    loadStatistics: async function() {
        try {
            // Load BOS statistics only
            const bosStats = await LunaUtils.apiCall('/api/get_bos_statistics.php');
            
            if (bosStats.success) {
                // Update BOS stat cards
                const bosAktifEl = document.getElementById('bos-aktif');
                const bosTotalEl = document.getElementById('bos-total');
                
                if (bosAktifEl) bosAktifEl.textContent = bosStats.data.bos_aktif;
                if (bosTotalEl) bosTotalEl.textContent = bosStats.data.total_bos;
                
                console.log('BOS Statistics loaded:', bosStats.data);
            } else {
                console.error('Failed to load BOS statistics:', bosStats.message);
                // Set default values if API fails
                const bosAktifEl = document.getElementById('bos-aktif');
                const bosTotalEl = document.getElementById('bos-total');
                
                if (bosAktifEl) bosAktifEl.textContent = '0';
                if (bosTotalEl) bosTotalEl.textContent = '0';
            }
            
        } catch (error) {
            console.error('Error loading statistics:', error);
            // Set default values if API fails
            const bosAktifEl = document.getElementById('bos-aktif');
            const bosTotalEl = document.getElementById('bos-total');
            
            if (bosAktifEl) bosAktifEl.textContent = '0';
            if (bosTotalEl) bosTotalEl.textContent = '0';
        }
    },

    // Load recent transactions
    loadRecentTransactions: async function() {
        try {
            // Skip loading recent transactions for now
            // This feature will be implemented later
            console.log('Recent transactions feature not yet implemented');
            
        } catch (error) {
            console.error('Error loading recent transactions:', error);
        }
    }
};

// =====================================================
// TEBAKAN FUNCTIONS
// =====================================================

const LunaTebakan = {
    // Initialize tebakan form
    init: function() {
        this.bindEvents();
        this.updateSummary();
    },

    // Bind events
    bindEvents: function() {
        // Number input events
        document.querySelectorAll('.number-input').forEach(input => {
            input.addEventListener('input', (e) => this.handleNumberInput(e.target));
        });

        // Quick number buttons
        document.querySelectorAll('.quick-number').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const type = e.target.dataset.type;
                const number = e.target.dataset.number;
                this.fillQuickNumber(type, number);
            });
        });

        // Quantity buttons
        document.querySelectorAll('.quantity-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const type = e.target.dataset.type;
                const change = parseInt(e.target.dataset.change);
                this.changeQuantity(type, change);
            });
        });

        // Form submission
        document.getElementById('tebakan-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.submitTebakan();
        });
    },

    // Handle number input
    handleNumberInput: function(input) {
        const type = input.dataset.type;
        const position = parseInt(input.dataset.position);
        const value = input.value;

        // Validate input
        if (!/^\d*$/.test(value)) {
            input.value = '';
            return;
        }

        // Auto focus next input
        if (value && position < this.getMaxDigits(type) - 1) {
            const nextInput = document.querySelector(`[data-type="${type}"][data-position="${position + 1}"]`);
            if (nextInput) nextInput.focus();
        }

        this.updateTebakanData(type);
        this.updateSummary();
    },

    // Fill quick number
    fillQuickNumber: function(type, number) {
        const inputs = document.querySelectorAll(`[data-type="${type}"]`);
        inputs.forEach((input, index) => {
            input.value = number[index] || '';
        });
        this.updateTebakanData(type);
        this.updateSummary();
    },

    // Change quantity
    changeQuantity: function(type, change) {
        const currentQty = parseInt(document.getElementById(`quantity-${type}`).textContent);
        const newQty = Math.max(1, currentQty + change);
        
        document.getElementById(`quantity-${type}`).textContent = newQty;
        this.updateSummary();
    },

    // Update tebakan data
    updateTebakanData: function(type) {
        const inputs = document.querySelectorAll(`[data-type="${type}"]`);
        let angka = '';
        inputs.forEach(input => {
            angka += input.value;
        });
        
        // Store in data attribute
        document.getElementById(`section-${type}`).dataset.angka = angka;
    },

    // Update summary
    updateSummary: function() {
        let grandTotal = 0;
        const types = ['4d', '3d', '2d'];

        types.forEach(type => {
            const angka = document.getElementById(`section-${type}`).dataset.angka || '';
            const quantity = parseInt(document.getElementById(`quantity-${type}`).textContent);
            const harga = this.getHarga(type);
            const total = angka ? quantity * harga : 0;
            grandTotal += total;

            document.getElementById(`summary-${type}`).textContent = angka || '-';
            document.getElementById(`total-${type}`).textContent = LunaUtils.formatCurrency(total);
        });

        document.getElementById('grand-total').textContent = LunaUtils.formatCurrency(grandTotal);
    },

    // Get harga per tipe
    getHarga: function(type) {
        const harga = {
            '4d': 1000,
            '3d': 500,
            '2d': 200
        };
        return harga[type] || 0;
    },

    // Get max digits for type
    getMaxDigits: function(type) {
        const maxDigits = { '4d': 4, '3d': 3, '2d': 2 };
        return maxDigits[type];
    },

    // Submit tebakan
    submitTebakan: async function() {
        try {
            const tebakanData = this.collectTebakanData();
            
            if (Object.keys(tebakanData).length === 0) {
                LunaUtils.showToast('Tidak ada tebakan yang valid!', 'error');
                return;
            }

            LunaUtils.showLoading('submit-btn', 'Submitting...');
            
            const response = await LunaUtils.apiCall('/api/tebakan/submit', {
                method: 'POST',
                body: JSON.stringify(tebakanData)
            });

            LunaUtils.showToast('Tebakan berhasil disimpan!', 'success');
            this.clearForm();
            
        } catch (error) {
            LunaUtils.showToast(error.message, 'error');
        } finally {
            LunaUtils.hideLoading('submit-btn');
        }
    },

    // Collect tebakan data
    collectTebakanData: function() {
        const tebakanData = {};
        const types = ['4d', '3d', '2d'];

        types.forEach(type => {
            const angka = document.getElementById(`section-${type}`).dataset.angka || '';
            const quantity = parseInt(document.getElementById(`quantity-${type}`).textContent);
            
            if (angka && angka.length === this.getMaxDigits(type)) {
                tebakanData[type] = {
                    angka: angka,
                    jumlah: quantity,
                    harga: this.getHarga(type)
                };
            }
        });

        return tebakanData;
    },

    // Clear form
    clearForm: function() {
        document.querySelectorAll('.number-input').forEach(input => {
            input.value = '';
        });

        document.querySelectorAll('.quantity-display').forEach(display => {
            display.textContent = '1';
        });

        this.updateSummary();
    }
};

// =====================================================
// EVENT LISTENERS
// =====================================================

document.addEventListener('DOMContentLoaded', function() {
    // Initialize based on current page
    const currentPage = window.location.pathname.split('/').pop();
    
    switch(currentPage) {
        case 'index.html':
        case '':
            // Login page - focus on first input
            const firstInput = document.getElementById('login-username');
            if (firstInput) firstInput.focus();
            break;
            
        case 'super_admin_dashboard.html':
            // Dashboard page
            console.log('Super admin dashboard page detected');
            LunaDashboard.loadDashboard();
            break;
    }

    // Global event listeners
    document.addEventListener('click', function(e) {
        // Handle navigation
        if (e.target.matches('.nav-item')) {
            e.preventDefault();
            const page = e.target.getAttribute('href');
            if (page) LunaUtils.redirect(page);
        }

        // Handle logout
        if (e.target.matches('.logout-btn')) {
            e.preventDefault();
            LunaAuth.logout();
        }

        // Handle back button
        if (e.target.matches('.back-btn')) {
            e.preventDefault();
            window.history.back();
        }
    });
});

// =====================================================
// EXPORT FOR MODULE SYSTEMS
// =====================================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        LunaUtils,
        LunaValidation,
        LunaAuth,
        LunaDashboard,
        LunaTebakan
    };
}