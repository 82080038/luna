# Database Migration Guide - Luna System v2.4

## Overview
Luna System telah dimigrasi dari single-database ke multi-database architecture untuk memisahkan data geografis dari business logic.

## Changes Summary

### Before Migration
```
sistem_angka Database:
├── orang_alamat (with kelurahan_desa_id)
├── negara
├── provinsi
├── kabupaten_kota
├── kecamatan
└── kelurahan_desa
```

### After Migration
```
sistem_angka Database:
└── orang_alamat (with geographic ID references)

sistem_alamat Database:
├── cbo_negara
├── cbo_propinsi
├── cbo_kab_kota
├── cbo_kecamatan
└── cbo_desa
```

## Migration Steps

### 1. Backup Database
```bash
# Backup sistem_angka
mysqldump -u root sistem_angka > backup_sistem_angka_$(date +%Y%m%d_%H%M%S).sql

# Backup sistem_alamat (if needed)
mysqldump -u root sistem_alamat > backup_sistem_alamat_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Run Cleanup Script
```bash
# Windows
cleanup_database.bat

# Manual execution
mysql -u root -e "USE sistem_angka; SOURCE db/cleanup_geographic_tables.sql;"
```

### 3. Verify Migration
```sql
-- Check tables in sistem_angka
USE sistem_angka;
SHOW TABLES;

-- Verify orang_alamat structure
DESCRIBE orang_alamat;

-- Check sistem_alamat tables
USE sistem_alamat;
SHOW TABLES;
```

## API Changes

### Updated Endpoints
All geographic API endpoints now use `sistem_alamat` database:

| Endpoint | Old Table | New Table | Changes |
|----------|-----------|-----------|---------|
| `get_provinsi.php` | `provinsi` | `cbo_propinsi` | `id` → `id_propinsi`, `nama` → `nama_propinsi` |
| `get_kabupaten.php` | `kabupaten_kota` | `cbo_kab_kota` | `id` → `id_kab_kota`, `nama` → `nama_kab_kota` |
| `get_kecamatan.php` | `kecamatan` | `cbo_kecamatan` | `id` → `id_kecamatan`, `nama` → `nama_kecamatan` |
| `get_kelurahan.php` | `kelurahan_desa` | `cbo_desa` | `id` → `id_desa`, `nama` → `nama_desa` |

### New Endpoints
- `get_negara.php` - Get country data from `cbo_negara`
- `get_alamat_lengkap.php` - Get complete address with geographic data
- `save_alamat.php` - Save address with geographic references

## Database Schema Changes

### orang_alamat Table
```sql
-- Removed column
DROP COLUMN kelurahan_desa_id;

-- Added columns
ADD COLUMN negara_id INT NULL;
ADD COLUMN provinsi_id INT NULL;
ADD COLUMN kabupaten_kota_id INT NULL;
ADD COLUMN kecamatan_id INT NULL;
ADD COLUMN desa_id INT NULL;

-- Added indexes
ADD INDEX idx_orang_alamat_negara (negara_id);
ADD INDEX idx_orang_alamat_provinsi (provinsi_id);
ADD INDEX idx_orang_alamat_kabupaten (kabupaten_kota_id);
ADD INDEX idx_orang_alamat_kecamatan (kecamatan_id);
ADD INDEX idx_orang_alamat_desa (desa_id);
```

### Removed Tables from sistem_angka
- `negara`
- `provinsi`
- `kabupaten_kota`
- `kecamatan`
- `kelurahan_desa`

## Frontend Changes Required

### Address Forms
Update address forms to use new API structure:

```javascript
// Old way
loadProvinsi(); // Used old provinsi table

// New way
loadProvinsi(); // Now uses cbo_propinsi table
```

### Data Structure
Address data now includes geographic IDs:

```javascript
// Old structure
{
  "kelurahan_desa_id": 123,
  "alamat_lengkap": "Jl. Example No. 1"
}

// New structure
{
  "negara_id": 1,
  "provinsi_id": 31,
  "kabupaten_kota_id": 3171,
  "kecamatan_id": 317101,
  "desa_id": 31710101,
  "alamat_lengkap": "Jl. Example No. 1"
}
```

## Benefits

### 1. Data Separation
- Geographic data is now centralized in `sistem_alamat`
- Business logic remains in `sistem_angka`
- Easier maintenance and updates

### 2. Performance
- Smaller `sistem_angka` database
- Efficient ID-based references
- Better query performance

### 3. Scalability
- Databases can be scaled independently
- Geographic data can be updated without affecting business logic
- Better backup strategies

### 4. Maintenance
- Geographic data updates don't require application changes
- Easier to manage data consistency
- Simplified data migration processes

## Troubleshooting

### Common Issues

#### 1. API Errors
```bash
# Check if sistem_alamat database exists
mysql -u root -e "SHOW DATABASES LIKE 'sistem_alamat';"

# Check if tables exist
mysql -u root -e "USE sistem_alamat; SHOW TABLES;"
```

#### 2. Missing Geographic Data
```sql
-- Check if data exists in sistem_alamat
USE sistem_alamat;
SELECT COUNT(*) FROM cbo_propinsi;
SELECT COUNT(*) FROM cbo_kab_kota;
SELECT COUNT(*) FROM cbo_kecamatan;
SELECT COUNT(*) FROM cbo_desa;
```

#### 3. Foreign Key Issues
```sql
-- Check orang_alamat data
USE sistem_angka;
SELECT * FROM orang_alamat WHERE negara_id IS NOT NULL LIMIT 5;
```

### Rollback Plan
If migration fails, restore from backup:

```bash
# Restore sistem_angka
mysql -u root sistem_angka < backup_sistem_angka_YYYYMMDD_HHMMSS.sql

# Restart application
```

## Testing

### API Testing
```bash
# Test geographic APIs
curl "http://localhost/luna/api/get_provinsi.php"
curl "http://localhost/luna/api/get_kabupaten.php?provinsi_id=31"
curl "http://localhost/luna/api/get_kecamatan.php?kabupaten_id=3171"
curl "http://localhost/luna/api/get_kelurahan.php?kecamatan_id=317101"

# Test new APIs
curl "http://localhost/luna/api/get_negara.php"
curl "http://localhost/luna/api/get_alamat_lengkap.php?orang_id=1"
```

### Database Testing
```sql
-- Test cross-database queries
USE sistem_angka;
SELECT 
    oa.id,
    oa.orang_id,
    oa.negara_id,
    oa.provinsi_id
FROM orang_alamat oa
WHERE oa.negara_id IS NOT NULL
LIMIT 5;
```

## Security Considerations

### Database Access
- Ensure proper permissions for cross-database access
- Use separate database users if needed
- Monitor database connections

### Data Validation
- Validate geographic IDs before saving
- Implement proper error handling
- Log database operations

## Performance Monitoring

### Key Metrics
- Database response times
- Cross-database query performance
- Memory usage
- Connection pool utilization

### Optimization
- Use appropriate indexes
- Implement caching where needed
- Monitor slow queries
- Regular database maintenance

---

**Migration Completed**: ✅  
**Version**: Luna System v2.4  
**Date**: December 2024  
**Status**: Production Ready 