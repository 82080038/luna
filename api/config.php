<?php
// Dual Database Configuration
$host = 'localhost';
$username = 'root';
$password = '';

// Database 1: Sistem utama (sistem_angka)
$dbname_sistem = 'sistem_angka';

// Database 2: Database alamat (sistem_alamat)
$dbname_alamat = 'sistem_alamat';

// Create database connection function for main system
function getDatabaseConnection($database = 'sistem') {
    global $host, $dbname_sistem, $dbname_alamat, $username, $password;
    
    $dbname = ($database === 'alamat') ? $dbname_alamat : $dbname_sistem;
    
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch (PDOException $e) {
        throw new Exception('Database connection failed: ' . $e->getMessage());
    }
}

// Get address database connection
function getAddressDatabaseConnection() {
    return getDatabaseConnection('alamat');
}

// Get main system database connection
function getMainDatabaseConnection() {
    return getDatabaseConnection('sistem');
}

// Set common headers
function setCommonHeaders() {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    
    // Handle preflight requests
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// Send JSON response
function sendJsonResponse($success, $data = null, $error = null, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'error' => $error
    ]);
    exit();
}
?> 