-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 02 Agu 2025 pada 12.42
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sistem_angka`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_alamat_orang` (IN `p_orang_id` INT)   BEGIN
    SELECT 
        aj.nama_jenis as jenis,
        oa.alamat_lengkap,
        oa.rt,
        oa.rw,
        oa.kode_pos,
        kd.nama as kelurahan_desa,
        kk.nama as kabupaten_kota,
        p.nama as provinsi,
        oa.is_primary,
        oa.is_verified
    FROM orang_alamat oa
    JOIN alamat_jenis aj ON oa.alamat_jenis_id = aj.id
    LEFT JOIN kelurahan_desa kd ON oa.kelurahan_desa_id = kd.id
    LEFT JOIN kecamatan k ON kd.kecamatan_id = k.id
    LEFT JOIN kabupaten_kota kk ON k.kabupaten_kota_id = kk.id
    LEFT JOIN provinsi p ON kk.provinsi_id = p.id
    WHERE oa.orang_id = p_orang_id
    ORDER BY oa.is_primary DESC, aj.nama_jenis;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_identitas_orang` (IN `p_orang_id` INT)   BEGIN
    SELECT 
        mji.nama_jenis as jenis,
        oi.nilai_identitas as nilai,
        oi.is_primary,
        oi.is_verified
    FROM orang_identitas oi
    JOIN master_jenis_identitas mji ON oi.jenis_identitas_id = mji.id
    WHERE oi.orang_id = p_orang_id
    ORDER BY oi.is_primary DESC, mji.nama_jenis;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tambah_alamat_orang` (IN `p_orang_id` INT, IN `p_jenis_alamat` VARCHAR(50), IN `p_alamat_lengkap` TEXT, IN `p_rt` VARCHAR(3), IN `p_rw` VARCHAR(3), IN `p_kode_pos` VARCHAR(10), IN `p_kelurahan_desa_id` INT, IN `p_is_primary` BOOLEAN)   BEGIN
    DECLARE v_jenis_id INT;
    
    -- Ambil ID jenis alamat
    SELECT id INTO v_jenis_id 
    FROM alamat_jenis 
    WHERE nama_jenis = p_jenis_alamat;
    
    -- Jika primary, set yang lain menjadi non-primary
    IF p_is_primary THEN
        UPDATE orang_alamat 
        SET is_primary = FALSE 
        WHERE orang_id = p_orang_id AND alamat_jenis_id = v_jenis_id;
    END IF;
    
    -- Insert alamat baru
    INSERT INTO orang_alamat (orang_id, alamat_jenis_id, alamat_lengkap, rt, rw, kode_pos, kelurahan_desa_id, is_primary)
    VALUES (p_orang_id, v_jenis_id, p_alamat_lengkap, p_rt, p_rw, p_kode_pos, p_kelurahan_desa_id, p_is_primary);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tambah_identitas_orang` (IN `p_orang_id` INT, IN `p_jenis_identitas` VARCHAR(50), IN `p_nilai_identitas` VARCHAR(255), IN `p_is_primary` BOOLEAN)   BEGIN
    DECLARE v_jenis_id INT;
    
    -- Ambil ID jenis identitas
    SELECT id INTO v_jenis_id 
    FROM master_jenis_identitas 
    WHERE nama_jenis = p_jenis_identitas;
    
    -- Jika primary, set yang lain menjadi non-primary
    IF p_is_primary THEN
        UPDATE orang_identitas 
        SET is_primary = FALSE 
        WHERE orang_id = p_orang_id AND jenis_identitas_id = v_jenis_id;
    END IF;
    
    -- Insert identitas baru
    INSERT INTO orang_identitas (orang_id, jenis_identitas_id, nilai_identitas, is_primary)
    VALUES (p_orang_id, v_jenis_id, p_nilai_identitas, p_is_primary);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateSuperAdminAccess` (IN `user_id` INT)   BEGIN
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

-- --------------------------------------------------------

--
-- Struktur dari tabel `alamat_jenis`
--

