// =====================================================
// CORE FUNCTIONS - Shared across all roles
// =====================================================

const LunaCore = {
    // API utility functions
    apiCall: async function(endpoint, method = 'GET', data = null) {
        try {
            // Get current path to determine correct API base URL
            const currentPath = window.location.pathname;
            let baseUrl = '';
            
            // Determine base URL based on current path
            if (currentPath.includes('/dashboards/')) {
                baseUrl = '../../api';
            } else {
                baseUrl = 'api';
            }
            
            // Remove leading slash from endpoint if it exists
            const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
            const fullUrl = `${baseUrl}/${cleanEndpoint}`;
            
            console.log(`API Call: ${method} ${fullUrl}`);
            
            const options = {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                }
            };

            if (data && (method === 'POST' || method === 'PUT')) {
                options.body = JSON.stringify(data);
                console.log('Request data:', data);
            }

            const response = await fetch(fullUrl, options);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            console.log('API Response:', result);
            
            return result;
        } catch (error) {
            console.error('API Error:', error);
            console.error('Failed URL:', fullUrl);
            throw error;
        }
    },

    // User data functions
    getUserData: async function(userId) {
        try {
            const response = await this.apiCall(`get_user_data.php?id=${userId}`);
            return response;
        } catch (error) {
            console.error('Error getting user data:', error);
            throw error;
        }
    },

    // Address functions
    getProvinces: async function() {
        try {
            const response = await this.apiCall('get_provinsi.php');
            return response;
        } catch (error) {
            console.error('Error getting provinces:', error);
            throw error;
        }
    },

    getKabupaten: async function(provinceId) {
        try {
            const response = await this.apiCall(`get_kabupaten.php?provinsi_id=${provinceId}`);
            return response;
        } catch (error) {
            console.error('Error getting kabupaten:', error);
            throw error;
        }
    },

    getKecamatan: async function(kabupatenId) {
        try {
            const response = await this.apiCall(`get_kecamatan.php?kabupaten_id=${kabupatenId}`);
            return response;
        } catch (error) {
            console.error('Error getting kecamatan:', error);
            throw error;
        }
    },

    getKelurahan: async function(kecamatanId) {
        try {
            const response = await this.apiCall(`get_kelurahan.php?kecamatan_id=${kecamatanId}`);
            return response;
        } catch (error) {
            console.error('Error getting kelurahan:', error);
            throw error;
        }
    },

    // Address validation
    validateAddress: async function(addressData) {
        try {
            const response = await this.apiCall('validate_address.php', 'POST', addressData);
            return response;
        } catch (error) {
            console.error('Error validating address:', error);
            throw error;
        }
    },

    // User management functions
    getAllUsers: async function() {
        try {
            const response = await this.apiCall('get_all_users.php');
            return response;
        } catch (error) {
            console.error('Error getting all users:', error);
            throw error;
        }
    },

    toggleUserStatus: async function(userId) {
        try {
            const response = await this.apiCall('toggle_user_status.php', 'POST', { user_id: userId });
            return response;
        } catch (error) {
            console.error('Error toggling user status:', error);
            throw error;
        }
    },

    deleteUser: async function(userId) {
        try {
            const response = await this.apiCall('delete_user.php', 'POST', { user_id: userId });
            return response;
        } catch (error) {
            console.error('Error deleting user:', error);
            throw error;
        }
    },

    // Password functions
    changePassword: async function(passwordData) {
        try {
            const response = await this.apiCall('change_password.php', 'POST', passwordData);
            return response;
        } catch (error) {
            console.error('Error changing password:', error);
            throw error;
        }
    },

    // Check user completeness
    checkUserCompleteness: async function(userId) {
        try {
            const response = await this.apiCall(`check_user_completeness.php?user_id=${userId}`);
            return response;
        } catch (error) {
            console.error('Error checking user completeness:', error);
            throw error;
        }
    },

    // Check first login
    checkFirstLogin: async function(userId) {
        try {
            const response = await this.apiCall(`check_first_login.php?user_id=${userId}`);
            return response;
        } catch (error) {
            console.error('Error checking first login:', error);
            throw error;
        }
    },

    // Check phone number
    checkPhoneNumber: async function(phoneNumber) {
        try {
            const response = await this.apiCall(`check_telepon.php?telepon=${phoneNumber}`);
            return response;
        } catch (error) {
            console.error('Error checking phone number:', error);
            throw error;
        }
    },

    // Utility functions
    showNotification: function(message, type = 'info') {
        // Implementation for showing notifications
        console.log(`${type.toUpperCase()}: ${message}`);
    },

    showLoading: function(show = true) {
        // Implementation for showing/hiding loading spinner
        const loader = document.getElementById('loading-spinner');
        if (loader) {
            loader.style.display = show ? 'block' : 'none';
        }
    },

    formatCurrency: function(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR'
        }).format(amount);
    },

    formatDate: function(date) {
        return new Intl.DateTimeFormat('id-ID', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date(date));
    },

    // Authentication functions
    getCurrentUser: function() {
        try {
            const userData = localStorage.getItem('luna_current_user');
            return userData ? JSON.parse(userData) : null;
        } catch (error) {
            console.error('Error getting current user:', error);
            return null;
        }
    },

    checkAuth: function() {
        const userData = this.getCurrentUser();
        const token = localStorage.getItem('luna_token');
        return !!(userData && token);
    },

    logout: function() {
        localStorage.removeItem('luna_current_user');
        localStorage.removeItem('luna_token');
        
        // Get current path to determine correct redirect URL
        const currentPath = window.location.pathname;
        let redirectUrl = '';
        
        if (currentPath.includes('/dashboards/')) {
            redirectUrl = '../../index.html';
        } else {
            redirectUrl = 'index.html';
        }
        
        window.location.href = redirectUrl;
    },

    redirect: function(url) {
        window.location.href = url;
    }
};

