// =====================================================
// BOS FUNCTIONS
// =====================================================

const LunaBos = {
    // Initialize BOS dashboard
    init: function() {
        this.loadDashboard();
        this.bindEvents();
    },

    // Bind events
    bindEvents: function() {
        // Quick action buttons
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-action="admin-bos-management"]')) {
                this.openAdminBosManagement();
            }
            if (e.target.matches('[data-action="transporter-management"]')) {
                this.openTransporterManagement();
            }
            if (e.target.matches('[data-action="penjual-management"]')) {
                this.openPenjualManagement();
            }
            if (e.target.matches('[data-action="pembeli-management"]')) {
                this.openPembeliManagement();
            }
            if (e.target.matches('[data-action="add-admin-bos"]')) {
                this.openAddAdminBosModal();
            }
            if (e.target.matches('[data-action="add-transporter"]')) {
                this.openAddTransporterModal();
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
            
        } catch (error) {
            console.error('Error loading dashboard:', error);
            LunaCore.showNotification('Gagal memuat dashboard', 'error');
        } finally {
            LunaCore.showLoading(false);
        }
    },

    // Load statistics
    loadStatistics: async function() {
        try {
            const response = await LunaCore.apiCall('/api/get_bos_statistics.php');
            
            if (response.success) {
                // Update Admin BOS stat cards
                const adminBosAktifEl = document.getElementById('admin-bos-aktif');
                const adminBosTotalEl = document.getElementById('admin-bos-total');
                
                if (adminBosAktifEl) adminBosAktifEl.textContent = response.data.admin_bos_aktif;
                if (adminBosTotalEl) adminBosTotalEl.textContent = response.data.total_admin_bos;
                
                // Update Transporter stat cards
                const transporterAktifEl = document.getElementById('transporter-aktif');
                const transporterTotalEl = document.getElementById('transporter-total');
                
                if (transporterAktifEl) transporterAktifEl.textContent = response.data.transporter_aktif;
                if (transporterTotalEl) transporterTotalEl.textContent = response.data.total_transporter;
                
                // Update Penjual stat cards
                const penjualAktifEl = document.getElementById('penjual-aktif');
                const penjualTotalEl = document.getElementById('penjual-total');
                
                if (penjualAktifEl) penjualAktifEl.textContent = response.data.penjual_aktif;
                if (penjualTotalEl) penjualTotalEl.textContent = response.data.total_penjual;
                
                // Update Pembeli stat cards
                const pembeliAktifEl = document.getElementById('pembeli-aktif');
                const pembeliTotalEl = document.getElementById('pembeli-total');
                
                if (pembeliAktifEl) pembeliAktifEl.textContent = response.data.pembeli_aktif;
                if (pembeliTotalEl) pembeliTotalEl.textContent = response.data.total_pembeli;
                
                console.log('BOS Statistics loaded:', response.data);
            } else {
                console.error('Failed to load statistics:', response.message);
                this.setDefaultStatistics();
            }
            
        } catch (error) {
            console.error('Error loading statistics:', error);
            this.setDefaultStatistics();
        }
    },

    // Set default statistics
    setDefaultStatistics: function() {
        const elements = [
            'admin-bos-aktif', 'admin-bos-total',
            'transporter-aktif', 'transporter-total',
            'penjual-aktif', 'penjual-total',
            'pembeli-aktif', 'pembeli-total'
        ];
        
        elements.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.textContent = '0';
        });
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

    // Admin BOS Management
    openAdminBosManagement: function() {
        LunaUI.openModal('adminBosManagementModal');
        this.loadAdminBosTable();
    },

    loadAdminBosTable: async function() {
        try {
            const response = await LunaCore.apiCall('/api/get_bos_users.php?role=Admin Bos');
            
            if (response.success) {
                this.populateUserTable(response.data, 'adminBosTableBody');
            } else {
                LunaCore.showNotification('Gagal memuat data Admin BOS', 'error');
            }
        } catch (error) {
            console.error('Error loading Admin BOS table:', error);
            LunaCore.showNotification('Gagal memuat data Admin BOS', 'error');
        }
    },

    // Transporter Management
    openTransporterManagement: function() {
        LunaUI.openModal('transporterManagementModal');
        this.loadTransporterTable();
    },

    loadTransporterTable: async function() {
        try {
            const response = await LunaCore.apiCall('/api/get_bos_users.php?role=Transporter');
            
            if (response.success) {
                this.populateUserTable(response.data, 'transporterTableBody');
            } else {
                LunaCore.showNotification('Gagal memuat data Transporter', 'error');
            }
        } catch (error) {
            console.error('Error loading Transporter table:', error);
            LunaCore.showNotification('Gagal memuat data Transporter', 'error');
        }
    },

    // Penjual Management
    openPenjualManagement: function() {
        LunaUI.openModal('penjualManagementModal');
        this.loadPenjualTable();
    },

    loadPenjualTable: async function() {
        try {
            const response = await LunaCore.apiCall('/api/get_bos_users.php?role=Penjual');
            
            if (response.success) {
                this.populateUserTable(response.data, 'penjualTableBody');
            } else {
                LunaCore.showNotification('Gagal memuat data Penjual', 'error');
            }
        } catch (error) {
            console.error('Error loading Penjual table:', error);
            LunaCore.showNotification('Gagal memuat data Penjual', 'error');
        }
    },

    // Pembeli Management
    openPembeliManagement: function() {
        LunaUI.openModal('pembeliManagementModal');
        this.loadPembeliTable();
    },

    loadPembeliTable: async function() {
        try {
            const response = await LunaCore.apiCall('/api/get_bos_users.php?role=Pembeli');
            
            if (response.success) {
                this.populateUserTable(response.data, 'pembeliTableBody');
            } else {
                LunaCore.showNotification('Gagal memuat data Pembeli', 'error');
            }
        } catch (error) {
            console.error('Error loading Pembeli table:', error);
            LunaCore.showNotification('Gagal memuat data Pembeli', 'error');
        }
    },

    // Populate user table
    populateUserTable: function(users, tableBodyId) {
        const tbody = document.getElementById(tableBodyId);
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
                    <button class="btn btn-sm btn-outline-warning" onclick="LunaBos.toggleUserStatus(${user.id})">
                        <i class="fas fa-toggle-on"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="LunaBos.deleteUser(${user.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    },

    // User management functions
    toggleUserStatus: async function(userId) {
        try {
            const response = await LunaCore.toggleUserStatus(userId);
            
            if (response.success) {
                LunaCore.showNotification('Status user berhasil diubah', 'success');
                // Refresh all tables
                this.refreshAllTables();
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
                // Refresh all tables
                this.refreshAllTables();
            } else {
                LunaCore.showNotification(response.error || 'Gagal menghapus user', 'error');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
            LunaCore.showNotification('Gagal menghapus user', 'error');
        }
    },

    // Refresh all tables
    refreshAllTables: function() {
        this.loadStatistics();
        // Refresh specific tables if modals are open
        if (document.getElementById('adminBosManagementModal').classList.contains('show')) {
            this.loadAdminBosTable();
        }
        if (document.getElementById('transporterManagementModal').classList.contains('show')) {
            this.loadTransporterTable();
        }
        if (document.getElementById('penjualManagementModal').classList.contains('show')) {
            this.loadPenjualTable();
        }
        if (document.getElementById('pembeliManagementModal').classList.contains('show')) {
            this.loadPembeliTable();
        }
    },

    // Add Admin BOS
    openAddAdminBosModal: function() {
        LunaUI.openModal('addAdminBosModal');
    },

    addAdminBos: async function(formData) {
        try {
            const response = await LunaCore.apiCall('/api/add_admin_bos.php', 'POST', formData);
            
            if (response.success) {
                LunaCore.showNotification('Admin BOS berhasil ditambahkan', 'success');
                LunaUI.closeModal('addAdminBosModal');
                LunaUI.resetForm('addAdminBosForm');
                this.loadStatistics();
            } else {
                LunaCore.showNotification(response.error || 'Gagal menambahkan Admin BOS', 'error');
            }
        } catch (error) {
            console.error('Error adding Admin BOS:', error);
            LunaCore.showNotification('Gagal menambahkan Admin BOS', 'error');
        }
    },

    // Add Transporter
    openAddTransporterModal: function() {
        LunaUI.openModal('addTransporterModal');
    },

    addTransporter: async function(formData) {
        try {
            const response = await LunaCore.apiCall('/api/add_transporter.php', 'POST', formData);
            
            if (response.success) {
                LunaCore.showNotification('Transporter berhasil ditambahkan', 'success');
                LunaUI.closeModal('addTransporterModal');
                LunaUI.resetForm('addTransporterForm');
                this.loadStatistics();
            } else {
                LunaCore.showNotification(response.error || 'Gagal menambahkan Transporter', 'error');
            }
        } catch (error) {
            console.error('Error adding Transporter:', error);
            LunaCore.showNotification('Gagal menambahkan Transporter', 'error');
        }
    },

    // Address Management (same as Super Admin)
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
    // Check if this is BOS dashboard
    if (document.querySelector('[data-role="bos"]')) {
        LunaBos.init();
    }
}); 