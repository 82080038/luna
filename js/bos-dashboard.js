// =====================================================
// BOS DASHBOARD - JAVASCRIPT FUNCTIONALITY
// Luna System - Bos Role Management
// =====================================================

// Global variables for Bos Dashboard
let currentBosTab = 'overview';
let bosData = {
    servers: [],
    sessions: [],
    adminBos: [],
    transporters: [],
    financialData: {}
};

// =====================================================
// INITIALIZATION
// =====================================================

document.addEventListener('DOMContentLoaded', function() {
    // Check if user is logged in and has Bos role
    const currentUser = LunaUtils.getCurrentUser();
    if (!currentUser || currentUser.role !== 'Bos') {
        window.location.href = 'index.html';
        return;
    }
    
    // Initialize dashboard
    initBosDashboard();
    loadBosOverviewData();
});

// =====================================================
// DASHBOARD INITIALIZATION
// =====================================================

function initBosDashboard() {
    const currentUser = LunaUtils.getCurrentUser();
    
    // Update user info
    document.getElementById('bos-name').textContent = currentUser.name || 'Bos Dashboard';
    
    // Initialize event listeners
    setupEventListeners();
    
    // Load initial data
    loadDashboardStats();
}

function setupEventListeners() {
    // Filter event listeners
    const filterServer = document.getElementById('filter-server');
    const filterStatus = document.getElementById('filter-status');
    
    if (filterServer) {
        filterServer.addEventListener('change', filterSessions);
    }
    
    if (filterStatus) {
        filterStatus.addEventListener('change', filterSessions);
    }
}

// =====================================================
// TAB SWITCHING
// =====================================================

function switchBosTab(tabName) {
    // Remove active class from all tabs
    document.querySelectorAll('#bos-nav .nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Add active class to selected tab
    event.target.classList.add('active');
    document.getElementById(tabName + '-tab').classList.add('active');
    
    currentBosTab = tabName;
    
    // Load tab-specific data
    switch(tabName) {
        case 'overview':
            loadBosOverviewData();
            break;
        case 'servers':
            loadServersData();
            break;
        case 'sessions':
            loadSessionsData();
            break;
        case 'admin-bos':
            loadAdminBosData();
            break;
        case 'finance':
            loadFinanceData();
            break;
        case 'transporter':
            loadTransporterData();
            break;
    }
}

// =====================================================
// DATA LOADING FUNCTIONS
// =====================================================

async function loadDashboardStats() {
    try {
        const response = await fetch('api/bos_dashboard_stats.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
            }
        });
        
        const result = await response.json();
        
        if (result.success) {
            updateDashboardStats(result.data);
        } else {
            console.error('Failed to load dashboard stats:', result.error);
        }
    } catch (error) {
        console.error('Error loading dashboard stats:', error);
        // Show fallback data
        updateDashboardStats({
            total_servers: 0,
            active_sessions: 0,
            total_users: 0,
            total_revenue: 0
        });
    }
}

function updateDashboardStats(data) {
    document.getElementById('total-servers').textContent = data.total_servers || 0;
    document.getElementById('active-sessions').textContent = data.active_sessions || 0;
    document.getElementById('total-users').textContent = data.total_users || 0;
    document.getElementById('total-revenue').textContent = LunaUtils.formatCurrency(data.total_revenue || 0);
}

async function loadBosOverviewData() {
    try {
        // Load recent activities
        loadRecentActivities();
        
        // Load server status
        loadServerStatus();
        
    } catch (error) {
        console.error('Error loading overview data:', error);
    }
}

async function loadRecentActivities() {
    try {
        const response = await fetch('api/bos_recent_activities.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
            }
        });
        
        const result = await response.json();
        
        if (result.success && result.data) {
            displayRecentActivities(result.data);
        } else {
            displayNoActivities();
        }
    } catch (error) {
        console.error('Error loading recent activities:', error);
        displayNoActivities();
    }
}

