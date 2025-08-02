<?php
require_once 'api/config.php';

echo "=== DEBUG LOGIN ISSUE ===\n\n";

$test_username = '081265511982';
$test_password = '081265511982';

echo "Testing login for:\n";
echo "Username: $test_username\n";
echo "Password: $test_password\n\n";

try {
    $pdo = new PDO("mysql:host=$host;dbname=sistem_angka", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // 1. Check if user exists
    echo "1. Checking if user exists...\n";
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.password_hash,
            u.is_active,
            r.nama_role,
            o.nama_depan,
            o.nama_tengah,
            o.nama_belakang
        FROM user u
        JOIN role r ON u.role_id = r.id
        JOIN orang o ON u.orang_id = o.id
        WHERE u.username = ?
    ");
    
    $stmt->execute([$test_username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo "   ❌ User not found!\n";
        exit;
    }
    
    echo "   ✅ User found!\n";
    echo "   ID: {$user['id']}\n";
    echo "   Username: {$user['username']}\n";
    echo "   Role: {$user['nama_role']}\n";
    echo "   Active: " . ($user['is_active'] ? 'Yes' : 'No') . "\n";
    echo "   Name: {$user['nama_depan']} {$user['nama_tengah']} {$user['nama_belakang']}\n";
    echo "   Password Hash: {$user['password_hash']}\n\n";
    
    // 2. Check password verification
    echo "2. Checking password verification...\n";
    
    // Try different password verification methods
    $sha256_hash = hash('sha256', $test_password);
    $password_verify_result = password_verify($test_password, $user['password_hash']);
    
    echo "   Input password: $test_password\n";
    echo "   SHA256 hash: $sha256_hash\n";
    echo "   Stored hash: {$user['password_hash']}\n";
    echo "   SHA256 match: " . ($sha256_hash === $user['password_hash'] ? 'YES' : 'NO') . "\n";
    echo "   Password verify: " . ($password_verify_result ? 'YES' : 'NO') . "\n\n";
    
    // 3. Check what hash algorithm was used
    echo "3. Analyzing hash algorithm...\n";
    $hash_info = password_get_info($user['password_hash']);
    echo "   Algorithm: " . $hash_info['algoName'] . "\n";
    echo "   Algorithm ID: " . $hash_info['algo'] . "\n";
    echo "   Options: " . print_r($hash_info['options'], true) . "\n\n";
    
    // 4. Test different verification methods
    echo "4. Testing verification methods...\n";
    
    // Method 1: SHA256
    $sha256_match = (hash('sha256', $test_password) === $user['password_hash']);
    echo "   SHA256 verification: " . ($sha256_match ? 'SUCCESS' : 'FAILED') . "\n";
    
    // Method 2: Password verify
    $pwd_verify_match = password_verify($test_password, $user['password_hash']);
    echo "   Password verify: " . ($pwd_verify_match ? 'SUCCESS' : 'FAILED') . "\n";
    
    // Method 3: Direct comparison
    $direct_match = ($test_password === $user['password_hash']);
    echo "   Direct comparison: " . ($direct_match ? 'SUCCESS' : 'FAILED') . "\n\n";
    
    // 5. Generate correct hash
    echo "5. Generating correct hash...\n";
    $correct_sha256 = hash('sha256', $test_password);
    $correct_bcrypt = password_hash($test_password, PASSWORD_DEFAULT);
    
    echo "   Correct SHA256: $correct_sha256\n";
    echo "   Correct bcrypt: $correct_bcrypt\n\n";
    
    // 6. Check if we need to update the hash
    echo "6. Recommendation:\n";
    if ($sha256_match) {
        echo "   ✅ SHA256 hash is correct. The issue might be in the API.\n";
    } elseif ($pwd_verify_match) {
        echo "   ✅ Bcrypt hash is correct. The issue might be in the API.\n";
    } else {
        echo "   ❌ Hash doesn't match. Need to update password hash.\n";
        echo "   Current hash: {$user['password_hash']}\n";
        echo "   Expected SHA256: $correct_sha256\n";
        echo "   Expected bcrypt: $correct_bcrypt\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 