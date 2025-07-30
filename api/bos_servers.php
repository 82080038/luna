<?php
require_once 'config.php';
setCommonHeaders();

// Rate limiting
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!checkRateLimit($clientIP, 60, 3600)) {
    sendJsonResponse(false, null, 'Rate limit exceeded', 429);
}

// Establish database connection
try {
    $pdo = getDatabaseConnection();
} catch (Exception $e) {
    sendJsonResponse(false, null, 'Database connection failed', 500);
}

// Check authentication
$authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
if (!$authHeader || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
    sendJsonResponse(false, null, 'Authorization header required', 401);
}

$sessionToken = $matches[1];

try {
    // Verify session and get user info
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, r.nama_role 
        FROM user u 
        JOIN role r ON u.role_id = r.id 
        LEFT JOIN user_sessions us ON u.id = us.user_id 
        WHERE us.session_token = ? AND us.expires_at > NOW() AND u.is_active = 1
    ");
    $stmt->execute([hash('sha256', $sessionToken)]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJsonResponse(false, null, 'Invalid or expired session', 401);
    }

    if ($user['nama_role'] !== 'Bos') {
        sendJsonResponse(false, null, 'Access denied. Bos role required', 403);
    }

    $bosId = $user['id'];
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            handleGetServers($pdo, $bosId);
            break;
        case 'POST':
            handleCreateServer($pdo, $bosId, $clientIP);
            break;
        case 'PUT':
            handleUpdateServer($pdo, $bosId, $clientIP);
            break;
        case 'DELETE':
            handleDeleteServer($pdo, $bosId, $clientIP);
            break;
        default:
            sendJsonResponse(false, null, 'Method not allowed', 405);
    }

} catch (Exception $e) {
    error_log("Bos Servers API Error: " . $e->getMessage());
    sendJsonResponse(false, null, 'Internal server error', 500);
}

// =====================================================
// GET SERVERS
// =====================================================

function handleGetServers($pdo, $bosId) {
    try {
        $stmt = $pdo->prepare("
            SELECT 
                s.id,
                s.nama_server,
                s.kode_server,
                s.lokasi,
                s.status,
                s.created_at,
                s.updated_at,
                COUNT(DISTINCT ss.id) as active_sessions,
                COUNT(DISTINCT tt.user_id) as total_users,
                COALESCE(SUM(tt.harga_total), 0) as total_revenue
            FROM server s
            LEFT JOIN sesi_server ss ON s.id = ss.server_id AND ss.status = 'active' AND ss.tanggal_sesi = CURDATE()
            LEFT JOIN transaksi_tebakan tt ON ss.id = tt.sesi_server_id AND tt.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            WHERE s.created_by = ? OR s.owner_id = ?
            GROUP BY s.id, s.nama_server, s.kode_server, s.lokasi, s.status, s.created_at, s.updated_at
            ORDER BY s.created_at DESC
        ");
        
        $stmt->execute([$bosId, $bosId]);
        $servers = $stmt->fetchAll();

        // Format data for response
        $formattedServers = array_map(function($server) {
            return [
                'id' => (int)$server['id'],
                'nama_server' => $server['nama_server'],
                'kode_server' => $server['kode_server'],
                'lokasi' => $server['lokasi'],
                'status' => $server['status'],
                'active_sessions' => (int)$server['active_sessions'],
                'total_users' => (int)$server['total_users'],
                'total_revenue' => (float)$server['total_revenue'],
                'created_at' => $server['created_at'],
                'updated_at' => $server['updated_at']
            ];
        }, $servers);

        sendJsonResponse(true, $formattedServers, null, 200);

    } catch (Exception $e) {
        error_log("Get Servers Error: " . $e->getMessage());
        sendJsonResponse(false, null, 'Failed to retrieve servers', 500);
    }
}

// =====================================================
// CREATE SERVER
// =====================================================

function handleCreateServer($pdo, $bosId, $clientIP) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            sendJsonResponse(false, null, 'Invalid JSON input', 400);
        }

        // Validation rules
        $validationRules = [
            'nama_server' => [
                'required' => true,
                'min_length' => 3,
                'max_length' => 100
            ],
            'kode_server' => [
                'required' => false,
                'max_length' => 20,
                'pattern' => '/^[A-Z0-9_-]*$/'
            ],
            'lokasi' => [
                'required' => true,
                'min_length' => 3,
                'max_length' => 100
            ],
            'alamat_lengkap' => [
                'required' => false,
                'max_length' => 500
            ],
            'provinsi_id' => [
                'required' => false,
                'type' => 'numeric'
            ],
            'kabupaten_kota_id' => [
                'required' => false,
                'type' => 'numeric'
            ],
            'kecamatan_id' => [
                'required' => false,
                'type' => 'numeric'
            ],
            'kelurahan_desa_id' => [
                'required' => false,
                'type' => 'numeric'
            ]
        ];

        $validation = validateAndSanitizeInput($input, $validationRules);
        
        if (!$validation['valid']) {
            sendJsonResponse(false, null, implode(', ', $validation['errors']), 400);
        }

        $data = $validation['data'];

        // Auto-generate kode_server if not provided
        if (empty($data['kode_server'])) {
            $data['kode_server'] = generateServerCode($pdo, $data['nama_server']);
        }

        // Check if server code already exists
        $stmt = $pdo->prepare("SELECT id FROM server WHERE kode_server = ?");
        $stmt->execute([$data['kode_server']]);
        if ($stmt->fetch()) {
            sendJsonResponse(false, null, 'Kode server sudah digunakan', 409);
        }

        // Start transaction
        $pdo->beginTransaction();

        // Insert server
        $stmt = $pdo->prepare("
            INSERT INTO server (
                nama_server, kode_server, lokasi, alamat_lengkap,
                provinsi_id, kabupaten_kota_id, kecamatan_id, kelurahan_desa_id,
                created_by, owner_id, status, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW())
        ");
        
        $stmt->execute([
            $data['nama_server'],
            $data['kode_server'],
            $data['lokasi'],
            $data['alamat_lengkap'],
            $data['provinsi_id'],
            $data['kabupaten_kota_id'],
            $data['kecamatan_id'],
            $data['kelurahan_desa_id'],
            $bosId,
            $bosId
        ]);

        $serverId = $pdo->lastInsertId();

        // Create default bet types for the server
        createDefaultBetTypes($pdo, $serverId);

        // Log the action
        $stmt = $pdo->prepare("
            INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values, ip_address, created_at) 
            VALUES (?, 'CREATE_SERVER', 'server', ?, ?, ?, NOW())
        ");
        $stmt->execute([
            $bosId,
            $serverId,
            json_encode(['server_data' => $data]),
            $clientIP
        ]);

        $pdo->commit();

        sendJsonResponse(true, [
            'server_id' => $serverId,
            'kode_server' => $data['kode_server'],
            'message' => 'Server berhasil dibuat'
        ], null, 201);

    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollback();
        }
        error_log("Create Server Error: " . $e->getMessage());
        sendJsonResponse(false, null, 'Failed to create server', 500);
    }
}