// =====================================================
// COMPATIBILITY LAYER - For backward compatibility
// =====================================================

// LunaAuth compatibility
const LunaAuth = {
    checkAuth: function() {
        return LunaCore.checkAuth();
    },
    
    getCurrentUser: function() {
        return LunaCore.getCurrentUser();
    },
    
    logout: function() {
        return LunaCore.logout();
    }
};

// LunaUtils compatibility
const LunaUtils = {
    getCurrentUser: function() {
        return LunaCore.getCurrentUser();
    },
    
    setCurrentUser: function(user) {
        localStorage.setItem('luna_current_user', JSON.stringify(user));
    },
    
    checkAuth: function() {
        return LunaCore.checkAuth();
    },
    
    logout: function() {
        return LunaCore.logout();
    },
    
    redirect: function(url) {
        return LunaCore.redirect(url);
    }
};

// =====================================================
// COMMON UI FUNCTIONS
// =====================================================

const LunaUI = {
    // Modal functions
    openModal: function(modalId) {
        const modal = new bootstrap.Modal(document.getElementById(modalId));
        modal.show();
    },

    closeModal: function(modalId) {
        const modal = bootstrap.Modal.getInstance(document.getElementById(modalId));
        if (modal) {
            modal.hide();
        }
    },

    // Table functions
    refreshTable: function(tableId) {
        const table = document.getElementById(tableId);
        if (table) {
            // Trigger table refresh event
            const event = new CustomEvent('tableRefresh', { detail: { tableId } });
            document.dispatchEvent(event);
        }
    },

    // Form functions
    resetForm: function(formId) {
        const form = document.getElementById(formId);
        if (form) {
            form.reset();
        }
    },

    validateForm: function(formId) {
        const form = document.getElementById(formId);
        if (form) {
            return form.checkValidity();
        }
        return false;
    },

    // Dropdown functions
    populateDropdown: function(dropdownId, data, valueKey = 'id', textKey = 'name') {
        const dropdown = document.getElementById(dropdownId);
        if (dropdown) {
            dropdown.innerHTML = '<option value="">Pilih...</option>';
            data.forEach(item => {
                const option = document.createElement('option');
                option.value = item[valueKey];
                option.textContent = item[textKey];
                dropdown.appendChild(option);
            });
        }
    }
}; 