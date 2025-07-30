<?php
// Database configuration
$host = $_ENV['DB_HOST'] ?? 'localhost';
$dbname = $_ENV['DB_NAME'] ?? 'sistem_angka';
$username = $_ENV['DB_USER'] ?? 'root';
$password = $_ENV['DB_PASS'] ?? '';

// Security: Ensure database password is set in production
if (empty($password) && (isset($_ENV['APP_ENV']) && $_ENV['APP_ENV'] === 'production')) {
    throw new Exception('Database password must be set in production environment');
}

// Create database connection function
function getDatabaseConnection() {
    global $host, $dbname, $username, $password;
    
    try {
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false, // Security: Disable emulated prepares
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
        ];
        
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, $options);
        return $pdo;
    } catch (PDOException $e) {
        // Security: Don't expose database details in production
        $message = (isset($_ENV['APP_ENV']) && $_ENV['APP_ENV'] === 'production') 
            ? 'Database connection failed' 
            : 'Database connection failed: ' . $e->getMessage();
        throw new Exception($message);
    }
}

// Set common headers with enhanced security
function setCommonHeaders() {
    header('Content-Type: application/json; charset=utf-8');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('X-XSS-Protection: 1; mode=block');
    
    // CORS configuration - restrict in production
    $allowedOrigins = $_ENV['ALLOWED_ORIGINS'] ?? '*';
    header("Access-Control-Allow-Origin: $allowedOrigins");
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Max-Age: 86400'); // 24 hours
    
    // Handle preflight requests
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// Send JSON response with enhanced error handling
function sendJsonResponse($success, $data = null, $error = null, $statusCode = 200) {
    http_response_code($statusCode);
    
    $response = [
        'success' => $success,
        'timestamp' => date('c'),
        'data' => $data
    ];
    
    if ($error !== null) {
        $response['error'] = $error;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit();
}

// Input validation and sanitization helper
function validateAndSanitizeInput($input, $rules = []) {
    $errors = [];
    $sanitized = [];
    
    foreach ($rules as $field => $rule) {
        $value = $input[$field] ?? null;
        
        // Check required fields
        if (isset($rule['required']) && $rule['required'] && empty($value)) {
            $errors[] = "Field '$field' is required";
            continue;
        }
        
        // Skip validation if field is not required and empty
        if (empty($value) && (!isset($rule['required']) || !$rule['required'])) {
            $sanitized[$field] = null;
            continue;
        }
        
        // Type validation
        if (isset($rule['type'])) {
            switch ($rule['type']) {
                case 'email':
                    if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                        $errors[] = "Field '$field' must be a valid email";
                        continue 2;
                    }
                    break;
                case 'phone':
                    if (!preg_match('/^[0-9]{10,13}$/', $value)) {
                        $errors[] = "Field '$field' must be 10-13 digits";
                        continue 2;
                    }
                    break;
                case 'numeric':
                    if (!is_numeric($value)) {
                        $errors[] = "Field '$field' must be numeric";
                        continue 2;
                    }
                    break;
            }
        }
        
        // Length validation
        if (isset($rule['max_length']) && strlen($value) > $rule['max_length']) {
            $errors[] = "Field '$field' maximum length is {$rule['max_length']} characters";
            continue;
        }
        
        if (isset($rule['min_length']) && strlen($value) < $rule['min_length']) {
            $errors[] = "Field '$field' minimum length is {$rule['min_length']} characters";
            continue;
        }
        
        // Pattern validation
        if (isset($rule['pattern']) && !preg_match($rule['pattern'], $value)) {
            $errors[] = "Field '$field' format is invalid";
            continue;
        }
        
        // Sanitize the value
        $sanitized[$field] = htmlspecialchars(trim($value), ENT_QUOTES, 'UTF-8');
    }
    
    return [
        'valid' => empty($errors),
        'errors' => $errors,
        'data' => $sanitized
    ];
}

// Rate limiting helper (simple implementation)
function checkRateLimit($identifier, $maxRequests = 60, $timeWindow = 3600) {
    $cacheFile = sys_get_temp_dir() . '/luna_rate_limit_' . md5($identifier);
    
    if (file_exists($cacheFile)) {
        $data = json_decode(file_get_contents($cacheFile), true);
        $now = time();
        
        // Reset if time window has passed
        if ($now - $data['start_time'] > $timeWindow) {
            $data = ['requests' => 0, 'start_time' => $now];
        }
        
        if ($data['requests'] >= $maxRequests) {
            return false;
        }
        
        $data['requests']++;
    } else {
        $data = ['requests' => 1, 'start_time' => time()];
    }
    
    file_put_contents($cacheFile, json_encode($data));
    return true;
}
?> 