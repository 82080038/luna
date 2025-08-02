// =====================================================
// DASHBOARD MODULE - Handles dashboard functionality
// =====================================================

const LunaDashboard = {
    // Initialize dashboard
    init: function() {
        this.bindEvents();
        this.checkAuth();
    },

    // Bind all event listeners
    bindEvents: function() {
        // Modal triggers
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-action]')) {
                e.preventDefault();
                this.handleAction(e.target.dataset.action, e);
            }
        });

        // Form submissions
        const addBosForm = document.getElementById('addBosForm');
        if (addBosForm) {
            addBosForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleAddBos();
            });
        }

        // Logout
        const logoutBtn = document.querySelector('[data-action="logout"]');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.handleLogout();
            });
        }
    },

    // Handle different actions
    handleAction: function(action, event) {
        switch(action) {
            case 'user-management':
                this.openUserManagement();
                break;
            case 'server-management':
                this.openServerManagement();
                break;
            case 'financial-report':
                this.openFinancialReport();
                break;
            case 'system-settings':
                this.openSystemSettings();
                break;
            case 'add-bos':
                this.openAddBosModal();
                break;
            case 'logout':
                this.handleLogout();
                break;
            case 'notifications':
                this.openNotifications();
                break;
            case 'clear-filters':
                this.clearFilters();
                break;
            case 'refresh-users':
                this.loadAllUsers();
                break;
            case 'toggle-user':
                this.handleToggleUser(event);
                break;
            case 'delete-user':
                this.handleDeleteUser(event);
                break;
            default:
                console.log('Unknown action:', action);
        }
    },

    // Check authentication
    checkAuth: function() {
        setTimeout(() => {
            try {
                const userData = LunaCore.getCurrentUser();
                const token = localStorage.getItem('luna_token');
                
                console.log('Auth check - User data:', userData);
                console.log('Auth check - Token:', token);
                
                if (!userData || !token) {
                    console.log('No user data or token found, redirecting to login');
                    window.location.href = '../../index.html';
                    return;
                }
                
                // Check if user is Super Admin
                if (userData.role !== 'Super Admin') {
                    console.log('User is not Super Admin, redirecting');
                    alert('Anda tidak memiliki akses ke halaman ini!');
                    window.location.href = '../../index.html';
                    return;
                }
                
                console.log('Authentication successful for Super Admin');
                
                // Update user info
                this.updateUserInfo(userData);
                
                // Initialize dashboard after successful auth
                if (typeof LunaSuperAdmin !== 'undefined') {
                    LunaSuperAdmin.init();
                }
            } catch (error) {
                console.error('Error in authentication check:', error);
                // Don't redirect immediately on error, give it another try
                setTimeout(() => {
                    const userData = LunaCore.getCurrentUser();
                    const token = localStorage.getItem('luna_token');
                    if (!userData || !token) {
                        window.location.href = '../../index.html';
                    }
                }, 1000);
            }
        }, 500);
    },

    // Update user information in header
    updateUserInfo: function(userData) {
        const userDetailsElement = document.querySelector('.user-details h6');
        const userRoleElement = document.querySelector('.user-details small');
        
        if (userDetailsElement) {
            userDetailsElement.textContent = userData.nama_lengkap || userData.username;
        }
        if (userRoleElement) {
            userRoleElement.textContent = userData.role;
        }
    },

    // Handle logout
    handleLogout: function() {
        if (confirm('Apakah Anda yakin ingin logout?')) {
            LunaCore.logout();
        }
    },

    // Modal functions
    openUserManagement: function() {
        const modal = new bootstrap.Modal(document.getElementById('userManagementModal'));
        modal.show();
        this.loadAllUsers();
    },

    openServerManagement: function() {
        alert('Fitur Manajemen Server akan segera hadir!');
    },

    openFinancialReport: function() {
        alert('Fitur Laporan Keuangan akan segera hadir!');
    },

    openSystemSettings: function() {
        alert('Fitur Pengaturan Sistem akan segera hadir!');
    },

    openNotifications: function() {
        alert('Fitur Notifikasi akan segera hadir!');
    },

    // Clear filters
    clearFilters: function() {
        const roleFilter = document.getElementById('filterRole');
        const statusFilter = document.getElementById('filterStatus');
        const searchInput = document.getElementById('searchUser');
        
        if (roleFilter) roleFilter.value = '';
        if (statusFilter) statusFilter.value = '';
        if (searchInput) searchInput.value = '';
        
        // Reload all users
        this.loadAllUsers();
    },

    // Handle toggle user status
    handleToggleUser: function(event) {
        const userId = event.target.dataset.userId;
        const newStatus = event.target.dataset.status === 'true';
        const statusText = newStatus ? 'mengaktifkan' : 'menonaktifkan';
        
        if (!confirm(`Apakah Anda yakin ingin ${statusText} user ini?`)) {
            return;
        }
        
        LunaCore.apiCall('toggle_user_status.php', 'POST', {
            user_id: userId,
            is_active: newStatus
        })
        .then(result => {
            if (result.success) {
                alert(`User berhasil ${statusText}!`);
                this.loadAllUsers(); // Refresh table
                this.refreshStatistics(); // Refresh statistics
            } else {
                alert('Error: ' + result.error);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Terjadi kesalahan koneksi');
        });
    },

    // Handle delete user
    handleDeleteUser: function(event) {
        const userId = event.target.dataset.userId;
        const userName = event.target.dataset.userName;
        
        if (!confirm(`Apakah Anda yakin ingin menghapus user "${userName}"? Tindakan ini tidak dapat dibatalkan!`)) {
            return;
        }
        
        LunaCore.apiCall('delete_user.php', 'POST', {
            user_id: userId
        })
        .then(result => {
            if (result.success) {
                alert('User berhasil dihapus!');
                this.loadAllUsers(); // Refresh table
                this.refreshStatistics(); // Refresh statistics
            } else {
                alert('Error: ' + result.error);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Terjadi kesalahan koneksi');
        });
    },

    openAddBosModal: function() {
        const modal = new bootstrap.Modal(document.getElementById('addBosModal'));
        
        // Clear phone status when modal opens
        const phoneStatusDiv = document.getElementById('phoneStatus');
        if (phoneStatusDiv) {
            phoneStatusDiv.style.display = 'none';
            phoneStatusDiv.innerHTML = '';
        }
        
        modal.show();
        
        // Add event listener to clear status when modal is hidden
        const modalElement = document.getElementById('addBosModal');
        if (modalElement) {
            modalElement.addEventListener('hidden.bs.modal', function() {
                const phoneStatusDiv = document.getElementById('phoneStatus');
                if (phoneStatusDiv) {
                    phoneStatusDiv.style.display = 'none';
                    phoneStatusDiv.innerHTML = '';
                }
                if (typeof lastCheckedPhone !== 'undefined') {
                    lastCheckedPhone = '';
                }
            });
        }
    },

    // Handle add BOS form submission
    handleAddBos: function() {
        const form = document.getElementById('addBosForm');
        
        // Basic form validation
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }

        // Get form data
        const formData = new FormData(form);
        const bosData = {
            telepon: formData.get('telepon'),
            whatsapp: formData.get('whatsapp'),
            provinsi_id: formData.get('provinsi_id'),
            kabupaten_kota_id: formData.get('kabupaten_kota_id'),
            kecamatan_id: formData.get('kecamatan_id'),
            kelurahan_desa_id: formData.get('kelurahan_desa_id'),
            nama_depan: formData.get('nama_depan'),
            nama_belakang: formData.get('nama_belakang'),
            jenis_kelamin: formData.get('jenis_kelamin'),
            username: formData.get('username'),
            password: formData.get('password')
        };

        // Show loading state
        const submitBtn = form.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Menyimpan...';
        submitBtn.disabled = true;

        // Call API
        LunaCore.apiCall('add_bos.php', 'POST', bosData)
        .then(result => {
            if (result.success) {
                // Show success message
                alert('Bos berhasil ditambahkan!\n\nUsername: ' + result.data.username + '\nPassword: ' + result.data.password + '\nNama: ' + result.data.nama_depan + '\n\nPassword wajib diganti saat login pertama kali!');
                
                // Close modal and reset form
                const modal = bootstrap.Modal.getInstance(document.getElementById('addBosModal'));
                if (modal) {
                    modal.hide();
                }
                
                // Reset form
                if (form) {
                    form.reset();
                }
                
                // Reset address dropdowns
                this.resetAllAddressDropdowns();

                // Refresh BOS statistics
                this.refreshStatistics();
            } else {
                alert('Error: ' + (result.error || 'Terjadi kesalahan tidak diketahui'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Terjadi kesalahan koneksi: ' + error.message);
        })
        .finally(() => {
            // Reset button state
            if (submitBtn) {
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }
        });
    },

    // Refresh statistics
    refreshStatistics: function() {
        if (typeof LunaSuperAdmin !== 'undefined' && LunaSuperAdmin.loadStatistics) {
            LunaSuperAdmin.loadStatistics();
        } else {
            // Manual refresh as fallback
            console.log('LunaSuperAdmin not available, using manual refresh...');
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        }
    },

    // Reset address dropdowns
    resetAllAddressDropdowns: function() {
        const dropdowns = ['kabupaten_kota_id', 'kecamatan_id', 'kelurahan_desa_id'];
        dropdowns.forEach(id => {
            const select = document.getElementById(id);
            if (select) {
                select.innerHTML = '<option value="">Pilih...</option>';
                select.disabled = true;
            }
        });
    },

    // Load all users
    loadAllUsers: function() {
        const tbody = document.getElementById('userTableBody');
        if (!tbody) return;
        
        tbody.innerHTML = '<tr><td colspan="8" class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading...</td></tr>';
        
        LunaCore.getAllUsers()
            .then(result => {
                if (result.success) {
                    this.displayAllUsers(result.data);
                    window.allUsersData = result.data; // Store for filtering
                } else {
                    tbody.innerHTML = '<tr><td colspan="8" class="text-center text-danger">Error: ' + result.error + '</td></tr>';
                }
            })
            .catch(error => {
                console.error('Error loading users data:', error);
                tbody.innerHTML = '<tr><td colspan="8" class="text-center text-danger">Error loading data</td></tr>';
            });
    },

    // Display all users
    displayAllUsers: function(usersList) {
        const tbody = document.getElementById('userTableBody');
        if (!tbody) return;
        
        if (usersList.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center">Tidak ada data user</td></tr>';
            return;
        }
        
        let html = '';
        usersList.forEach(user => {
            const statusBadge = user.is_active ? 
                '<span class="badge bg-success">Aktif</span>' : 
                '<span class="badge bg-danger">Tidak Aktif</span>';
            
            const roleBadge = this.getRoleBadge(user.role);
            const actionButtons = this.getActionButtons(user);
            
            html += `
                <tr>
                    <td>${user.id}</td>
                    <td>${user.username}</td>
                    <td>${user.nama_lengkap}</td>
                    <td>${user.telepon}</td>
                    <td>${roleBadge}</td>
                    <td>${statusBadge}</td>
                    <td>${user.created_at}</td>
                    <td>${actionButtons}</td>
                </tr>
            `;
        });
        
        tbody.innerHTML = html;
    },

    // Get role badge
    getRoleBadge: function(role) {
        const roleColors = {
            'Super Admin': 'bg-danger',
            'Bos': 'bg-primary',
            'Admin Bos': 'bg-info',
            'Transporter': 'bg-warning',
            'Penjual': 'bg-success',
            'Pembeli': 'bg-secondary'
        };
        
        return `<span class="badge ${roleColors[role] || 'bg-secondary'}">${role}</span>`;
    },

    // Get action buttons
    getActionButtons: function(user) {
        let buttons = '';
        
        // Super Admin tidak boleh diubah/dihapus
        if (user.role === 'Super Admin') {
            return '<span class="text-muted">Tidak dapat diubah</span>';
        }
        
        // Toggle status button
        const toggleButton = user.is_active ?
            `<button class="btn btn-sm btn-outline-warning" data-action="toggle-user" data-user-id="${user.id}" data-status="false">Nonaktifkan</button>` :
            `<button class="btn btn-sm btn-outline-success" data-action="toggle-user" data-user-id="${user.id}" data-status="true">Aktifkan</button>`;
        
        buttons += toggleButton + ' ';
        
        // Delete button
        buttons += `<button class="btn btn-sm btn-outline-danger" data-action="delete-user" data-user-id="${user.id}" data-user-name="${user.nama_lengkap}">Hapus</button>`;
        
        return buttons;
    }
};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    LunaDashboard.init();
}); 