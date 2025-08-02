-- Script untuk setup dual database system
-- Database 1: sistem_angka (sistem utama)
-- Database 2: sistem_alamat (data alamat)

-- 1. Buat database sistem_alamat jika belum ada
CREATE DATABASE IF NOT EXISTS sistem_alamat;
USE sistem_alamat;

-- 2. Import data alamat dari sistem_alamat.sql
-- (gunakan file sistem_alamat.sql yang sudah ada)

-- 3. Verifikasi struktur dual database
SELECT 'Dual database setup completed!' as status;

-- 4. Test koneksi ke kedua database
-- Test sistem_angka
USE sistem_angka;
SELECT COUNT(*) as total_users FROM user;

-- Test sistem_alamat  
USE sistem_alamat;
SELECT COUNT(*) as total_provinsi FROM cbo_propinsi; 