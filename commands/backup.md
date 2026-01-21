---
name: backup
description: Crea backup completo del progetto (database, storage, configurazione)
---

# /backup - Backup Manager

Crea e gestisce backup completi del progetto Laravel.

## Uso

```bash
/backup                     # Backup completo
/backup db                  # Solo database
/backup files               # Solo storage files
/backup config              # Solo configurazione
/backup --upload=s3         # Upload su S3
/backup restore 20240115    # Ripristina backup
```

## Comandi

### `/backup` - Backup Completo

```bash
#!/bin/bash
# scripts/backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="storage/backups/${TIMESTAMP}"
PROJECT_NAME=$(basename $(pwd))

mkdir -p $BACKUP_DIR

echo "Starting backup: $TIMESTAMP"

# 1. Database
echo "Backing up database..."
php artisan db:dump $BACKUP_DIR/database.sql

# 2. Storage
echo "Backing up storage..."
tar -czf $BACKUP_DIR/storage.tar.gz storage/app

# 3. Config
echo "Backing up configuration..."
cp .env $BACKUP_DIR/.env.backup
tar -czf $BACKUP_DIR/config.tar.gz config/

# 4. Composer lock
cp composer.lock $BACKUP_DIR/

# 5. Create manifest
cat > $BACKUP_DIR/manifest.json << EOF
{
    "timestamp": "$TIMESTAMP",
    "project": "$PROJECT_NAME",
    "laravel_version": "$(php artisan --version)",
    "php_version": "$(php -v | head -1)",
    "files": [
        "database.sql",
        "storage.tar.gz",
        "config.tar.gz",
        ".env.backup",
        "composer.lock"
    ]
}
EOF

# 6. Create single archive
tar -czf storage/backups/${PROJECT_NAME}_${TIMESTAMP}.tar.gz -C storage/backups ${TIMESTAMP}
rm -rf $BACKUP_DIR

echo "Backup complete: storage/backups/${PROJECT_NAME}_${TIMESTAMP}.tar.gz"
```

### `/backup db` - Solo Database

```bash
# MySQL
mysqldump -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE | gzip > storage/backups/db_$(date +%Y%m%d_%H%M%S).sql.gz

# PostgreSQL
pg_dump -U $DB_USERNAME $DB_DATABASE | gzip > storage/backups/db_$(date +%Y%m%d_%H%M%S).sql.gz

# Laravel (con spatie/laravel-backup)
php artisan backup:run --only-db
```

### `/backup files` - Solo Storage

```bash
tar -czf storage/backups/files_$(date +%Y%m%d_%H%M%S).tar.gz storage/app/public
```

### `/backup restore [timestamp]` - Ripristino

```bash
#!/bin/bash
# scripts/restore.sh

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore.sh <backup_file>"
    exit 1
fi

echo "Extracting backup..."
tar -xzf $BACKUP_FILE -C /tmp/restore_$$

RESTORE_DIR="/tmp/restore_$$"

# Restore database
if [ -f "$RESTORE_DIR/database.sql" ]; then
    echo "Restoring database..."
    mysql -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE < $RESTORE_DIR/database.sql
fi

# Restore storage
if [ -f "$RESTORE_DIR/storage.tar.gz" ]; then
    echo "Restoring storage..."
    tar -xzf $RESTORE_DIR/storage.tar.gz -C .
fi

# Cleanup
rm -rf $RESTORE_DIR

echo "Restore complete!"
```

## Spatie Laravel Backup (Raccomandato)

### Installazione

```bash
composer require spatie/laravel-backup
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"
```

### Configurazione