function displayRecentActivities(activities) {
    const container = document.getElementById('recent-activities');
    
    if (!activities || activities.length === 0) {
        displayNoActivities();
        return;
    }
    
    const html = activities.map(activity => `
        <div class="activity-item d-flex align-items-center mb-3">
            <div class="activity-icon me-3">
                <i class="fas fa-${getActivityIcon(activity.type)} text-primary"></i>
            </div>
            <div class="activity-content flex-grow-1">
                <div class="activity-title">${activity.title}</div>
                <small class="text-muted">${LunaUtils.formatDate(activity.created_at)}</small>
            </div>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function displayNoActivities() {
    document.getElementById('recent-activities').innerHTML = `
        <div class="text-center py-4">
            <i class="fas fa-info-circle text-muted"></i>
            <p class="text-muted mt-2">Belum ada aktivitas terbaru</p>
        </div>
    `;
}

function getActivityIcon(type) {
    const icons = {
        'server_created': 'server',
        'session_created': 'clock',
        'user_added': 'user-plus',
        'transaction': 'money-bill-wave',
        'login': 'sign-in-alt'
    };
    return icons[type] || 'info-circle';
}

async function loadServerStatus() {
    try {
        const response = await fetch('api/bos_server_status.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
            }
        });
        
        const result = await response.json();
        
        if (result.success && result.data) {
            displayServerStatus(result.data);
        } else {
            displayNoServerStatus();
        }
    } catch (error) {
        console.error('Error loading server status:', error);
        displayNoServerStatus();
    }
}

function displayServerStatus(servers) {
    const container = document.getElementById('server-status');
    
    if (!servers || servers.length === 0) {
        displayNoServerStatus();
        return;
    }
    
    const html = servers.map(server => `
        <div class="server-status-item d-flex justify-content-between align-items-center mb-2">
            <div>
                <div class="fw-bold">${server.nama_server}</div>
                <small class="text-muted">${server.lokasi}</small>
            </div>
            <span class="badge bg-${server.status === 'active' ? 'success' : 'secondary'}">
                ${server.status === 'active' ? 'Aktif' : 'Tidak Aktif'}
            </span>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function displayNoServerStatus() {
    document.getElementById('server-status').innerHTML = `
        <div class="text-center py-4">
            <i class="fas fa-server text-muted"></i>
            <p class="text-muted mt-2">Belum ada server</p>
        </div>
    `;
}

// =====================================================
// SERVERS MANAGEMENT
// =====================================================

async function loadServersData() {
    try {
        showTableLoading('servers-list', 6);
        
        const response = await fetch('api/bos_servers.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
            }
        });
        
        const result = await response.json();
        
        if (result.success && result.data) {
            bosData.servers = result.data;
            displayServersTable(result.data);
        } else {
            displayNoServers();
        }
    } catch (error) {
        console.error('Error loading servers:', error);
        displayNoServers();
    }
}

function displayServersTable(servers) {
    const tbody = document.getElementById('servers-list');
    
    if (!servers || servers.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" class="text-center py-4">
                    <i class="fas fa-server text-muted"></i>
                    <p class="text-muted mt-2">Belum ada server</p>
                </td>
            </tr>
        `;
        return;
    }
    
    const html = servers.map(server => `
        <tr>
            <td>
                <div class="fw-bold">${server.nama_server}</div>
                <small class="text-muted">${server.kode_server || '-'}</small>
            </td>
            <td>${server.lokasi}</td>
            <td>
                <span class="badge bg-${server.status === 'active' ? 'success' : 'secondary'}">
                    ${server.status === 'active' ? 'Aktif' : 'Tidak Aktif'}
                </span>
            </td>
            <td>${server.active_sessions || 0}</td>
            <td>${server.total_users || 0}</td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="editServer(${server.id})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-outline-info" onclick="viewServerDetails(${server.id})">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-outline-danger" onclick="deleteServer(${server.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
    
    tbody.innerHTML = html;
}

function displayNoServers() {
    document.getElementById('servers-list').innerHTML = `
        <tr>
            <td colspan="6" class="text-center py-4">
                <i class="fas fa-server text-muted"></i>
                <p class="text-muted mt-2">Belum ada server. <a href="#" onclick="openAddServerModal()">Tambah server pertama</a></p>
            </td>
        </tr>
    `;
}

// =====================================================
// SESSIONS MANAGEMENT
// =====================================================

async function loadSessionsData() {
    try {
        showTableLoading('sessions-list', 7);
        
        // Load servers for filter
        await loadServerFilter();
        
        const response = await fetch('api/bos_sessions.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
            }
        });
        
        const result = await response.json();
        
        if (result.success && result.data) {
            bosData.sessions = result.data;
            displaySessionsTable(result.data);
        } else {
            displayNoSessions();
        }
    } catch (error) {
        console.error('Error loading sessions:', error);
        displayNoSessions();
    }
}

async function loadServerFilter() {
    const filterSelect = document.getElementById('filter-server');
    if (!filterSelect) return;
    
    // Clear existing options except first
    filterSelect.innerHTML = '<option value="">Semua Server</option>';
    
    if (bosData.servers.length === 0) {
        // Load servers if not already loaded
        try {
            const response = await fetch('api/bos_servers.php', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + LunaUtils.getCurrentUser()?.session_token
                }
            });
            
            const result = await response.json();
            if (result.success && result.data) {
                bosData.servers = result.data;
            }
        } catch (error) {
            console.error('Error loading servers for filter:', error);
        }
    }
    
    // Add server options
    bosData.servers.forEach(server => {
        const option = document.createElement('option');
        option.value = server.id;
        option.textContent = server.nama_server;
        filterSelect.appendChild(option);
    });
}

