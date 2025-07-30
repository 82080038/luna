-- Database Schema for Bos Management Features
-- Luna System - Bos Role Management
-- Run this after database_optimized.sql

USE sistem_angka;

-- =====================================================
-- SERVER MANAGEMENT TABLES
-- =====================================================

-- Enhanced server table for Bos management
CREATE TABLE IF NOT EXISTS server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_server VARCHAR(100) NOT NULL,
    kode_server VARCHAR(20) UNIQUE NOT NULL,
    lokasi VARCHAR(100) NOT NULL,
    alamat_lengkap TEXT,
    
    -- Location details
    provinsi_id INT,
    kabupaten_kota_id INT,
    kecamatan_id INT,
    kelurahan_desa_id INT,
    
    -- Server configuration
    server_config JSON,
    maintenance_mode BOOLEAN DEFAULT FALSE,
    max_concurrent_sessions INT DEFAULT 10,
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    
    -- Ownership and permissions
    created_by INT NOT NULL,
    owner_id INT NOT NULL,
    status ENUM('active', 'inactive', 'maintenance') DEFAULT 'active',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_owner_id (owner_id),
    INDEX idx_created_by (created_by),
    INDEX idx_status (status),
    INDEX idx_kode_server (kode_server),
    
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (owner_id) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Bet types for each server
CREATE TABLE IF NOT EXISTS tipe_tebakan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    kode_tipe VARCHAR(10) NOT NULL,
    nama_tipe VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    hadiah_persen DECIMAL(5,2) NOT NULL,
    minimal_bet INT DEFAULT 1000,
    maksimal_bet INT DEFAULT 10000000,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_server_tipe (server_id, kode_tipe),
    INDEX idx_server_id (server_id),
    INDEX idx_is_active (is_active),
    
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- SESSION MANAGEMENT TABLES
-- =====================================================

-- Enhanced session server table
CREATE TABLE IF NOT EXISTS sesi_server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    nama_sesi VARCHAR(100) NOT NULL,
    tanggal_sesi DATE NOT NULL,
    jam_buka TIME NOT NULL,
    jam_tutup TIME NOT NULL,
    
    -- Session configuration
    auto_close BOOLEAN DEFAULT TRUE,
    allow_late_bets BOOLEAN DEFAULT FALSE,
    late_bet_cutoff_minutes INT DEFAULT 5,
    
    -- Results
    hasil_4d VARCHAR(4),
    hasil_3d VARCHAR(3), 
    hasil_2d VARCHAR(2),
    hasil_announced_at TIMESTAMP NULL,
    
    -- Status tracking
    status ENUM('upcoming', 'active', 'closed', 'finished', 'cancelled') DEFAULT 'upcoming',
    status_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_changed_by INT,
    
    -- Statistics
    total_bets INT DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    total_winners INT DEFAULT 0,
    total_payout DECIMAL(15,2) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    
    INDEX idx_server_id (server_id),
    INDEX idx_tanggal_sesi (tanggal_sesi),
    INDEX idx_status (status),
    INDEX idx_created_by (created_by),
    
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (status_changed_by) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================
-- USER HIERARCHY & MANAGEMENT
-- =====================================================

-- Enhanced user ownership for hierarchy management
ALTER TABLE user_ownership 
ADD COLUMN IF NOT EXISTS relationship_type VARCHAR(50) DEFAULT 'direct',
ADD COLUMN IF NOT EXISTS permissions JSON,
ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS assigned_by INT,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Add foreign key if not exists
ALTER TABLE user_ownership 
ADD CONSTRAINT IF NOT EXISTS fk_assigned_by 
FOREIGN KEY (assigned_by) REFERENCES user(id) ON DELETE SET NULL;

-- User permissions for fine-grained access control
CREATE TABLE IF NOT EXISTS user_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    permission_type VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id INT,
    can_create BOOLEAN DEFAULT FALSE,
    can_read BOOLEAN DEFAULT FALSE,
    can_update BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    granted_by INT NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    UNIQUE KEY unique_user_permission (user_id, permission_type, resource_type, resource_id),
    INDEX idx_user_id (user_id),
    INDEX idx_permission_type (permission_type),
    INDEX idx_resource (resource_type, resource_id),
    INDEX idx_granted_by (granted_by),
    
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (granted_by) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- FINANCIAL MANAGEMENT
-- =====================================================

