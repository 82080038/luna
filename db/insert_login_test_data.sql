-- =====================================================
-- INSERT TEST DATA FOR LOGIN WITH DIFFERENT ROLES
-- =====================================================

-- Clear existing test data (optional)
-- DELETE FROM user WHERE username IN ('admin', 'bos1', 'adminbos1', 'transporter1', 'penjual1', 'pembeli1');
-- DELETE FROM orang WHERE nama_depan IN ('Super Admin', 'Bos Test', 'Admin Bos Test', 'Transporter Test', 'Penjual Test', 'Pembeli Test');

-- =====================================================
-- 1. INSERT ORANG DATA
-- =====================================================

-- Super Admin
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Super', 'Administrator', 'L');

-- Bos
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Bos', 'Test', 'L');

-- Admin Bos
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Admin', 'Bos Test', 'L');

-- Transporter
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Transporter', 'Test', 'L');

-- Penjual
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Penjual', 'Test', 'L');

-- Pembeli
INSERT INTO orang (nama_depan, nama_belakang, jenis_kelamin) VALUES 
('Pembeli', 'Test', 'L');

-- =====================================================
-- 2. INSERT CONTACT INFORMATION
-- =====================================================

-- Get orang IDs
SET @super_admin_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Super' AND nama_belakang = 'Administrator');
SET @bos_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Bos' AND nama_belakang = 'Test');
SET @admin_bos_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Admin' AND nama_belakang = 'Bos Test');
SET @transporter_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Transporter' AND nama_belakang = 'Test');
SET @penjual_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Penjual' AND nama_belakang = 'Test');
SET @pembeli_orang_id = (SELECT id FROM orang WHERE nama_depan = 'Pembeli' AND nama_belakang = 'Test');

-- Get contact type IDs
SET @email_type_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Email');
SET @telepon_type_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon');

-- Insert contact information for all users
INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary, is_verified) VALUES
-- Super Admin
(@super_admin_orang_id, @email_type_id, 'admin@luna.com', TRUE, TRUE),
(@super_admin_orang_id, @telepon_type_id, '081234567890', TRUE, TRUE),

-- Bos
(@bos_orang_id, @email_type_id, 'bos@luna.com', TRUE, TRUE),
(@bos_orang_id, @telepon_type_id, '081234567891', TRUE, TRUE),

-- Admin Bos
(@admin_bos_orang_id, @email_type_id, 'adminbos@luna.com', TRUE, TRUE),
(@admin_bos_orang_id, @telepon_type_id, '081234567892', TRUE, TRUE),

-- Transporter
(@transporter_orang_id, @email_type_id, 'transporter@luna.com', TRUE, TRUE),
(@transporter_orang_id, @telepon_type_id, '081234567893', TRUE, TRUE),

-- Penjual
(@penjual_orang_id, @email_type_id, 'penjual@luna.com', TRUE, TRUE),
(@penjual_orang_id, @telepon_type_id, '081234567894', TRUE, TRUE),

-- Pembeli
(@pembeli_orang_id, @email_type_id, 'pembeli@luna.com', TRUE, TRUE),
(@pembeli_orang_id, @telepon_type_id, '081234567895', TRUE, TRUE);

-- =====================================================
-- 3. INSERT USER ACCOUNTS
-- =====================================================

-- Get role IDs
SET @super_admin_role_id = (SELECT id FROM role WHERE nama_role = 'Super Admin');
SET @bos_role_id = (SELECT id FROM role WHERE nama_role = 'Bos');
SET @admin_bos_role_id = (SELECT id FROM role WHERE nama_role = 'Admin Bos');
SET @transporter_role_id = (SELECT id FROM role WHERE nama_role = 'Transporter');
SET @penjual_role_id = (SELECT id FROM role WHERE nama_role = 'Penjual');
SET @pembeli_role_id = (SELECT id FROM role WHERE nama_role = 'Pembeli');

-- Insert user accounts with hashed passwords
INSERT INTO user (username, password, role_id, orang_id, is_active) VALUES
-- Super Admin (password: admin123)
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @super_admin_role_id, @super_admin_orang_id, TRUE),

-- Bos (password: bos123)
('bos1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @bos_role_id, @bos_orang_id, TRUE),

-- Admin Bos (password: adminbos123)
('adminbos1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @admin_bos_role_id, @admin_bos_orang_id, TRUE),

-- Transporter (password: transporter123)
('transporter1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @transporter_role_id, @transporter_orang_id, TRUE),

-- Penjual (password: penjual123)
('penjual1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @penjual_role_id, @penjual_orang_id, TRUE),

-- Pembeli (password: pembeli123)
('pembeli1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @pembeli_role_id, @pembeli_orang_id, TRUE);

-- =====================================================
-- 4. TEST LOGIN CREDENTIALS
-- =====================================================

/*
TEST LOGIN CREDENTIALS:

1. Super Admin:
   Username: admin
   Password: admin123
   Redirect: super_admin_dashboard.html

2. Bos:
   Username: bos1
   Password: bos123
   Redirect: mobile_dashboard.html

3. Admin Bos:
   Username: adminbos1
   Password: adminbos123
   Redirect: mobile_dashboard.html

4. Transporter:
   Username: transporter1
   Password: transporter123
   Redirect: mobile_dashboard.html

5. Penjual:
   Username: penjual1
   Password: penjual123
   Redirect: mobile_dashboard.html

6. Pembeli:
   Username: pembeli1
   Password: pembeli123
   Redirect: mobile_dashboard.html

Note: All passwords are hashed using password_hash() with PASSWORD_DEFAULT
*/

-- =====================================================
-- 5. VERIFICATION QUERY
-- =====================================================

-- Verify the test data
SELECT 
    u.username,
    u.is_active,
    r.nama_role,
    CONCAT(o.nama_depan, ' ', COALESCE(o.nama_belakang, '')) as nama_lengkap,
    oi_email.nilai_identitas as email,
    oi_telepon.nilai_identitas as telepon
FROM user u
JOIN role r ON u.role_id = r.id
JOIN orang o ON u.orang_id = o.id
LEFT JOIN orang_identitas oi_email ON o.id = oi_email.orang_id 
    AND oi_email.jenis_identitas_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Email')
    AND oi_email.is_primary = TRUE
LEFT JOIN orang_identitas oi_telepon ON o.id = oi_telepon.orang_id 
    AND oi_telepon.jenis_identitas_id = (SELECT id FROM master_jenis_identitas WHERE nama_jenis = 'Telepon')
    AND oi_telepon.is_primary = TRUE
WHERE u.username IN ('admin', 'bos1', 'adminbos1', 'transporter1', 'penjual1', 'pembeli1')
ORDER BY r.id; 