// =====================================================
// HELPER FUNCTIONS
// =====================================================

function generateServerCode($pdo, $serverName) {
    // Generate code from server name
    $words = explode(' ', strtoupper($serverName));
    $code = '';
    
    foreach ($words as $word) {
        if (strlen($word) > 0) {
            $code .= substr($word, 0, 2);
        }
    }
    
    // Add random number
    $code .= str_pad(rand(1, 999), 3, '0', STR_PAD_LEFT);
    
    // Check if code exists, if yes, regenerate
    $stmt = $pdo->prepare("SELECT id FROM server WHERE kode_server = ?");
    $stmt->execute([$code]);
    
    if ($stmt->fetch()) {
        // Recursive call with timestamp
        $code = substr($code, 0, 4) . date('His');
    }
    
    return substr($code, 0, 20); // Max 20 characters
}

function createDefaultBetTypes($pdo, $serverId) {
    $defaultBetTypes = [
        ['kode' => '4D', 'nama' => '4 Digit', 'hadiah_persen' => 66.0],
        ['kode' => '3D', 'nama' => '3 Digit', 'hadiah_persen' => 59.5],
        ['kode' => '2D', 'nama' => '2 Digit', 'hadiah_persen' => 70.0],
        ['kode' => 'CB', 'nama' => 'Colok Bebas', 'hadiah_persen' => 12.0],
        ['kode' => 'CM', 'nama' => 'Colok Macau', 'hadiah_persen' => 33.0],
        ['kode' => 'CN', 'nama' => 'Colok Naga', 'hadiah_persen' => 24.0]
    ];

    $stmt = $pdo->prepare("
        INSERT INTO tipe_tebakan (server_id, kode_tipe, nama_tipe, hadiah_persen, is_active, created_at)
        VALUES (?, ?, ?, ?, 1, NOW())
    ");

    foreach ($defaultBetTypes as $betType) {
        $stmt->execute([
            $serverId,
            $betType['kode'],
            $betType['nama'],
            $betType['hadiah_persen']
        ]);
    }
}

// UPDATE SERVER (Placeholder)
function handleUpdateServer($pdo, $bosId, $clientIP) {
    sendJsonResponse(false, null, 'Update server functionality will be implemented soon', 501);
}

// DELETE SERVER (Placeholder)  
function handleDeleteServer($pdo, $bosId, $clientIP) {
    sendJsonResponse(false, null, 'Delete server functionality will be implemented soon', 501);
}
?>