function displaySessionsTable(sessions) {
    const tbody = document.getElementById('sessions-list');
    
    if (!sessions || sessions.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <i class="fas fa-clock text-muted"></i>
                    <p class="text-muted mt-2">Belum ada sesi</p>
                </td>
            </tr>
        `;
        return;
    }
    
    const html = sessions.map(session => `
        <tr>
            <td>${session.server_name}</td>
            <td>${LunaUtils.formatDate(session.tanggal_sesi)}</td>
            <td>${session.jam_buka}</td>
            <td>${session.jam_tutup}</td>
            <td>
                <span class="badge bg-${getSessionStatusColor(session.status)}">
                    ${getSessionStatusText(session.status)}
                </span>
            </td>
            <td>${session.total_bets || 0}</td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="editSession(${session.id})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-outline-info" onclick="viewSessionDetails(${session.id})">
                        <i class="fas fa-eye"></i>
                    </button>
                    ${session.status === 'upcoming' ? 
                        `<button class="btn btn-outline-danger" onclick="deleteSession(${session.id})">
                            <i class="fas fa-trash"></i>
                        </button>` : ''
                    }
                </div>
            </td>
        </tr>
    `).join('');
    
    tbody.innerHTML = html;
}

function getSessionStatusColor(status) {
    const colors = {
        'upcoming': 'secondary',
        'active': 'success',
        'closed': 'warning',
        'finished': 'info'
    };
    return colors[status] || 'secondary';
}

function getSessionStatusText(status) {
    const texts = {
        'upcoming': 'Akan Datang',
        'active': 'Aktif',
        'closed': 'Tutup',
        'finished': 'Selesai'
    };
    return texts[status] || status;
}

function filterSessions() {
    const serverFilter = document.getElementById('filter-server').value;
    const statusFilter = document.getElementById('filter-status').value;
    
    let filteredSessions = bosData.sessions;
    
    if (serverFilter) {
        filteredSessions = filteredSessions.filter(session => 
            session.server_id == serverFilter
        );
    }
    
    if (statusFilter) {
        filteredSessions = filteredSessions.filter(session => 
            session.status === statusFilter
        );
    }
    
    displaySessionsTable(filteredSessions);
}

function displayNoSessions() {
    document.getElementById('sessions-list').innerHTML = `
        <tr>
            <td colspan="7" class="text-center py-4">
                <i class="fas fa-clock text-muted"></i>
                <p class="text-muted mt-2">Belum ada sesi. <a href="#" onclick="openAddSessionModal()">Buat sesi pertama</a></p>
            </td>
        </tr>
    `;
}

// =====================================================
// UTILITY FUNCTIONS
// =====================================================

function showTableLoading(tableBodyId, colspan) {
    const tbody = document.getElementById(tableBodyId);
    if (tbody) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${colspan}" class="text-center py-4">
                    <i class="fas fa-spinner fa-spin text-muted"></i>
                    <p class="text-muted mt-2">Memuat data...</p>
                </td>
            </tr>
        `;
    }
}

// =====================================================
// MODAL FUNCTIONS (Placeholders)
// =====================================================

function openAddServerModal() {
    LunaUtils.showToast('Fitur Tambah Server akan segera tersedia', 'info');
}

function openAddSessionModal() {
    LunaUtils.showToast('Fitur Tambah Sesi akan segera tersedia', 'info');
}

function openAddAdminBosModal() {
    LunaUtils.showToast('Fitur Tambah Admin Bos akan segera tersedia', 'info');
}

function openAddTransporterModal() {
    LunaUtils.showToast('Fitur Tambah Transporter akan segera tersedia', 'info');
}

function openDepositModal() {
    LunaUtils.showToast('Fitur Deposit akan segera tersedia', 'info');
}

function openWithdrawModal() {
    LunaUtils.showToast('Fitur Withdrawal akan segera tersedia', 'info');
}

function viewFinancialReport() {
    LunaUtils.showToast('Fitur Laporan Keuangan akan segera tersedia', 'info');
}

function openNotifications() {
    LunaUtils.showToast('Fitur Notifikasi akan segera tersedia', 'info');
}

// =====================================================
// ADMIN BOS MANAGEMENT (Placeholder)
// =====================================================

async function loadAdminBosData() {
    showTableLoading('admin-bos-list', 7);
    
    // Placeholder for now
    setTimeout(() => {
        document.getElementById('admin-bos-list').innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <i class="fas fa-users-cog text-muted"></i>
                    <p class="text-muted mt-2">Fitur manajemen Admin Bos akan segera tersedia</p>
                </td>
            </tr>
        `;
    }, 1000);
}

// =====================================================
// FINANCE MANAGEMENT (Placeholder)
// =====================================================

async function loadFinanceData() {
    // Placeholder for now
    document.getElementById('total-income').textContent = 'Rp 0';
    document.getElementById('total-expense').textContent = 'Rp 0';
    document.getElementById('available-balance').textContent = 'Rp 0';
    document.getElementById('pending-withdrawal').textContent = 'Rp 0';
    
    document.getElementById('recent-transactions').innerHTML = `
        <div class="text-center py-4">
            <i class="fas fa-money-bill-wave text-muted"></i>
            <p class="text-muted mt-2">Fitur keuangan akan segera tersedia</p>
        </div>
    `;
}

// =====================================================
// TRANSPORTER MANAGEMENT (Placeholder)
// =====================================================

async function loadTransporterData() {
    showTableLoading('transporter-list', 7);
    
    // Placeholder for now
    setTimeout(() => {
        document.getElementById('transporter-list').innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <i class="fas fa-truck text-muted"></i>
                    <p class="text-muted mt-2">Fitur manajemen Transporter akan segera tersedia</p>
                </td>
            </tr>
        `;
    }, 1000);
}