---
name: ferlo-db-snapshot
description: This skill creates and restores database snapshots before risky operations. Use when user asks for "backup database", "db snapshot", "save database", "restore database", "before migrate fresh", or mentions destructive database operations.
version: 1.0.0
---

# DB Snapshot - Database Backup & Restore

Crea e ripristina snapshot del database prima di operazioni rischiose.

## Quando Usare

**SEMPRE** prima di:
- `php artisan migrate:fresh`
- `php artisan db:wipe`
- `php artisan migrate:reset`
- Modifiche massive ai dati
- Test con dati reali

## Comandi Snapshot

### Crea Snapshot

```bash
# MySQL
mysqldump -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE > storage/snapshots/$(date +%Y%m%d_%H%M%S).sql

# Con compressione
mysqldump -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE | gzip > storage/snapshots/$(date +%Y%m%d_%H%M%S).sql.gz
```

### Laravel-friendly

```bash
# Crea directory se non esiste
mkdir -p storage/snapshots

# Snapshot con nome descrittivo
php artisan db:dump storage/snapshots/before_migration_$(date +%Y%m%d_%H%M%S).sql
```

### Usando Laravel Packages

Con `spatie/laravel-backup`:

```bash
php artisan backup:run --only-db
```

## Restore Snapshot

```bash
# MySQL
mysql -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE < storage/snapshots/20260119_120000.sql

# Da file compresso
gunzip < storage/snapshots/20260119_120000.sql.gz | mysql -u $DB_USERNAME -p$DB_PASSWORD $DB_DATABASE
```

## Script Automatico

```bash
#!/bin/bash
# scripts/db-snapshot.sh

DB_NAME="${DB_DATABASE:-laravel}"
SNAPSHOT_DIR="storage/snapshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $SNAPSHOT_DIR

echo "Creating snapshot..."
mysqldump -u root $DB_NAME > "$SNAPSHOT_DIR/${DB_NAME}_${TIMESTAMP}.sql"

if [ $? -eq 0 ]; then
    echo "✅ Snapshot created: ${SNAPSHOT_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

    # Mantieni solo ultimi 5 snapshot
    ls -t $SNAPSHOT_DIR/*.sql | tail -n +6 | xargs -r rm

    echo "Old snapshots cleaned up."
else
    echo "❌ Snapshot failed!"
    exit 1
fi
```

## Integrazione con Migration

Prima di `migrate:fresh`:

```php
// In un command custom
public function handle()
{
    // Backup automatico
    $this->call('db:dump', [
        'path' => storage_path('snapshots/pre_fresh_' . now()->format('Ymd_His') . '.sql')
    ]);

    // Procedi con fresh
    $this->call('migrate:fresh', ['--seed' => true]);
}
```

## Configurazione .env

```env
# Snapshot settings
DB_SNAPSHOT_DIR=storage/snapshots
DB_SNAPSHOT_KEEP=5
DB_SNAPSHOT_COMPRESS=true
```

## Checklist Pre-Operazione Rischiosa

- [ ] Snapshot creato?
- [ ] Snapshot verificato (file non vuoto)?
- [ ] Spazio disco sufficiente?
- [ ] Notificato team?
- [ ] Testato restore su ambiente dev?

## Best Practices

1. **Naming convention**: `{db}_{operation}_{timestamp}.sql`
2. **Comprimi** snapshot grandi (> 100MB)
3. **Verifica** dimensione file dopo dump
4. **Mantieni** ultimi N snapshot, elimina vecchi
5. **Non committare** snapshot in git (aggiungi a .gitignore)

## .gitignore

```
storage/snapshots/*.sql
storage/snapshots/*.sql.gz
```
