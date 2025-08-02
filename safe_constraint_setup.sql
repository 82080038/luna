-- Script aman untuk setup constraint Super Admin
-- Jalankan script ini di database sistem_angka

-- 1. Drop trigger jika sudah ada (untuk menghindari error)
DROP TRIGGER IF EXISTS prevent_multiple_superadmin_insert;
DROP TRIGGER IF EXISTS prevent_multiple_superadmin_update;

-- 2. Drop view jika sudah ada
DROP VIEW IF EXISTS v_superadmin_monitor;

-- 3. Drop stored procedure jika sudah ada
DROP PROCEDURE IF EXISTS ValidateSuperAdminAccess;

-- 4. Buat trigger untuk mencegah Super Admin tambahan
DELIMITER $$

CREATE TRIGGER prevent_multiple_superadmin_insert
BEFORE INSERT ON user
FOR EACH ROW
BEGIN
    DECLARE superadmin_count INT;
    
    -- Hitung jumlah Super Admin yang sudah ada
    SELECT COUNT(*) INTO superadmin_count
    FROM user u
    JOIN role r ON u.role_id = r.id
    WHERE r.nama_role = 'Super Admin';
    
    -- Jika mencoba menambah Super Admin baru dan sudah ada 1
    IF superadmin_count >= 1 AND NEW.role_id = (SELECT id FROM role WHERE nama_role = 'Super Admin') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hanya boleh ada 1 Super Admin dalam sistem';
    END IF;
END$$

CREATE TRIGGER prevent_multiple_superadmin_update
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    DECLARE superadmin_count INT;
    
    -- Hitung jumlah Super Admin yang sudah ada (kecuali user yang sedang diupdate)
    SELECT COUNT(*) INTO superadmin_count
    FROM user u
    JOIN role r ON u.role_id = r.id
    WHERE r.nama_role = 'Super Admin' AND u.id != NEW.id;
    
    -- Jika mencoba mengubah role menjadi Super Admin dan sudah ada 1
    IF superadmin_count >= 1 AND NEW.role_id = (SELECT id FROM role WHERE nama_role = 'Super Admin') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hanya boleh ada 1 Super Admin dalam sistem';
    END IF;
END$$

DELIMITER ;

-- 5. Buat view untuk monitoring Super Admin
CREATE VIEW v_superadmin_monitor AS
SELECT 
    u.id as user_id,
    u.username,
    o.nama_depan,
    o.nama_tengah,
    o.nama_belakang,
    u.is_active,
    u.created_at,
    COUNT(*) OVER() as total_superadmin
FROM user u
JOIN role r ON u.role_id = r.id
JOIN orang o ON u.orang_id = o.id
WHERE r.nama_role = 'Super Admin';

-- 6. Buat stored procedure untuk validasi Super Admin
DELIMITER $$

CREATE PROCEDURE ValidateSuperAdminAccess(IN user_id INT)
BEGIN
    DECLARE user_role VARCHAR(50);
    
    -- Cek role user
    SELECT r.nama_role INTO user_role
    FROM user u
    JOIN role r ON u.role_id = r.id
    WHERE u.id = user_id;
    
    -- Hanya Super Admin yang boleh mengakses
    IF user_role != 'Super Admin' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Akses ditolak: Hanya Super Admin yang diizinkan';
    END IF;
END$$

DELIMITER ;

-- 7. Verifikasi constraint berhasil dibuat
SELECT '✅ Constraint berhasil ditambahkan!' as status;
SELECT COUNT(*) as jumlah_superadmin FROM v_superadmin_monitor;
SELECT 'Trigger dan stored procedure berhasil dibuat' as info; 