-- Deposit and withdrawal transactions
CREATE TABLE IF NOT EXISTS financial_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal', 'transfer', 'commission', 'bonus', 'penalty') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    fee DECIMAL(15,2) DEFAULT 0,
    net_amount DECIMAL(15,2) NOT NULL,
    
    -- Transaction details
    reference_id VARCHAR(100),
    description TEXT,
    payment_method VARCHAR(50),
    bank_account VARCHAR(100),
    
    -- Status tracking
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    status_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INT,
    
    -- Related records
    related_transaction_id INT,
    betting_session_id INT,
    server_id INT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_reference_id (reference_id),
    
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE RESTRICT,
    FOREIGN KEY (processed_by) REFERENCES user(id) ON DELETE SET NULL,
    FOREIGN KEY (related_transaction_id) REFERENCES financial_transactions(id) ON DELETE SET NULL,
    FOREIGN KEY (betting_session_id) REFERENCES sesi_server(id) ON DELETE SET NULL,
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- User balances
CREATE TABLE IF NOT EXISTS user_balances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    available_balance DECIMAL(15,2) DEFAULT 0,
    pending_balance DECIMAL(15,2) DEFAULT 0,
    total_deposits DECIMAL(15,2) DEFAULT 0,
    total_withdrawals DECIMAL(15,2) DEFAULT 0,
    total_bets DECIMAL(15,2) DEFAULT 0,
    total_winnings DECIMAL(15,2) DEFAULT 0,
    total_commissions DECIMAL(15,2) DEFAULT 0,
    
    -- Credit limits
    credit_limit DECIMAL(15,2) DEFAULT 0,
    credit_used DECIMAL(15,2) DEFAULT 0,
    
    -- Last update tracking
    last_transaction_id INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_available_balance (available_balance),
    
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (last_transaction_id) REFERENCES financial_transactions(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================
-- COMMISSION STRUCTURE
-- =====================================================

-- Commission rules for different user roles
CREATE TABLE IF NOT EXISTS commission_rules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    commission_type VARCHAR(50) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    minimum_amount DECIMAL(15,2) DEFAULT 0,
    maximum_amount DECIMAL(15,2),
    
    -- Conditions
    applicable_to_role_id INT,
    server_id INT,
    bet_type VARCHAR(10),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    
    INDEX idx_role_id (role_id),
    INDEX idx_commission_type (commission_type),
    INDEX idx_server_id (server_id),
    INDEX idx_effective_dates (effective_from, effective_until),
    
    FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE,
    FOREIGN KEY (applicable_to_role_id) REFERENCES role(id) ON DELETE CASCADE,
    FOREIGN KEY (server_id) REFERENCES server(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- NOTIFICATION SYSTEM
-- =====================================================

-- Notifications for Bos dashboard
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    
    -- Priority and category
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    category VARCHAR(50),
    
    -- Action and routing
    action_url VARCHAR(500),
    action_data JSON,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    -- Related data
    related_table VARCHAR(50),
    related_id INT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- VIEWS FOR BOS DASHBOARD
-- =====================================================

-- Server overview for Bos
CREATE OR REPLACE VIEW bos_server_overview AS
SELECT 
    s.id,
    s.nama_server,
    s.kode_server,
    s.lokasi,
    s.status,
    s.owner_id,
    COUNT(DISTINCT ss.id) as total_sessions,
    COUNT(DISTINCT CASE WHEN ss.status = 'active' THEN ss.id END) as active_sessions,
    COUNT(DISTINCT tt.user_id) as unique_players,
    COALESCE(SUM(tt.harga_total), 0) as total_revenue,
    s.created_at,
    s.updated_at
FROM server s
LEFT JOIN sesi_server ss ON s.id = ss.server_id
LEFT JOIN transaksi_tebakan tt ON ss.id = tt.sesi_server_id
GROUP BY s.id, s.nama_server, s.kode_server, s.lokasi, s.status, s.owner_id, s.created_at, s.updated_at;

-- Session summary for Bos
CREATE OR REPLACE VIEW bos_session_summary AS
SELECT 
    ss.id,
    ss.server_id,
    s.nama_server,
    ss.nama_sesi,
    ss.tanggal_sesi,
    ss.jam_buka,
    ss.jam_tutup,
    ss.status,
    ss.total_bets,
    ss.total_amount,
    ss.total_winners,
    ss.total_payout,
    ss.created_by,
    u.username as created_by_username,
    ss.created_at
FROM sesi_server ss
JOIN server s ON ss.server_id = s.id
LEFT JOIN user u ON ss.created_by = u.id;

-- User hierarchy view for Bos
CREATE OR REPLACE VIEW bos_user_hierarchy AS
SELECT 
    u.id as user_id,
    u.username,
    o.nama_depan,
    o.nama_belakang,
    r.nama_role,
    uo.owner_id as boss_id,
    boss.username as boss_username,
    uo.relationship_type,
    uo.assigned_at,
    u.is_active,
    u.last_login
FROM user u
JOIN role r ON u.role_id = r.id
LEFT JOIN user_ownership uo ON u.id = uo.user_id
LEFT JOIN user boss ON uo.owner_id = boss.id
LEFT JOIN orang o ON u.id = (SELECT user_id FROM user_ownership WHERE orang_id = o.id LIMIT 1);

-- =====================================================
-- STORED PROCEDURES FOR BOS OPERATIONS
-- =====================================================

-- Create server with default configuration
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_create_server_for_bos(
    IN p_bos_id INT,
    IN p_nama_server VARCHAR(100),
    IN p_kode_server VARCHAR(20),
    IN p_lokasi VARCHAR(100),
    OUT p_server_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Error creating server';
        SET p_server_id = 0;
    END;

    START TRANSACTION;
    
    -- Check if Bos exists and has correct role
    IF NOT EXISTS (SELECT 1 FROM user u JOIN role r ON u.role_id = r.id WHERE u.id = p_bos_id AND r.nama_role = 'Bos') THEN
        SET p_success = FALSE;
        SET p_message = 'Invalid Bos user';
        SET p_server_id = 0;
        ROLLBACK;
    ELSE
        -- Insert server
        INSERT INTO server (nama_server, kode_server, lokasi, created_by, owner_id, status)
        VALUES (p_nama_server, p_kode_server, p_lokasi, p_bos_id, p_bos_id, 'active');
        
        SET p_server_id = LAST_INSERT_ID();
        
        -- Create default bet types (this would call another procedure)
        -- CALL sp_create_default_bet_types(p_server_id);
        
        SET p_success = TRUE;
        SET p_message = 'Server created successfully';
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- =====================================================
-- INITIAL DATA FOR BOS MANAGEMENT
-- =====================================================

-- Insert default commission rules
INSERT IGNORE INTO commission_rules (role_id, commission_type, percentage, effective_from, created_by) VALUES
(2, 'betting_commission', 5.00, CURDATE(), 1),  -- Bos gets 5% from betting
(3, 'admin_commission', 2.00, CURDATE(), 1),    -- Admin Bos gets 2%
(4, 'transport_commission', 1.50, CURDATE(), 1), -- Transporter gets 1.5%
(5, 'seller_commission', 1.00, CURDATE(), 1);   -- Penjual gets 1%

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_server_owner_status ON server(owner_id, status);
CREATE INDEX IF NOT EXISTS idx_session_server_date ON sesi_server(server_id, tanggal_sesi);
CREATE INDEX IF NOT EXISTS idx_financial_user_type ON financial_transactions(user_id, transaction_type);
CREATE INDEX IF NOT EXISTS idx_user_balance_available ON user_balances(available_balance);

-- Show completion message
SELECT 'Bos Management Schema created successfully' as status,
       NOW() as timestamp,
       'Ready for Bos server and session management' as message;