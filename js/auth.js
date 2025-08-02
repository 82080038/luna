// =====================================================
// AUTHENTICATION MODULE - Handles login, register, forgot password
// =====================================================

const LunaAuth = {
    // Initialize authentication module
    init: function() {
        this.bindEvents();
        this.initPasswordStrength();
    },

    // Bind all event listeners
    bindEvents: function() {
        // Tab switching
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-tab]')) {
                e.preventDefault();
                this.switchTab(e.target.dataset.tab);
            }
        });

        // Password toggle
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-toggle-password]')) {
                this.togglePassword(e.target.dataset.togglePassword);
            }
        });

        // Form submissions
        document.getElementById('login-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        document.getElementById('register-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleRegister();
        });

        document.getElementById('forgot-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleForgotPassword();
        });
    },

    // Switch between tabs
    switchTab: function(tab) {
        // Hide all forms
        document.querySelectorAll('.auth-form').forEach(form => {
            form.classList.remove('active');
        });
        
        // Remove active class from all tabs
        document.querySelectorAll('.auth-tab').forEach(tabEl => {
            tabEl.classList.remove('active');
        });
        
        // Show selected form
        if (tab === 'login') {
            document.getElementById('login-form').classList.add('active');
            document.querySelector('.auth-tab[data-tab="login"]').classList.add('active');
            document.querySelector('.auth-tabs').style.display = 'flex';
        } else if (tab === 'register') {
            document.getElementById('register-form').classList.add('active');
            document.querySelector('.auth-tab[data-tab="register"]').classList.add('active');
            document.querySelector('.auth-tabs').style.display = 'flex';
        } else if (tab === 'forgot') {
            document.getElementById('forgot-form').classList.add('active');
            document.querySelector('.auth-tabs').style.display = 'none';
        }
        
        // Clear any existing messages
        this.clearMessages();
    },

    // Toggle password visibility
    togglePassword: function(inputId) {
        const input = document.getElementById(inputId);
        const icon = input.nextElementSibling;
        
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'fas fa-eye-slash input-group-icon';
        } else {
            input.type = 'password';
            icon.className = 'fas fa-eye input-group-icon';
        }
    },

    // Initialize password strength checker
    initPasswordStrength: function() {
        const passwordInput = document.getElementById('register-password');
        if (passwordInput) {
            passwordInput.addEventListener('input', (e) => {
                this.checkPasswordStrength(e.target.value);
            });
        }
    },

    // Check password strength
    checkPasswordStrength: function(password) {
        const strengthBar = document.getElementById('password-strength');
        if (!strengthBar) return;
        
        let strength = 0;
        if (password.length >= 8) strength++;
        if (/[a-z]/.test(password)) strength++;
        if (/[A-Z]/.test(password)) strength++;
        if (/[0-9]/.test(password)) strength++;
        if (/[^A-Za-z0-9]/.test(password)) strength++;
        
        strengthBar.className = 'strength-fill';
        if (strength <= 1) strengthBar.classList.add('strength-weak');
        else if (strength <= 2) strengthBar.classList.add('strength-fair');
        else if (strength <= 3) strengthBar.classList.add('strength-good');
        else strengthBar.classList.add('strength-strong');
    },

    // Handle login form submission
    handleLogin: async function() {
        const username = document.getElementById('login-username').value;
        const password = document.getElementById('login-password').value;
        
        if (!username || !password) {
            this.showError('Username dan password harus diisi');
            return;
        }
        
        const btn = document.getElementById('login-btn');
        const originalText = btn.innerHTML;
        this.setButtonLoading(btn, true);
        
        try {
            const response = await fetch('api/auth_login.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ username, password })
            });
            
            const data = await response.json();
            
            if (data.success) {
                // Set user data
                LunaUtils.setCurrentUser(data.data.user);
                localStorage.setItem('luna_token', data.data.token);
                
                this.showSuccess('Login berhasil! Redirecting...');
                
                // Check if this is first login
                if (data.data.is_first_login) {
                    setTimeout(() => {
                        window.location.href = 'change_password.html';
                    }, 1500);
                } else {
                    setTimeout(() => {
                        this.redirectBasedOnRole(data.data.user.role);
                    }, 1500);
                }
            } else {
                this.showError(data.error || 'Login gagal');
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showError('Terjadi kesalahan saat login');
        } finally {
            this.setButtonLoading(btn, false, originalText);
        }
    },

    // Handle register form submission
    handleRegister: async function() {
        const name = document.getElementById('register-name').value;
        const username = document.getElementById('register-username').value;
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;
        const confirmPassword = document.getElementById('register-confirm-password').value;
        
        if (!name || !username || !email || !password || !confirmPassword) {
            this.showError('Semua field harus diisi');
            return;
        }
        
        if (password !== confirmPassword) {
            this.showError('Password tidak cocok');
            return;
        }
        
        if (password.length < 8) {
            this.showError('Password minimal 8 karakter');
            return;
        }
        
        const btn = document.getElementById('register-btn');
        const originalText = btn.innerHTML;
        this.setButtonLoading(btn, true);
        
        try {
            // Simulate API call
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            this.showSuccess('Register berhasil! Silakan login.');
            this.switchTab('login');
        } catch (error) {
            this.showError('Terjadi kesalahan saat register');
        } finally {
            this.setButtonLoading(btn, false, originalText);
        }
    },

    // Handle forgot password form submission
    handleForgotPassword: async function() {
        const email = document.getElementById('forgot-email').value;
        
        if (!email) {
            this.showError('Email harus diisi');
            return;
        }
        
        const btn = document.getElementById('forgot-btn');
        const originalText = btn.innerHTML;
        this.setButtonLoading(btn, true);
        
        try {
            // Simulate API call
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            this.showSuccess('Reset link telah dikirim ke email Anda');
        } catch (error) {
            this.showError('Terjadi kesalahan saat mengirim reset link');
        } finally {
            this.setButtonLoading(btn, false, originalText);
        }
    },

    // Set button loading state
    setButtonLoading: function(btn, loading, originalText = null) {
        if (loading) {
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Loading...';
            btn.disabled = true;
        } else {
            btn.innerHTML = originalText || btn.innerHTML;
            btn.disabled = false;
        }
    },

    // Show error message
    showError: function(message) {
        this.clearMessages();
        
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.style.display = 'block';
        errorDiv.textContent = message;
        
        const activeForm = document.querySelector('.auth-form.active');
        if (activeForm) {
            activeForm.appendChild(errorDiv);
        }
    },

    // Show success message
    showSuccess: function(message) {
        this.clearMessages();
        
        const successDiv = document.createElement('div');
        successDiv.className = 'success-message';
        successDiv.style.display = 'block';
        successDiv.textContent = message;
        
        const activeForm = document.querySelector('.auth-form.active');
        if (activeForm) {
            activeForm.appendChild(successDiv);
        }
    },

    // Clear all messages
    clearMessages: function() {
        document.querySelectorAll('.error-message, .success-message').forEach(msg => msg.remove());
    },

    // Redirect based on user role
    redirectBasedOnRole: function(role) {
        const roleRoutes = {
            'Super Admin': 'dashboards/super_admin/index.html',
            'Bos': 'dashboards/bos/index.html',
            'Admin Bos': 'dashboards/admin_bos/index.html',
            'Transporter': 'dashboards/transporter/index.html',
            'Penjual': 'dashboards/penjual/index.html',
            'Pembeli': 'dashboards/pembeli/index.html'
        };
        
        const route = roleRoutes[role] || 'dashboards/super_admin/index.html';
        window.location.href = route;
    }
};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    LunaAuth.init();
}); 