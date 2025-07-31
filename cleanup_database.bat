@echo off
echo ========================================
echo Luna System - Database Cleanup Script
echo ========================================
echo.

echo Checking MySQL connectivity...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL command not found in PATH
    echo Please ensure MySQL is installed and in your PATH
    echo Or use full path to mysql.exe
    pause
    exit /b 1
)

echo MySQL found. Proceeding with database cleanup...
echo.

echo Step 1: Cleaning up geographic tables from sistem_angka...
mysql -u root -e "USE sistem_angka; SOURCE db/cleanup_geographic_tables.sql;"

if %errorlevel% neq 0 (
    echo ERROR: Failed to run cleanup script
    echo Please check if MySQL service is running and databases exist
    pause
    exit /b 1
)

echo.
echo Step 2: Verifying cleanup results...
mysql -u root -e "USE sistem_angka; SHOW TABLES LIKE '%negara%'; SHOW TABLES LIKE '%provinsi%'; SHOW TABLES LIKE '%kabupaten%'; SHOW TABLES LIKE '%kecamatan%'; SHOW TABLES LIKE '%kelurahan%';"

echo.
echo Step 3: Checking orang_alamat table structure...
mysql -u root -e "USE sistem_angka; DESCRIBE orang_alamat;"

echo.
echo Step 4: Testing new API endpoints...
echo Testing get_alamat_lengkap.php...
curl -s "http://localhost/luna/api/get_alamat_lengkap.php?orang_id=1" | findstr "success"

echo Testing save_alamat.php...
curl -s -X POST "http://localhost/luna/api/save_alamat.php" -H "Content-Type: application/json" -d "{\"orang_id\":1,\"alamat_jenis_id\":1,\"alamat_lengkap\":\"Test Address\"}" | findstr "success"

echo.
echo ========================================
echo Database cleanup completed successfully!
echo ========================================
echo.
echo Changes made:
echo - Removed geographic tables from sistem_angka
echo - Modified orang_alamat table to reference sistem_alamat
echo - Created new API endpoints for cross-database operations
echo - Updated views and stored procedures
echo.
echo Next steps:
echo 1. Update frontend forms to use new address structure
echo 2. Test address management functionality
echo 3. Update any existing code that references old geographic tables
echo.
pause 