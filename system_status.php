<?php
require_once 'api/config.php';

echo "=== STATUS SISTEM LUNA ===\n\n";

echo "🔍 MEMERIKSA KOMPONEN SISTEM...\n\n";

// 1. Check Database Connection
echo "1. Database Connection:\n";
try {
    $pdo = new PDO("mysql:host=$host;dbname=sistem_angka", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "   ✅ sistem_angka: Connected\n";
    
    // Check sistem_alamat database
    $pdo_alamat = new PDO("mysql:host=$host;dbname=sistem_alamat", $username, $password);
    $pdo_alamat->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "   ✅ sistem_alamat: Connected\n";
} catch (PDOException $e) {
    echo "   ❌ Database Error: " . $e->getMessage() . "\n";
    exit;
}

// 2. Check User Counts
echo "\n2. User Statistics:\n";
try {
    $stmt = $pdo->prepare("
        SELECT 
            r.nama_role,
            COUNT(*) as total,
            SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) as aktif
        FROM user u
        JOIN role r ON u.role_id = r.id
        GROUP BY r.nama_role
        ORDER BY r.id
    ");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($users as $user) {
        echo "   📊 {$user['nama_role']}: {$user['aktif']}/{$user['total']} (Aktif/Total)\n";
    }
} catch (Exception $e) {
    echo "   ❌ Error getting user stats: " . $e->getMessage() . "\n";
}

// 3. Check API Files
echo "\n3. API Endpoints:\n";
$api_files = [
    'auth_login.php' => 'Authentication',
    'change_password.php' => 'Password Management',
    'check_first_login.php' => 'First Login Detection',
    'check_user_completeness.php' => 'Profile Completeness',
    'add_bos.php' => 'Add BOS',
    'add_admin_bos.php' => 'Add Admin BOS',
    'add_transporter.php' => 'Add Transporter',
    'add_penjual.php' => 'Add Penjual',
    'get_all_users.php' => 'Get All Users',
    'toggle_user_status.php' => 'Toggle User Status',
    'delete_user.php' => 'Delete User',
    'get_bos_statistics.php' => 'BOS Statistics',
    'get_bos_users.php' => 'Get BOS Users',
    'get_provinsi.php' => 'Get Provinces',
    'get_kabupaten.php' => 'Get Regencies',
    'get_kecamatan.php' => 'Get Districts',
    'get_kelurahan.php' => 'Get Villages',
    'validate_address.php' => 'Validate Address',
    'get_user_address.php' => 'Get User Address',
    'check_telepon.php' => 'Check Phone Number'
];

foreach ($api_files as $file => $description) {
    if (file_exists("api/$file")) {
        echo "   ✅ $file - $description\n";
    } else {
        echo "   ❌ $file - $description (MISSING)\n";
    }
}

// 4. Check Dashboard Files
echo "\n4. Dashboard Files:\n";
$dashboard_files = [
    'super_admin/index.html' => 'Super Admin Dashboard',
    'bos/index.html' => 'BOS Dashboard',
    'admin_bos/index.html' => 'Admin BOS Dashboard',
    'transporter/index.html' => 'Transporter Dashboard',
    'penjual/index.html' => 'Penjual Dashboard',
    'pembeli/index.html' => 'Pembeli Dashboard'
];

foreach ($dashboard_files as $file => $description) {
    if (file_exists("dashboards/$file")) {
        echo "   ✅ $file - $description\n";
    } else {
        echo "   ❌ $file - $description (MISSING)\n";
    }
}

// 5. Check Core Files
echo "\n5. Core Files:\n";
$core_files = [
    'index.html' => 'Login Page',
    'change_password.html' => 'Change Password Page',
    'profile_completeness.html' => 'Profile Completeness Page',
    'css/styles.css' => 'Main Stylesheet',
    'js/app.js' => 'Main JavaScript',
    'api/config.php' => 'Database Config'
];

foreach ($core_files as $file => $description) {
    if (file_exists($file)) {
        echo "   ✅ $file - $description\n";
    } else {
        echo "   ❌ $file - $description (MISSING)\n";
    }
}

// 6. Check Database Tables
echo "\n6. Database Tables:\n";
$required_tables = [
    'user' => 'User accounts',
    'role' => 'User roles',
    'orang' => 'Personal data',
    'orang_identitas' => 'Contact data',
    'orang_alamat' => 'Address data',
    'user_ownership' => 'User ownership',
    'master_jenis_identitas' => 'Identity types'
];

foreach ($required_tables as $table => $description) {
    try {
        $stmt = $pdo->prepare("SHOW TABLES LIKE ?");
        $stmt->execute([$table]);
        if ($stmt->rowCount() > 0) {
            echo "   ✅ $table - $description\n";
        } else {
            echo "   ❌ $table - $description (MISSING)\n";
        }
    } catch (Exception $e) {
        echo "   ❌ $table - $description (ERROR)\n";
    }
}

// 7. Check Address Database Tables
echo "\n7. Address Database Tables:\n";
$address_tables = [
    'cbo_propinsi' => 'Provinces',
    'cbo_kab_kota' => 'Regencies/Cities',
    'cbo_kecamatan' => 'Districts',
    'cbo_desa' => 'Villages'
];

foreach ($address_tables as $table => $description) {
    try {
        $stmt = $pdo_alamat->prepare("SHOW TABLES LIKE ?");
        $stmt->execute([$table]);
        if ($stmt->rowCount() > 0) {
            // Get record count
            $count_stmt = $pdo_alamat->prepare("SELECT COUNT(*) as count FROM $table");
            $count_stmt->execute();
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "   ✅ $table - $description ($count records)\n";
        } else {
            echo "   ❌ $table - $description (MISSING)\n";
        }
    } catch (Exception $e) {
        echo "   ❌ $table - $description (ERROR)\n";
    }
}

// 8. System Status Summary
echo "\n8. System Status Summary:\n";

// Count total files checked
$total_files = count($api_files) + count($dashboard_files) + count($core_files);
$existing_files = 0;

foreach (array_merge($api_files, $dashboard_files, $core_files) as $file => $description) {
    if (file_exists($file) || file_exists("api/$file") || file_exists("dashboards/$file")) {
        $existing_files++;
    }
}

$file_coverage = round(($existing_files / $total_files) * 100, 1);

echo "   📁 File Coverage: $existing_files/$total_files ($file_coverage%)\n";

// Check if system is ready
$system_ready = true;
if ($file_coverage < 95) {
    $system_ready = false;
}

if ($system_ready) {
    echo "   🟢 System Status: READY\n";
    echo "   🚀 Ready for production use\n";
} else {
    echo "   🟡 System Status: NEEDS ATTENTION\n";
    echo "   ⚠️  Some components are missing\n";
}

echo "\n=== TEST INSTRUCTIONS ===\n";
echo "1. Login as Super Admin: admin / admin123\n";
echo "2. Login as BOS: 081910457868 / 081910457868\n";
echo "3. Test profile completeness system\n";
echo "4. Test user management features\n";
echo "5. Test address validation\n\n";

echo "=== ACCESS URLS ===\n";
echo "🌐 Main Login: http://localhost/luna/\n";
echo "🔐 Change Password: http://localhost/luna/change_password.html\n";
echo "📋 Profile Completeness: http://localhost/luna/profile_completeness.html\n";
echo "👑 Super Admin Dashboard: http://localhost/luna/dashboards/super_admin/index.html\n";
echo "👨‍💼 BOS Dashboard: http://localhost/luna/dashboards/bos/index.html\n\n";

echo "✅ System check completed!\n";
?> 