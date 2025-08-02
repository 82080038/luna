// =====================================================
// SUPER ADMIN FUNCTIONS
// =====================================================

const LunaSuperAdmin = {
    // Initialize Super Admin dashboard
    init: function() {
        this.loadDashboard();
        this.bindEvents();
    },

    // Bind events
    bindEvents: function() {
        // Quick action buttons
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-action="user-management"]')) {
                this.openUserManagement();
            }
            if (e.target.matches('[data-action="server-management"]')) {
                this.openServerManagement();
            }
            if (e.target.matches('[data-action="financial-report"]')) {
                this.openFinancialReport();
            }
            if (e.target.matches('[data-action="system-settings"]')) {
                this.openSystemSettings();
            }
            if (e.target.matches('[data-action="add-bos"]')) {
                this.openAddBosModal();
            }
        });

        // Address dropdowns
        this.setupAddressDropdowns();
    },

    // Load dashboard data
    loadDashboard: async function() {
        try {
            LunaCore.showLoading(true);
            
            // Load statistics
            await this.loadStatistics();
            
            // Load recent activities
            await this.loadRecentActivities();
            
            // Load notifications
            await this.loadNotifications();
            
        } catch (error) {
            console.error('Error loading dashboard:', error);
            LunaCore.showNotification('Gagal memuat dashboard', 'error');
        } finally {
            LunaCore.showLoading(false);
        }
    },

    // Load BOS statistics
    loadStatistics: async function() {
        try {
            const bosStats = await LunaCore.apiCall('get_bos_statistics.php');
            
            if (bosStats.success) {
                // Update BOS stat cards
                const bosAktifEl = document.getElementById('bos-aktif');
                const bosTotalEl = document.getElementById('bos-total');
                
                if (bosAktifEl) bosAktifEl.textContent = bosStats.data.admin_bos_aktif;
                if (bosTotalEl) bosTotalEl.textContent = bosStats.data.total_admin_bos;
                
                console.log('BOS Statistics loaded:', bosStats.data);
            } else {
                console.error('Failed to load BOS statistics:', bosStats.message);
                this.setDefaultStatistics();
            }
            
        } catch (error) {
            console.error('Error loading statistics:', error);
            this.setDefaultStatistics();
        }
    },

    // Set default statistics
    setDefaultStatistics: function() {
        const bosAktifEl = document.getElementById('bos-aktif');
        const bosTotalEl = document.getElementById('bos-total');
        
        if (bosAktifEl) bosAktifEl.textContent = '0';
        if (bosTotalEl) bosTotalEl.textContent = '0';
    },

    // Load recent activities
    loadRecentActivities: async function() {
        try {
            // This feature will be implemented later
            console.log('Recent activities feature not yet implemented');
        } catch (error) {
            console.error('Error loading recent activities:', error);
        }
    },

    // Load notifications
    loadNotifications: async function() {
        try {
            // This feature will be implemented later
            console.log('Notifications feature not yet implemented');
        } catch (error) {
            console.error('Error loading notifications:', error);
        }
    },

    // User Management
    openUserManagement: function() {
        LunaUI.openModal('userManagementModal');
        this.loadUserTable();
    },

    loadUserTable: async function() {
        try {
            const response = await LunaCore.getAllUsers();
            
            if (response.success) {
                this.populateUserTable(response.data);
            } else {
                LunaCore.showNotification('Gagal memuat data user', 'error');
            }
        } catch (error) {
            console.error('Error loading user table:', error);
            LunaCore.showNotification('Gagal memuat data user', 'error');
        }
    },

    populateUserTable: function(users) {
        const tbody = document.getElementById('userTableBody');
        if (!tbody) return;

        tbody.innerHTML = '';
        
        users.forEach(user => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.nama_lengkap || '-'}</td>
                <td>${user.telepon || '-'}</td>
                <td><span class="badge bg-primary">${user.role}</span></td>
                <td>
                    <span class="badge ${user.is_active ? 'bg-success' : 'bg-danger'}">
                        ${user.is_active ? 'Aktif' : 'Tidak Aktif'}
                    </span>
                </td>
                <td>${LunaCore.formatDate(user.created_at)}</td>
                <td>
                    <button class="btn btn-sm btn-outline-warning" onclick="LunaSuperAdmin.toggleUserStatus(${user.id})">
                        <i class="fas fa-toggle-on"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="LunaSuperAdmin.deleteUser(${user.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    },

    toggleUserStatus: async function(userId) {
        try {
            const response = await LunaCore.toggleUserStatus(userId);
            
            if (response.success) {
                LunaCore.showNotification('Status user berhasil diubah', 'success');
                this.loadUserTable(); // Refresh table
            } else {
                LunaCore.showNotification(response.error || 'Gagal mengubah status user', 'error');
            }
        } catch (error) {
            console.error('Error toggling user status:', error);
            LunaCore.showNotification('Gagal mengubah status user', 'error');
        }
    },

    deleteUser: async function(userId) {
        if (!confirm('Apakah Anda yakin ingin menghapus user ini?')) {
            return;
        }

        try {
            const response = await LunaCore.deleteUser(userId);
            
            if (response.success) {
                LunaCore.showNotification('User berhasil dihapus', 'success');
                this.loadUserTable(); // Refresh table
            } else {
                LunaCore.showNotification(response.error || 'Gagal menghapus user', 'error');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
            LunaCore.showNotification('Gagal menghapus user', 'error');
        }
    },

    // Server Management
    openServerManagement: function() {
        LunaUI.openModal('serverManagementModal');
    },

    // Financial Report
    openFinancialReport: function() {
        LunaCore.showNotification('Fitur laporan keuangan belum tersedia', 'info');
    },

    // System Settings
    openSystemSettings: function() {
        LunaCore.showNotification('Fitur pengaturan sistem belum tersedia', 'info');
    },

    // BOS Management
    openAddBosModal: function() {
        LunaUI.openModal('addBosModal');
    },

    addBos: async function(formData) {
        try {
            const response = await LunaCore.apiCall('add_bos.php', 'POST', formData);
            
            if (response.success) {
                LunaCore.showNotification('BOS berhasil ditambahkan', 'success');
                LunaUI.closeModal('addBosModal');
                LunaUI.resetForm('addBosForm');
                this.loadStatistics(); // Refresh statistics
            } else {
                LunaCore.showNotification(response.error || 'Gagal menambahkan BOS', 'error');
            }
        } catch (error) {
            console.error('Error adding BOS:', error);
            LunaCore.showNotification('Gagal menambahkan BOS', 'error');
        }
    },

    // Address Management
    setupAddressDropdowns: function() {
        // Load provinces on page load
        this.loadProvinces();
        
        // Bind province change event
        const provinceSelect = document.getElementById('provinsi');
        if (provinceSelect) {
            provinceSelect.addEventListener('change', (e) => {
                this.loadKabupaten(e.target.value);
            });
        }

        // Bind kabupaten change event
        const kabupatenSelect = document.getElementById('kabupaten');
        if (kabupatenSelect) {
            kabupatenSelect.addEventListener('change', (e) => {
                this.loadKecamatan(e.target.value);
            });
        }

        // Bind kecamatan change event
        const kecamatanSelect = document.getElementById('kecamatan');
        if (kecamatanSelect) {
            kecamatanSelect.addEventListener('change', (e) => {
                this.loadKelurahan(e.target.value);
            });
        }
    },

    loadProvinces: async function() {
        try {
            const response = await LunaCore.getProvinces();
            
            if (response.success) {
                LunaUI.populateDropdown('provinsi', response.data, 'id', 'nama');
            }
        } catch (error) {
            console.error('Error loading provinces:', error);
        }
    },

    loadKabupaten: async function(provinceId) {
        if (!provinceId) return;
        
        try {
            const response = await LunaCore.getKabupaten(provinceId);
            
            if (response.success) {
                LunaUI.populateDropdown('kabupaten', response.data, 'id', 'nama');
                // Reset dependent dropdowns
                LunaUI.populateDropdown('kecamatan', [], 'id', 'nama');
                LunaUI.populateDropdown('kelurahan', [], 'id', 'nama');
            }
        } catch (error) {
            console.error('Error loading kabupaten:', error);
        }
    },

    loadKecamatan: async function(kabupatenId) {
        if (!kabupatenId) return;
        
        try {
            const response = await LunaCore.getKecamatan(kabupatenId);
            
            if (response.success) {
                LunaUI.populateDropdown('kecamatan', response.data, 'id', 'nama');
                // Reset dependent dropdown
                LunaUI.populateDropdown('kelurahan', [], 'id', 'nama');
            }
        } catch (error) {
            console.error('Error loading kecamatan:', error);
        }
    },

    loadKelurahan: async function(kecamatanId) {
        if (!kecamatanId) return;
        
        try {
            const response = await LunaCore.getKelurahan(kecamatanId);
            
            if (response.success) {
                LunaUI.populateDropdown('kelurahan', response.data, 'id', 'nama');
            }
        } catch (error) {
            console.error('Error loading kelurahan:', error);
        }
    }
};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Check if this is Super Admin dashboard
    if (document.querySelector('[data-role="super-admin"]')) {
        LunaSuperAdmin.init();
    }
}); 