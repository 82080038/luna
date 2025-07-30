-- Security Enhancements for Luna System
-- Run this script to add security features to the existing database

USE sistem_angka;

-- Add security columns to user table
ALTER TABLE user 
ADD COLUMN IF NOT EXISTS failed_login_attempts INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS locked_until TIMESTAMP NULL,
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP NULL,
ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN DEFAULT FALSE;

-- Create user sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_user_session (user_id),
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB;

-- Create audit log table for tracking important actions
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Create login attempts log
CREATE TABLE IF NOT EXISTS login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    failure_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_ip_address (ip_address),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- Create password history table to prevent password reuse
CREATE TABLE IF NOT EXISTS password_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- Add indexes for better performance
ALTER TABLE user ADD INDEX IF NOT EXISTS idx_username (username);
ALTER TABLE user ADD INDEX IF NOT EXISTS idx_last_login (last_login);
ALTER TABLE user ADD INDEX IF NOT EXISTS idx_locked_until (locked_until);

-- Update existing users to use stronger password hashing
-- Note: This will require users to reset their passwords
UPDATE user SET must_change_password = TRUE WHERE password NOT LIKE '$argon2id$%';

-- Create stored procedure for cleaning expired sessions
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS CleanExpiredSessions()
BEGIN
    DELETE FROM user_sessions WHERE expires_at < NOW();
    DELETE FROM login_attempts WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
    DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
END //
DELIMITER ;

-- Create event to automatically clean expired sessions daily
-- SET GLOBAL event_scheduler = ON;
-- CREATE EVENT IF NOT EXISTS CleanExpiredSessionsEvent
-- ON SCHEDULE EVERY 1 DAY
-- STARTS CURRENT_TIMESTAMP
-- DO CALL CleanExpiredSessions();

-- Create view for user login statistics
CREATE OR REPLACE VIEW user_login_stats AS
SELECT 
    u.id,
    u.username,
    u.last_login,
    u.failed_login_attempts,
    u.locked_until,
    COUNT(la.id) as total_login_attempts,
    SUM(CASE WHEN la.success = 1 THEN 1 ELSE 0 END) as successful_logins,
    SUM(CASE WHEN la.success = 0 THEN 1 ELSE 0 END) as failed_logins
FROM user u
LEFT JOIN login_attempts la ON u.username = la.username AND la.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.id, u.username, u.last_login, u.failed_login_attempts, u.locked_until;

-- Create view for active sessions
CREATE OR REPLACE VIEW active_sessions AS
SELECT 
    s.id,
    s.user_id,
    u.username,
    s.expires_at,
    s.created_at,
    s.ip_address,
    TIMESTAMPDIFF(MINUTE, NOW(), s.expires_at) as minutes_until_expiry
FROM user_sessions s
JOIN user u ON s.user_id = u.id
WHERE s.expires_at > NOW() AND s.is_active = TRUE;

-- Insert sample audit log for tracking
INSERT INTO audit_logs (user_id, action, table_name, new_values, ip_address) 
VALUES (1, 'SECURITY_ENHANCEMENT', 'database', '{"action": "Added security tables and procedures"}', '127.0.0.1');

-- Show summary of security enhancements
SELECT 'Security enhancements completed successfully' as status,
       NOW() as timestamp,
       'Added: user_sessions, audit_logs, login_attempts, password_history tables' as details;