CREATE TABLE `alamat_jenis` (
  `id` int(11) NOT NULL,
  `nama_jenis` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `alamat_jenis`
--

INSERT INTO `alamat_jenis` (`id`, `nama_jenis`, `deskripsi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Rumah Tinggal', 'Alamat tempat tinggal utama', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(2, 'Tempat Kerja', 'Alamat tempat bekerja', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(3, 'Alamat Kantor', 'Alamat kantor atau tempat usaha', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(4, 'Alamat Domisili', 'Alamat domisili resmi', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(5, 'Alamat Korespondensi', 'Alamat untuk korespondensi', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(6, 'Alamat Darurat', 'Alamat darurat atau kontak darurat', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `deposit_member`
--

CREATE TABLE `deposit_member` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `bos_id` int(11) NOT NULL,
  `saldo` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `deposit_member`
--

INSERT INTO `deposit_member` (`id`, `user_id`, `bos_id`, `saldo`, `created_at`, `updated_at`) VALUES
(1, 5, 2, 5000000.00, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(2, 6, 2, 1000000.00, '2025-07-29 18:15:32', '2025-07-29 18:15:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `detail_kemenangan`
--

CREATE TABLE `detail_kemenangan` (
  `id` int(11) NOT NULL,
  `transaksi_id` int(11) NOT NULL,
  `tipe_tebakan_id` int(11) NOT NULL,
  `angka_tebakan` varchar(10) NOT NULL,
  `jumlah_tebakan` int(11) NOT NULL,
  `hadiah_per_tebakan` decimal(15,2) NOT NULL,
  `total_hadiah` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `hadiah`
--

CREATE TABLE `hadiah` (
  `id` int(11) NOT NULL,
  `tipe_tebakan_id` int(11) NOT NULL,
  `nama_hadiah` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `jumlah_hadiah` decimal(15,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `hadiah`
--

INSERT INTO `hadiah` (`id`, `tipe_tebakan_id`, `nama_hadiah`, `deskripsi`, `jumlah_hadiah`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Hadiah 4D', 'Hadiah untuk tebakan 4 digit', 9000000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(2, 2, 'Hadiah 3D', 'Hadiah untuk tebakan 3 digit', 900000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(3, 3, 'Hadiah 2D', 'Hadiah untuk tebakan 2 digit', 90000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(4, 4, 'Hadiah CE', 'Hadiah untuk colok bebas', 9000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(5, 5, 'Hadiah CK', 'Hadiah untuk colok kembang', 9000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(6, 6, 'Hadiah CB', 'Hadiah untuk colok buntut', 9000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `hasil_tebakan`
--

CREATE TABLE `hasil_tebakan` (
  `id` int(11) NOT NULL,
  `sesi_server_id` int(11) NOT NULL,
  `tipe_tebakan_id` int(11) NOT NULL,
  `angka_hasil` varchar(10) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kabupaten_kota`
--

CREATE TABLE `kabupaten_kota` (
  `id` int(11) NOT NULL,
  `provinsi_id` int(11) NOT NULL,
  `kode` varchar(10) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `jenis` enum('Kabupaten','Kota') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kecamatan`
--

CREATE TABLE `kecamatan` (
  `id` int(11) NOT NULL,
  `kabupaten_kota_id` int(11) NOT NULL,
  `kode` varchar(10) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelurahan_desa`
--

CREATE TABLE `kelurahan_desa` (
  `id` int(11) NOT NULL,
  `kecamatan_id` int(11) NOT NULL,
  `kode` varchar(10) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `jenis` enum('Kelurahan','Desa') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `komisi_aturan`
--

CREATE TABLE `komisi_aturan` (
  `id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `persentase_komisi` decimal(5,2) NOT NULL,
  `minimum_transaksi` decimal(15,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `komisi_aturan`
--

INSERT INTO `komisi_aturan` (`id`, `role_id`, `persentase_komisi`, `minimum_transaksi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 2, 5.00, 100000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(2, 3, 3.00, 50000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(3, 4, 2.00, 25000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32'),
(4, 5, 1.50, 10000.00, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `komisi_transaksi`
--

CREATE TABLE `komisi_transaksi` (
  `id` int(11) NOT NULL,
  `transaksi_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `jumlah_komisi` decimal(15,2) NOT NULL,
  `persentase_komisi` decimal(5,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `master_agama`
--

CREATE TABLE `master_agama` (
  `id` int(11) NOT NULL,
  `nama_agama` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `master_agama`
--

INSERT INTO `master_agama` (`id`, `nama_agama`, `deskripsi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Islam', 'Agama Islam', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(2, 'Kristen', 'Agama Kristen', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(3, 'Katolik', 'Agama Katolik', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(4, 'Hindu', 'Agama Hindu', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(5, 'Buddha', 'Agama Buddha', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(6, 'Konghucu', 'Agama Konghucu', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(7, 'Lainnya', 'Agama lainnya', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `master_jenis_identitas`
--

CREATE TABLE `master_jenis_identitas` (
  `id` int(11) NOT NULL,
  `nama_jenis` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `master_jenis_identitas`
--

INSERT INTO `master_jenis_identitas` (`id`, `nama_jenis`, `deskripsi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Email', 'Alamat email', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(2, 'Telepon', 'Nomor telepon', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(3, 'WhatsApp', 'Nomor WhatsApp', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(4, 'Telegram', 'Username Telegram', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(5, 'Instagram', 'Username Instagram', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(6, 'Facebook', 'Username Facebook', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(7, 'LinkedIn', 'Username LinkedIn', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(8, 'NIK', 'Nomor Induk Kependudukan', 1, '2025-07-29 18:50:47', '2025-07-29 18:50:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `master_status_perkawinan`
--

CREATE TABLE `master_status_perkawinan` (
  `id` int(11) NOT NULL,
  `nama_status` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `master_status_perkawinan`
--

INSERT INTO `master_status_perkawinan` (`id`, `nama_status`, `deskripsi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Belum Menikah', 'Status belum menikah', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(2, 'Menikah', 'Status sudah menikah', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(3, 'Cerai', 'Status cerai', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53'),
(4, 'Janda/Duda', 'Status janda atau duda', 1, '2025-07-29 18:14:53', '2025-07-29 18:14:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `metode_pembayaran`
--

CREATE TABLE `metode_pembayaran` (
  `id` int(11) NOT NULL,
  `nama_metode` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `metode_pembayaran`
--

INSERT INTO `metode_pembayaran` (`id`, `nama_metode`, `deskripsi`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Tunai', 'Pembayaran tunai', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(2, 'Transfer Bank', 'Transfer antar bank', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(3, 'E-Wallet', 'Pembayaran via e-wallet', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(4, 'QRIS', 'Pembayaran via QRIS', 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `negara`
--

CREATE TABLE `negara` (
  `id` int(11) NOT NULL,
  `kode_iso` varchar(3) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `orang`
--

CREATE TABLE `orang` (
  `id` int(11) NOT NULL,
  `nama_depan` varchar(50) NOT NULL,
  `nama_tengah` varchar(50) DEFAULT NULL,
  `nama_belakang` varchar(50) DEFAULT NULL,
  `nama_panggilan` varchar(30) DEFAULT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `tempat_lahir` varchar(50) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `golongan_darah` enum('A','B','AB','O') DEFAULT NULL,
  `agama_id` int(11) DEFAULT NULL,
  `status_perkawinan_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `orang`
--

INSERT INTO `orang` (`id`, `nama_depan`, `nama_tengah`, `nama_belakang`, `nama_panggilan`, `jenis_kelamin`, `tempat_lahir`, `tanggal_lahir`, `golongan_darah`, `agama_id`, `status_perkawinan_id`, `created_at`, `updated_at`) VALUES
(1, 'Ahmad', 'Rizki', 'Pratama', 'Rizki', 'L', 'Jakarta', '1990-05-15', 'O', 1, 2, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(19, 'bos 1', NULL, NULL, NULL, 'L', NULL, NULL, NULL, NULL, NULL, '2025-08-02 09:52:33', '2025-08-02 09:52:33'),
(20, 'Test Statistics', NULL, NULL, NULL, 'L', NULL, NULL, NULL, NULL, NULL, '2025-08-02 09:54:18', '2025-08-02 09:54:18'),
(21, 'par dolok', NULL, NULL, NULL, 'L', NULL, NULL, NULL, NULL, NULL, '2025-08-02 09:57:00', '2025-08-02 09:57:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `orang_alamat`
--

CREATE TABLE `orang_alamat` (
  `id` int(11) NOT NULL,
  `id_orang` int(11) NOT NULL,
  `id_jenis_alamat` int(11) NOT NULL,
  `id_negara` int(11) DEFAULT 1,
  `id_propinsi` int(11) DEFAULT NULL,
  `id_kab_kota` int(11) DEFAULT NULL,
  `id_kecamatan` int(11) DEFAULT NULL,
  `id_desa` int(11) DEFAULT NULL,
  `nama_alamat` text DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `lat_long` varchar(50) DEFAULT NULL,
  `alamat_utama` enum('Y','N') DEFAULT 'N',
  `aktif` enum('Y','N') DEFAULT 'Y',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `orang_alamat`
--

INSERT INTO `orang_alamat` (`id`, `id_orang`, `id_jenis_alamat`, `id_negara`, `id_propinsi`, `id_kab_kota`, `id_kecamatan`, `id_desa`, `nama_alamat`, `kode_pos`, `lat_long`, `alamat_utama`, `aktif`, `created_at`, `updated_at`) VALUES
(6, 19, 1, 1, 12, 1217, 121708, 1217082025, 'kedai sipangkar', NULL, NULL, 'Y', 'Y', '2025-08-02 09:52:33', '2025-08-02 09:52:33'),
(7, 20, 1, 1, 31, 3171, 317101, 2147483647, 'Jl. Test Statistics No. 123', NULL, NULL, 'Y', 'Y', '2025-08-02 09:54:18', '2025-08-02 09:54:18'),
(8, 21, 1, 1, 12, 1217, 121708, 1217082001, 'LUMBAN BONA-BONA, DESA SIOPAT SOSOR', NULL, NULL, 'Y', 'Y', '2025-08-02 09:57:00', '2025-08-02 09:57:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `orang_alamat_backup`
--

CREATE TABLE `orang_alamat_backup` (
  `id` int(11) NOT NULL DEFAULT 0,
  `orang_id` int(11) NOT NULL,
  `alamat_jenis_id` int(11) NOT NULL,
  `kelurahan_desa_id` int(11) DEFAULT NULL,
  `alamat_lengkap` text NOT NULL,
  `rt` varchar(3) DEFAULT NULL,
  `rw` varchar(3) DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `orang_alamat_backup`
--

INSERT INTO `orang_alamat_backup` (`id`, `orang_id`, `alamat_jenis_id`, `kelurahan_desa_id`, `alamat_lengkap`, `rt`, `rw`, `kode_pos`, `is_primary`, `is_verified`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, 'Jl. Sudirman No. 123, Menteng', '001', '002', '10310', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(2, 1, 3, NULL, 'Jl. Thamrin No. 456, Jakarta Pusat', '003', '004', '10350', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(3, 2, 1, NULL, 'Jl. Darmo No. 789, Surabaya', '005', '006', '60241', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(4, 2, 2, NULL, 'Jl. Basuki Rahmat No. 321, Surabaya', '007', '008', '60271', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(5, 2, 3, NULL, 'Jl. Pemuda No. 654, Surabaya', '009', '010', '60272', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(6, 3, 1, NULL, 'Jl. Asia Afrika No. 111, Bandung', '011', '012', '40262', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(7, 3, 3, NULL, 'Jl. Merdeka No. 222, Bandung', '013', '014', '40111', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(8, 4, 1, NULL, 'Jl. Pandanaran No. 333, Semarang', '015', '016', '50241', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(9, 4, 2, NULL, 'Jl. Gajah Mada No. 444, Semarang', '017', '018', '50134', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(10, 5, 1, NULL, 'Jl. Malioboro No. 555, Yogyakarta', '019', '020', '55213', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(11, 5, 3, NULL, 'Jl. Solo No. 666, Yogyakarta', '021', '022', '55222', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(12, 6, 1, NULL, 'Jl. Ijen No. 777, Malang', '023', '024', '65111', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(13, 6, 6, NULL, 'Jl. Soekarno Hatta No. 888, Malang', '025', '026', '65144', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(19, 12, 1, NULL, 'Jl. Test No. 456, Alue Bagok, Arongan Lambalek, KAB. ACEH BARAT, ACEH', NULL, NULL, NULL, 1, 1, '2025-08-02 08:22:23', '2025-08-02 08:22:23'),
(20, 13, 1, NULL, 'Jl. Test API No. 123, Alue Bagok, Arongan Lambalek, KAB. ACEH BARAT, ACEH', NULL, NULL, NULL, 1, 1, '2025-08-02 08:23:11', '2025-08-02 08:23:11');

-- --------------------------------------------------------

--
-- Struktur dari tabel `orang_identitas`
--

CREATE TABLE `orang_identitas` (
  `id` int(11) NOT NULL,
  `orang_id` int(11) NOT NULL,
  `jenis_identitas_id` int(11) NOT NULL,
  `nilai_identitas` varchar(255) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `orang_identitas`
--

INSERT INTO `orang_identitas` (`id`, `orang_id`, `jenis_identitas_id`, `nilai_identitas`, `is_primary`, `is_verified`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'admin@luna.com', 1, 1, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(2, 1, 2, '08123456789', 1, 0, '2025-07-29 18:15:31', '2025-08-02 09:15:28'),
(3, 1, 3, '08123456789', 0, 0, '2025-07-29 18:15:31', '2025-07-29 18:15:31'),
(22, 1, 8, '1234567890123456', 1, 1, '2025-07-29 18:50:47', '2025-07-29 18:50:47'),
(41, 19, 2, '081265511982', 1, 1, '2025-08-02 09:52:33', '2025-08-02 09:52:33'),
(42, 20, 2, '08123456788', 1, 1, '2025-08-02 09:54:18', '2025-08-02 09:54:18'),
(43, 21, 2, '081910457868', 1, 1, '2025-08-02 09:57:00', '2025-08-02 09:57:00');

--
-- Trigger `orang_identitas`
--
DELIMITER $$
CREATE TRIGGER `tr_orang_identitas_before_update` BEFORE UPDATE ON `orang_identitas` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pembayaran_hadiah`
--

CREATE TABLE `pembayaran_hadiah` (
  `id` int(11) NOT NULL,
  `detail_kemenangan_id` int(11) NOT NULL,
  `jumlah_dibayar` decimal(15,2) NOT NULL,
  `status` enum('Pending','Dibayar','Dibatalkan') DEFAULT 'Pending',
  `dibayar_oleh` int(11) DEFAULT NULL,
  `tanggal_pembayaran` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `provinsi`
--

CREATE TABLE `provinsi` (
  `id` int(11) NOT NULL,
  `negara_id` int(11) NOT NULL,
  `kode` varchar(10) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `role`
--

CREATE TABLE `role` (
  `id` int(11) NOT NULL,
  `nama_role` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `parent_role_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `role`
--

INSERT INTO `role` (`id`, `nama_role`, `deskripsi`, `parent_role_id`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'Administrator tertinggi sistem', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(2, 'Bos', 'Pemilik server dan bisnis', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(3, 'Admin Bos', 'Administrator untuk Bos', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(4, 'Transporter', 'Pengangkut dan distributor', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(5, 'Penjual', 'Penjual tebakan', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(6, 'Pembeli', 'Pembeli tebakan', NULL, '2025-07-29 18:14:54', '2025-07-29 18:14:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `server`
--

CREATE TABLE `server` (
  `id` int(11) NOT NULL,
  `nama_server` varchar(100) NOT NULL,
  `kode_server` varchar(10) NOT NULL,
  `lokasi` varchar(255) DEFAULT NULL,
  `owner_id` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `server`
--

INSERT INTO `server` (`id`, `nama_server`, `kode_server`, `lokasi`, `owner_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Server Jakarta Pusat', 'JKT-PST', 'Jakarta Pusat, DKI Jakarta', 2, 1, '2025-07-29 18:15:32', '2025-07-29 18:15:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `sesi_server`
--

CREATE TABLE `sesi_server` (
  `id` int(11) NOT NULL,
  `server_id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `waktu_buka` time NOT NULL,
  `waktu_tutup` time NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tipe_tebakan`
--

CREATE TABLE `tipe_tebakan` (
  `id` int(11) NOT NULL,
  `nama_tipe` varchar(10) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `jumlah_digit` int(11) NOT NULL,
  `harga_dasar` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tipe_tebakan`
--

INSERT INTO `tipe_tebakan` (`id`, `nama_tipe`, `deskripsi`, `jumlah_digit`, `harga_dasar`, `is_active`, `created_at`, `updated_at`) VALUES
(1, '4D', 'Tebakan 4 digit', 4, 1000.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(2, '3D', 'Tebakan 3 digit', 3, 500.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(3, '2D', 'Tebakan 2 digit', 2, 200.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(4, 'CE', 'Colok Bebas', 1, 100.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(5, 'CK', 'Colok Kembang', 1, 100.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54'),
(6, 'CB', 'Colok Buntut', 1, 100.00, 1, '2025-07-29 18:14:54', '2025-07-29 18:14:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi_pembayaran`
--

CREATE TABLE `transaksi_pembayaran` (
  `id` int(11) NOT NULL,
  `kode_transaksi` varchar(20) NOT NULL,
  `dari_user_id` int(11) NOT NULL,
  `ke_user_id` int(11) NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `metode_pembayaran_id` int(11) DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `status` enum('Pending','Berhasil','Gagal','Dibatalkan') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi_tebakan`
--

CREATE TABLE `transaksi_tebakan` (
  `id` int(11) NOT NULL,
  `kode_transaksi` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `sesi_server_id` int(11) NOT NULL,
  `total_bayar` decimal(15,2) NOT NULL,
  `status` enum('Pending','Dibayar','Dibatalkan','Selesai') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `orang_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`id`, `orang_id`, `role_id`, `username`, `password_hash`, `is_active`, `last_login`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 1, NULL, NULL, '2025-07-29 18:15:31', '2025-08-02 09:12:07'),
(14, 19, 2, '081265511982', '$2y$10$bLHLfAeKIR35Qzqgh6p6WeppRMgxtHgiB72ghjo2vcKTuXqc0wXxm', 1, NULL, 1, '2025-08-02 09:52:33', '2025-08-02 09:52:33'),
(15, 20, 2, '08123456788', '$2y$10$nnret6pGUm8hg3kDOe.lo.n8JVMBz/wOAI0ACjQEfZhkOeMpayo3y', 1, NULL, 1, '2025-08-02 09:54:18', '2025-08-02 09:54:18'),
(16, 21, 2, '081910457868', '$2y$10$Z8lwOzMbayXeaYK/3MZQkeSaCghMEQ4VFqiR5yzrffaUIOfXae1km', 1, NULL, 1, '2025-08-02 09:57:00', '2025-08-02 10:10:30');

--
-- Trigger `user`
--
DELIMITER $$
CREATE TRIGGER `prevent_multiple_superadmin_insert` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `prevent_multiple_superadmin_update` BEFORE UPDATE ON `user` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_ownership`
--

CREATE TABLE `user_ownership` (
  `id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `owned_id` int(11) NOT NULL,
  `relationship_type` enum('SuperAdmin-Bos','Bos-AdminBos','Bos-Transporter','Transporter-Penjual','Penjual-Pembeli') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_ownership`
--

INSERT INTO `user_ownership` (`id`, `owner_id`, `owned_id`, `relationship_type`, `created_at`) VALUES
(1, 1, 2, 'SuperAdmin-Bos', '2025-07-29 18:15:32'),
(6, 1, 7, 'SuperAdmin-Bos', '2025-08-02 08:22:23'),
(7, 1, 8, 'SuperAdmin-Bos', '2025-08-02 08:23:11'),
(8, 1, 9, 'SuperAdmin-Bos', '2025-08-02 08:28:01'),
(9, 1, 10, 'SuperAdmin-Bos', '2025-08-02 09:25:10'),
(10, 1, 11, 'SuperAdmin-Bos', '2025-08-02 09:43:49'),
(11, 1, 12, 'SuperAdmin-Bos', '2025-08-02 09:45:11'),
(12, 1, 13, 'SuperAdmin-Bos', '2025-08-02 09:46:27'),
(13, 1, 14, 'SuperAdmin-Bos', '2025-08-02 09:52:33'),
(14, 1, 15, 'SuperAdmin-Bos', '2025-08-02 09:54:18'),
(15, 1, 16, 'SuperAdmin-Bos', '2025-08-02 09:57:00');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_arus_kas`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_arus_kas` (
`jenis` varchar(19)
,`tanggal` date
,`jumlah` decimal(37,2)
,`arah` varchar(6)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_laba_rugi_harian`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_laba_rugi_harian` (
`tanggal` date
,`total_transaksi` bigint(21)
,`total_pendapatan` decimal(37,2)
,`total_hadiah_dibayar` decimal(37,2)
,`laba_bersih` decimal(38,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_orang_alamat`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_orang_alamat` (
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_orang_identitas`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_orang_identitas` (
`id` int(11)
,`orang_id` int(11)
,`nama_depan` varchar(50)
,`nama_belakang` varchar(50)
,`jenis_identitas` varchar(50)
,`nilai_identitas` varchar(255)
,`is_primary` tinyint(1)
,`is_verified` tinyint(1)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_orang_lengkap`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_orang_lengkap` (
`id` int(11)
,`nama_depan` varchar(50)
,`nama_tengah` varchar(50)
,`nama_belakang` varchar(50)
,`nama_panggilan` varchar(30)
,`nama_lengkap` varchar(152)
,`jenis_kelamin` enum('L','P')
,`tempat_lahir` varchar(50)
,`tanggal_lahir` date
,`golongan_darah` enum('A','B','AB','O')
,`nama_agama` varchar(50)
,`status_perkawinan` varchar(50)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_orang_nik`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_orang_nik` (
`orang_id` int(11)
,`nama_depan` varchar(50)
,`nama_belakang` varchar(50)
,`nik` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_penyerahan_dana`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_penyerahan_dana` (
`username` varchar(50)
,`nama_lengkap` varchar(152)
,`nama_role` varchar(50)
,`saldo_deposit` decimal(15,2)
,`total_transaksi` bigint(21)
,`total_omset` decimal(37,2)
,`total_hadiah` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_user_lengkap`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_user_lengkap` (
`id` int(11)
,`username` varchar(50)
,`is_active` tinyint(1)
,`last_login` datetime
,`nama_depan` varchar(50)
,`nama_tengah` varchar(50)
,`nama_belakang` varchar(50)
,`nama_panggilan` varchar(30)
,`nama_lengkap` varchar(152)
,`jenis_kelamin` enum('L','P')
,`tempat_lahir` varchar(50)
,`tanggal_lahir` date
,`golongan_darah` enum('A','B','AB','O')
,`nama_agama` varchar(50)
,`status_perkawinan` varchar(50)
,`nama_role` varchar(50)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_superadmin_monitor`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_superadmin_monitor` (
`user_id` int(11)
,`username` varchar(50)
,`nama_depan` varchar(50)
,`nama_tengah` varchar(50)
,`nama_belakang` varchar(50)
,`is_active` tinyint(1)
,`created_at` timestamp
,`total_superadmin` bigint(21)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `view_arus_kas`
--
DROP TABLE IF EXISTS `view_arus_kas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_arus_kas`  AS SELECT 'Pendapatan Tebakan' AS `jenis`, cast(`transaksi_tebakan`.`created_at` as date) AS `tanggal`, sum(`transaksi_tebakan`.`total_bayar`) AS `jumlah`, 'Masuk' AS `arah` FROM `transaksi_tebakan` WHERE `transaksi_tebakan`.`status` = 'Dibayar' GROUP BY cast(`transaksi_tebakan`.`created_at` as date)union all select 'Pembayaran Hadiah' AS `jenis`,cast(`pembayaran_hadiah`.`created_at` as date) AS `tanggal`,sum(`pembayaran_hadiah`.`jumlah_dibayar`) AS `jumlah`,'Keluar' AS `arah` from `pembayaran_hadiah` where `pembayaran_hadiah`.`status` = 'Dibayar' group by cast(`pembayaran_hadiah`.`created_at` as date) union all select 'Transfer Antar User' AS `jenis`,cast(`transaksi_pembayaran`.`created_at` as date) AS `tanggal`,sum(`transaksi_pembayaran`.`jumlah`) AS `jumlah`,case when `transaksi_pembayaran`.`dari_user_id` = 1 then 'Keluar' else 'Masuk' end AS `arah` from `transaksi_pembayaran` where `transaksi_pembayaran`.`status` = 'Berhasil' group by cast(`transaksi_pembayaran`.`created_at` as date),case when `transaksi_pembayaran`.`dari_user_id` = 1 then 'Keluar' else 'Masuk' end  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_laba_rugi_harian`
--
DROP TABLE IF EXISTS `view_laba_rugi_harian`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_laba_rugi_harian`  AS SELECT cast(`tt`.`created_at` as date) AS `tanggal`, count(`tt`.`id`) AS `total_transaksi`, sum(`tt`.`total_bayar`) AS `total_pendapatan`, sum(case when `dk`.`id` is not null then `dk`.`total_hadiah` else 0 end) AS `total_hadiah_dibayar`, sum(`tt`.`total_bayar`) - sum(case when `dk`.`id` is not null then `dk`.`total_hadiah` else 0 end) AS `laba_bersih` FROM (`transaksi_tebakan` `tt` left join `detail_kemenangan` `dk` on(`tt`.`id` = `dk`.`transaksi_id`)) WHERE `tt`.`status` = 'Selesai' GROUP BY cast(`tt`.`created_at` as date) ORDER BY cast(`tt`.`created_at` as date) DESC ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_orang_alamat`
--
DROP TABLE IF EXISTS `view_orang_alamat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_orang_alamat`  AS SELECT `oa`.`id` AS `id`, `oa`.`orang_id` AS `orang_id`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_belakang` AS `nama_belakang`, `aj`.`nama_jenis` AS `jenis_alamat`, `oa`.`alamat_lengkap` AS `alamat_lengkap`, `oa`.`rt` AS `rt`, `oa`.`rw` AS `rw`, `oa`.`kode_pos` AS `kode_pos`, `kd`.`nama` AS `kelurahan_desa`, `kk`.`nama` AS `kabupaten_kota`, `p`.`nama` AS `provinsi`, `n`.`nama` AS `negara`, `oa`.`is_primary` AS `is_primary`, `oa`.`is_verified` AS `is_verified`, `oa`.`created_at` AS `created_at` FROM (((((((`orang_alamat` `oa` join `orang` `o` on(`oa`.`orang_id` = `o`.`id`)) join `alamat_jenis` `aj` on(`oa`.`alamat_jenis_id` = `aj`.`id`)) left join `kelurahan_desa` `kd` on(`oa`.`kelurahan_desa_id` = `kd`.`id`)) left join `kecamatan` `k` on(`kd`.`kecamatan_id` = `k`.`id`)) left join `kabupaten_kota` `kk` on(`k`.`kabupaten_kota_id` = `kk`.`id`)) left join `provinsi` `p` on(`kk`.`provinsi_id` = `p`.`id`)) left join `negara` `n` on(`p`.`negara_id` = `n`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_orang_identitas`
--
DROP TABLE IF EXISTS `view_orang_identitas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_orang_identitas`  AS SELECT `oi`.`id` AS `id`, `oi`.`orang_id` AS `orang_id`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_belakang` AS `nama_belakang`, `mji`.`nama_jenis` AS `jenis_identitas`, `oi`.`nilai_identitas` AS `nilai_identitas`, `oi`.`is_primary` AS `is_primary`, `oi`.`is_verified` AS `is_verified`, `oi`.`created_at` AS `created_at` FROM ((`orang_identitas` `oi` join `orang` `o` on(`oi`.`orang_id` = `o`.`id`)) join `master_jenis_identitas` `mji` on(`oi`.`jenis_identitas_id` = `mji`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_orang_lengkap`
--
DROP TABLE IF EXISTS `view_orang_lengkap`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_orang_lengkap`  AS SELECT `o`.`id` AS `id`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_tengah` AS `nama_tengah`, `o`.`nama_belakang` AS `nama_belakang`, `o`.`nama_panggilan` AS `nama_panggilan`, concat(`o`.`nama_depan`,' ',coalesce(`o`.`nama_tengah`,''),' ',coalesce(`o`.`nama_belakang`,'')) AS `nama_lengkap`, `o`.`jenis_kelamin` AS `jenis_kelamin`, `o`.`tempat_lahir` AS `tempat_lahir`, `o`.`tanggal_lahir` AS `tanggal_lahir`, `o`.`golongan_darah` AS `golongan_darah`, `ma`.`nama_agama` AS `nama_agama`, `msp`.`nama_status` AS `status_perkawinan`, `o`.`created_at` AS `created_at`, `o`.`updated_at` AS `updated_at` FROM ((`orang` `o` left join `master_agama` `ma` on(`o`.`agama_id` = `ma`.`id`)) left join `master_status_perkawinan` `msp` on(`o`.`status_perkawinan_id` = `msp`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_orang_nik`
--
DROP TABLE IF EXISTS `view_orang_nik`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_orang_nik`  AS SELECT `o`.`id` AS `orang_id`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_belakang` AS `nama_belakang`, `oi`.`nilai_identitas` AS `nik` FROM ((`orang` `o` join `orang_identitas` `oi` on(`o`.`id` = `oi`.`orang_id`)) join `master_jenis_identitas` `mji` on(`oi`.`jenis_identitas_id` = `mji`.`id`)) WHERE `mji`.`nama_jenis` = 'NIK' AND `oi`.`is_primary` = 1 ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_penyerahan_dana`
--
DROP TABLE IF EXISTS `view_penyerahan_dana`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_penyerahan_dana`  AS SELECT `u`.`username` AS `username`, concat(`o`.`nama_depan`,' ',coalesce(`o`.`nama_tengah`,''),' ',coalesce(`o`.`nama_belakang`,'')) AS `nama_lengkap`, `r`.`nama_role` AS `nama_role`, `dm`.`saldo` AS `saldo_deposit`, count(`tt`.`id`) AS `total_transaksi`, sum(`tt`.`total_bayar`) AS `total_omset`, sum(case when `dk`.`id` is not null then `dk`.`total_hadiah` else 0 end) AS `total_hadiah` FROM (((((`user` `u` join `orang` `o` on(`u`.`orang_id` = `o`.`id`)) join `role` `r` on(`u`.`role_id` = `r`.`id`)) left join `deposit_member` `dm` on(`u`.`id` = `dm`.`user_id`)) left join `transaksi_tebakan` `tt` on(`u`.`id` = `tt`.`user_id`)) left join `detail_kemenangan` `dk` on(`tt`.`id` = `dk`.`transaksi_id`)) WHERE `r`.`nama_role` in ('Penjual','Pembeli') GROUP BY `u`.`id`, `u`.`username`, `o`.`nama_depan`, `o`.`nama_tengah`, `o`.`nama_belakang`, `r`.`nama_role`, `dm`.`saldo` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_user_lengkap`
--
DROP TABLE IF EXISTS `view_user_lengkap`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_user_lengkap`  AS SELECT `u`.`id` AS `id`, `u`.`username` AS `username`, `u`.`is_active` AS `is_active`, `u`.`last_login` AS `last_login`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_tengah` AS `nama_tengah`, `o`.`nama_belakang` AS `nama_belakang`, `o`.`nama_panggilan` AS `nama_panggilan`, concat(`o`.`nama_depan`,' ',coalesce(`o`.`nama_tengah`,''),' ',coalesce(`o`.`nama_belakang`,'')) AS `nama_lengkap`, `o`.`jenis_kelamin` AS `jenis_kelamin`, `o`.`tempat_lahir` AS `tempat_lahir`, `o`.`tanggal_lahir` AS `tanggal_lahir`, `o`.`golongan_darah` AS `golongan_darah`, `ma`.`nama_agama` AS `nama_agama`, `msp`.`nama_status` AS `status_perkawinan`, `r`.`nama_role` AS `nama_role`, `u`.`created_at` AS `created_at` FROM ((((`user` `u` join `orang` `o` on(`u`.`orang_id` = `o`.`id`)) join `role` `r` on(`u`.`role_id` = `r`.`id`)) left join `master_agama` `ma` on(`o`.`agama_id` = `ma`.`id`)) left join `master_status_perkawinan` `msp` on(`o`.`status_perkawinan_id` = `msp`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_superadmin_monitor`
--
DROP TABLE IF EXISTS `v_superadmin_monitor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_superadmin_monitor`  AS SELECT `u`.`id` AS `user_id`, `u`.`username` AS `username`, `o`.`nama_depan` AS `nama_depan`, `o`.`nama_tengah` AS `nama_tengah`, `o`.`nama_belakang` AS `nama_belakang`, `u`.`is_active` AS `is_active`, `u`.`created_at` AS `created_at`, count(0) over () AS `total_superadmin` FROM ((`user` `u` join `role` `r` on(`u`.`role_id` = `r`.`id`)) join `orang` `o` on(`u`.`orang_id` = `o`.`id`)) WHERE `r`.`nama_role` = 'Super Admin' ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `alamat_jenis`
--
ALTER TABLE `alamat_jenis`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_jenis` (`nama_jenis`);

--
-- Indeks untuk tabel `deposit_member`
--
ALTER TABLE `deposit_member`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`bos_id`),
  ADD KEY `bos_id` (`bos_id`),
  ADD KEY `idx_deposit_user_bos` (`user_id`,`bos_id`);

--
-- Indeks untuk tabel `detail_kemenangan`
--
ALTER TABLE `detail_kemenangan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tipe_tebakan_id` (`tipe_tebakan_id`),
  ADD KEY `idx_detail_transaksi` (`transaksi_id`);

--
-- Indeks untuk tabel `hadiah`
--
ALTER TABLE `hadiah`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tipe_tebakan_id` (`tipe_tebakan_id`);

--
-- Indeks untuk tabel `hasil_tebakan`
--
ALTER TABLE `hasil_tebakan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sesi_server_id` (`sesi_server_id`,`tipe_tebakan_id`),
  ADD KEY `tipe_tebakan_id` (`tipe_tebakan_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_hasil_sesi` (`sesi_server_id`);

--
-- Indeks untuk tabel `kabupaten_kota`
--
ALTER TABLE `kabupaten_kota`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `provinsi_id` (`provinsi_id`,`nama`),
  ADD UNIQUE KEY `kode` (`kode`);

--
-- Indeks untuk tabel `kecamatan`
--
ALTER TABLE `kecamatan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kabupaten_kota_id` (`kabupaten_kota_id`,`nama`),
  ADD UNIQUE KEY `kode` (`kode`);

--
-- Indeks untuk tabel `kelurahan_desa`
--
ALTER TABLE `kelurahan_desa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kecamatan_id` (`kecamatan_id`,`nama`),
  ADD UNIQUE KEY `kode` (`kode`);

--
-- Indeks untuk tabel `komisi_aturan`
--
ALTER TABLE `komisi_aturan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `role_id` (`role_id`);

--
-- Indeks untuk tabel `komisi_transaksi`
--
ALTER TABLE `komisi_transaksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_komisi_transaksi` (`transaksi_id`);

--
-- Indeks untuk tabel `master_agama`
--
ALTER TABLE `master_agama`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_agama` (`nama_agama`);

--
-- Indeks untuk tabel `master_jenis_identitas`
--
ALTER TABLE `master_jenis_identitas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_jenis` (`nama_jenis`);

--
-- Indeks untuk tabel `master_status_perkawinan`
--
ALTER TABLE `master_status_perkawinan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_status` (`nama_status`);

--
-- Indeks untuk tabel `metode_pembayaran`
--
ALTER TABLE `metode_pembayaran`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `negara`
--
ALTER TABLE `negara`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama` (`nama`),
  ADD UNIQUE KEY `kode_iso` (`kode_iso`);

--
-- Indeks untuk tabel `orang`
--
ALTER TABLE `orang`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_orang_agama` (`agama_id`),
  ADD KEY `idx_orang_status_perkawinan` (`status_perkawinan_id`);

--
-- Indeks untuk tabel `orang_alamat`
--
ALTER TABLE `orang_alamat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_jenis_alamat` (`id_jenis_alamat`),
  ADD KEY `idx_orang` (`id_orang`),
  ADD KEY `idx_alamat_utama` (`alamat_utama`),
  ADD KEY `idx_aktif` (`aktif`),
  ADD KEY `idx_propinsi` (`id_propinsi`),
  ADD KEY `idx_kab_kota` (`id_kab_kota`),
  ADD KEY `idx_kecamatan` (`id_kecamatan`),
  ADD KEY `idx_desa` (`id_desa`);

--
-- Indeks untuk tabel `orang_identitas`
--
ALTER TABLE `orang_identitas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orang_id` (`orang_id`,`jenis_identitas_id`,`nilai_identitas`),
  ADD KEY `idx_orang_identitas_orang` (`orang_id`),
  ADD KEY `idx_orang_identitas_jenis` (`jenis_identitas_id`);

--
-- Indeks untuk tabel `pembayaran_hadiah`
--
ALTER TABLE `pembayaran_hadiah`
  ADD PRIMARY KEY (`id`),
  ADD KEY `detail_kemenangan_id` (`detail_kemenangan_id`),
  ADD KEY `dibayar_oleh` (`dibayar_oleh`);

--
-- Indeks untuk tabel `provinsi`
--
ALTER TABLE `provinsi`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `negara_id` (`negara_id`,`nama`),
  ADD UNIQUE KEY `kode` (`kode`);

--
-- Indeks untuk tabel `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_role` (`nama_role`),
  ADD KEY `parent_role_id` (`parent_role_id`);

--
-- Indeks untuk tabel `server`
--
ALTER TABLE `server`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_server` (`kode_server`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indeks untuk tabel `sesi_server`
--
ALTER TABLE `sesi_server`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `server_id` (`server_id`,`tanggal`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_sesi_server_date` (`tanggal`),
  ADD KEY `idx_sesi_server_active` (`is_active`);

--
-- Indeks untuk tabel `tipe_tebakan`
--
ALTER TABLE `tipe_tebakan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_tipe` (`nama_tipe`);

--
-- Indeks untuk tabel `transaksi_pembayaran`
--
ALTER TABLE `transaksi_pembayaran`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_transaksi` (`kode_transaksi`),
  ADD KEY `dari_user_id` (`dari_user_id`),
  ADD KEY `ke_user_id` (`ke_user_id`),
  ADD KEY `metode_pembayaran_id` (`metode_pembayaran_id`),
  ADD KEY `idx_pembayaran_status` (`status`),
  ADD KEY `idx_pembayaran_date` (`created_at`);

--
-- Indeks untuk tabel `transaksi_tebakan`
--
ALTER TABLE `transaksi_tebakan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_transaksi` (`kode_transaksi`),
  ADD KEY `idx_transaksi_sesi` (`sesi_server_id`),
  ADD KEY `idx_transaksi_user` (`user_id`),
  ADD KEY `idx_transaksi_status` (`status`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `orang_id` (`orang_id`,`role_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_user_role` (`role_id`),
  ADD KEY `idx_user_orang` (`orang_id`);

--
-- Indeks untuk tabel `user_ownership`
--
ALTER TABLE `user_ownership`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `owner_id` (`owner_id`,`owned_id`,`relationship_type`),
  ADD KEY `owned_id` (`owned_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `alamat_jenis`
--
ALTER TABLE `alamat_jenis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `deposit_member`
--
ALTER TABLE `deposit_member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `detail_kemenangan`
--
ALTER TABLE `detail_kemenangan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `hadiah`
--
ALTER TABLE `hadiah`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `hasil_tebakan`
--
ALTER TABLE `hasil_tebakan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kabupaten_kota`
--
ALTER TABLE `kabupaten_kota`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kecamatan`
--
ALTER TABLE `kecamatan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kelurahan_desa`
--
ALTER TABLE `kelurahan_desa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `komisi_aturan`
--
ALTER TABLE `komisi_aturan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `komisi_transaksi`
--
ALTER TABLE `komisi_transaksi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `master_agama`
--
ALTER TABLE `master_agama`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `master_jenis_identitas`
--
ALTER TABLE `master_jenis_identitas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `master_status_perkawinan`
--
ALTER TABLE `master_status_perkawinan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `metode_pembayaran`
--
ALTER TABLE `metode_pembayaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `negara`
--
ALTER TABLE `negara`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `orang`
--
ALTER TABLE `orang`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT untuk tabel `orang_alamat`
--
ALTER TABLE `orang_alamat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `orang_identitas`
--
ALTER TABLE `orang_identitas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT untuk tabel `pembayaran_hadiah`
--
ALTER TABLE `pembayaran_hadiah`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `provinsi`
--
ALTER TABLE `provinsi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `role`
--
ALTER TABLE `role`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `server`
--
ALTER TABLE `server`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `sesi_server`
--
ALTER TABLE `sesi_server`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tipe_tebakan`
--
ALTER TABLE `tipe_tebakan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `transaksi_pembayaran`
--
ALTER TABLE `transaksi_pembayaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `transaksi_tebakan`
--
ALTER TABLE `transaksi_tebakan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `user_ownership`
--
ALTER TABLE `user_ownership`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `deposit_member`
--
ALTER TABLE `deposit_member`
  ADD CONSTRAINT `deposit_member_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deposit_member_ibfk_2` FOREIGN KEY (`bos_id`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `detail_kemenangan`
--
ALTER TABLE `detail_kemenangan`
  ADD CONSTRAINT `detail_kemenangan_ibfk_1` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi_tebakan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detail_kemenangan_ibfk_2` FOREIGN KEY (`tipe_tebakan_id`) REFERENCES `tipe_tebakan` (`id`);

--
-- Ketidakleluasaan untuk tabel `hadiah`
--
ALTER TABLE `hadiah`
  ADD CONSTRAINT `hadiah_ibfk_1` FOREIGN KEY (`tipe_tebakan_id`) REFERENCES `tipe_tebakan` (`id`);

--
-- Ketidakleluasaan untuk tabel `hasil_tebakan`
--
ALTER TABLE `hasil_tebakan`
  ADD CONSTRAINT `hasil_tebakan_ibfk_1` FOREIGN KEY (`sesi_server_id`) REFERENCES `sesi_server` (`id`),
  ADD CONSTRAINT `hasil_tebakan_ibfk_2` FOREIGN KEY (`tipe_tebakan_id`) REFERENCES `tipe_tebakan` (`id`),
  ADD CONSTRAINT `hasil_tebakan_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `kabupaten_kota`
--
ALTER TABLE `kabupaten_kota`
  ADD CONSTRAINT `kabupaten_kota_ibfk_1` FOREIGN KEY (`provinsi_id`) REFERENCES `provinsi` (`id`);

--
-- Ketidakleluasaan untuk tabel `kecamatan`
--
ALTER TABLE `kecamatan`
  ADD CONSTRAINT `kecamatan_ibfk_1` FOREIGN KEY (`kabupaten_kota_id`) REFERENCES `kabupaten_kota` (`id`);

--
-- Ketidakleluasaan untuk tabel `kelurahan_desa`
--
ALTER TABLE `kelurahan_desa`
  ADD CONSTRAINT `kelurahan_desa_ibfk_1` FOREIGN KEY (`kecamatan_id`) REFERENCES `kecamatan` (`id`);

--
-- Ketidakleluasaan untuk tabel `komisi_aturan`
--
ALTER TABLE `komisi_aturan`
  ADD CONSTRAINT `komisi_aturan_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`);

--
-- Ketidakleluasaan untuk tabel `komisi_transaksi`
--
ALTER TABLE `komisi_transaksi`
  ADD CONSTRAINT `komisi_transaksi_ibfk_1` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi_tebakan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `komisi_transaksi_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `orang`
--
ALTER TABLE `orang`
  ADD CONSTRAINT `orang_ibfk_1` FOREIGN KEY (`agama_id`) REFERENCES `master_agama` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orang_ibfk_2` FOREIGN KEY (`status_perkawinan_id`) REFERENCES `master_status_perkawinan` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `orang_alamat`
--
ALTER TABLE `orang_alamat`
  ADD CONSTRAINT `orang_alamat_ibfk_1` FOREIGN KEY (`id_orang`) REFERENCES `orang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orang_alamat_ibfk_2` FOREIGN KEY (`id_jenis_alamat`) REFERENCES `alamat_jenis` (`id`);

--
-- Ketidakleluasaan untuk tabel `orang_identitas`
--
ALTER TABLE `orang_identitas`
  ADD CONSTRAINT `orang_identitas_ibfk_1` FOREIGN KEY (`orang_id`) REFERENCES `orang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orang_identitas_ibfk_2` FOREIGN KEY (`jenis_identitas_id`) REFERENCES `master_jenis_identitas` (`id`);

--
-- Ketidakleluasaan untuk tabel `pembayaran_hadiah`
--
ALTER TABLE `pembayaran_hadiah`
  ADD CONSTRAINT `pembayaran_hadiah_ibfk_1` FOREIGN KEY (`detail_kemenangan_id`) REFERENCES `detail_kemenangan` (`id`),
  ADD CONSTRAINT `pembayaran_hadiah_ibfk_2` FOREIGN KEY (`dibayar_oleh`) REFERENCES `user` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `provinsi`
--
ALTER TABLE `provinsi`
  ADD CONSTRAINT `provinsi_ibfk_1` FOREIGN KEY (`negara_id`) REFERENCES `negara` (`id`);

--
-- Ketidakleluasaan untuk tabel `role`
--
ALTER TABLE `role`
  ADD CONSTRAINT `role_ibfk_1` FOREIGN KEY (`parent_role_id`) REFERENCES `role` (`id`);

--
-- Ketidakleluasaan untuk tabel `server`
--
ALTER TABLE `server`
  ADD CONSTRAINT `server_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `sesi_server`
--
ALTER TABLE `sesi_server`
  ADD CONSTRAINT `sesi_server_ibfk_1` FOREIGN KEY (`server_id`) REFERENCES `server` (`id`),
  ADD CONSTRAINT `sesi_server_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `transaksi_pembayaran`
--
ALTER TABLE `transaksi_pembayaran`
  ADD CONSTRAINT `transaksi_pembayaran_ibfk_1` FOREIGN KEY (`dari_user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `transaksi_pembayaran_ibfk_2` FOREIGN KEY (`ke_user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `transaksi_pembayaran_ibfk_3` FOREIGN KEY (`metode_pembayaran_id`) REFERENCES `metode_pembayaran` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `transaksi_tebakan`
--
ALTER TABLE `transaksi_tebakan`
  ADD CONSTRAINT `transaksi_tebakan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `transaksi_tebakan_ibfk_2` FOREIGN KEY (`sesi_server_id`) REFERENCES `sesi_server` (`id`);

--
-- Ketidakleluasaan untuk tabel `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`orang_id`) REFERENCES `orang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`),
  ADD CONSTRAINT `user_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `user_ownership`
--
ALTER TABLE `user_ownership`
  ADD CONSTRAINT `user_ownership_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_ownership_ibfk_2` FOREIGN KEY (`owned_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