```php
// config/backup.php
return [
    'backup' => [
        'name' => env('APP_NAME', 'laravel-backup'),

        'source' => [
            'files' => [
                'include' => [
                    base_path(),
                ],
                'exclude' => [
                    base_path('vendor'),
                    base_path('node_modules'),
                    base_path('storage/backups'),
                ],
            ],

            'databases' => ['mysql'],
        ],

        'destination' => [
            'filename_prefix' => '',
            'disks' => ['local', 's3'],
        ],
    ],

    'cleanup' => [
        'strategy' => \Spatie\Backup\Tasks\Cleanup\Strategies\DefaultStrategy::class,

        'default_strategy' => [
            'keep_all_backups_for_days' => 7,
            'keep_daily_backups_for_days' => 16,
            'keep_weekly_backups_for_weeks' => 8,
            'keep_monthly_backups_for_months' => 4,
            'keep_yearly_backups_for_years' => 2,
            'delete_oldest_backups_when_using_more_megabytes_than' => 5000,
        ],
    ],

    'notifications' => [
        'mail' => [
            'to' => 'admin@example.com',
        ],
        'slack' => [
            'webhook_url' => env('BACKUP_SLACK_WEBHOOK_URL'),
        ],
    ],
];
```

### Comandi

```bash
# Backup completo
php artisan backup:run

# Solo database
php artisan backup:run --only-db

# Solo files
php artisan backup:run --only-files

# Lista backup
php artisan backup:list

# Pulizia vecchi backup
php artisan backup:clean

# Monitor health
php artisan backup:monitor
```

### Schedule

```php
// routes/console.php (Laravel 11+)
use Illuminate\Support\Facades\Schedule;

// Backup giornaliero alle 2:00
Schedule::command('backup:run')->dailyAt('02:00');

// Cleanup settimanale
Schedule::command('backup:clean')->weekly();

// Monitor
Schedule::command('backup:monitor')->dailyAt('03:00');
```

## Upload su Cloud

### S3

```php
// config/filesystems.php
'disks' => [
    's3-backups' => [
        'driver' => 's3',
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION'),
        'bucket' => env('AWS_BACKUP_BUCKET'),
    ],
],
```

```bash
# Upload manuale
aws s3 cp storage/backups/backup.tar.gz s3://bucket-name/backups/
```

### Google Cloud Storage

```bash
gsutil cp storage/backups/backup.tar.gz gs://bucket-name/backups/
```

## Backup Automatici Docker

```yaml
# docker-compose.yml
services:
  backup:
    image: databack/mysql-backup
    environment:
      - DB_SERVER=mysql
      - DB_USER=root
      - DB_PASS=password
      - DB_NAMES=laravel
      - DB_DUMP_CRON=0 2 * * *
      - AWS_ACCESS_KEY_ID=xxx
      - AWS_SECRET_ACCESS_KEY=xxx
      - AWS_DEFAULT_REGION=eu-west-1
      - DB_DUMP_TARGET=s3://bucket/backups
    depends_on:
      - mysql
```

## Verifica Backup

```bash
#!/bin/bash
# scripts/verify-backup.sh

BACKUP=$1

# Estrai in temp
TEMP_DIR=$(mktemp -d)
tar -xzf $BACKUP -C $TEMP_DIR

# Verifica database
if [ -f "$TEMP_DIR/database.sql" ]; then
    # Test restore su DB temp
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS backup_test"
    mysql -u root backup_test < $TEMP_DIR/database.sql

    TABLES=$(mysql -u root backup_test -e "SHOW TABLES" | wc -l)
    echo "Database: $TABLES tables restored successfully"

    mysql -u root -e "DROP DATABASE backup_test"
fi

# Verifica storage
if [ -f "$TEMP_DIR/storage.tar.gz" ]; then
    FILES=$(tar -tzf $TEMP_DIR/storage.tar.gz | wc -l)
    echo "Storage: $FILES files in archive"
fi

# Cleanup
rm -rf $TEMP_DIR

echo "Backup verification complete!"
```

## Checklist Backup

- [ ] Backup automatico schedulato (daily)
- [ ] Backup database separato
- [ ] Backup storage/uploads
- [ ] Backup .env (criptato!)
- [ ] Upload su cloud storage
- [ ] Retention policy configurata
- [ ] Test restore periodico
- [ ] Notifiche backup failure
- [ ] Encryption at rest
- [ ] Documentazione restore procedure

## Retention Policy Consigliata

| Tipo | Retention |
|------|-----------|
| Daily | 7 giorni |
| Weekly | 4 settimane |
| Monthly | 12 mesi |
| Yearly | 3 anni |

## .gitignore

```gitignore
storage/backups/*.tar.gz
storage/backups/*.sql
storage/backups/*.sql.gz
```
