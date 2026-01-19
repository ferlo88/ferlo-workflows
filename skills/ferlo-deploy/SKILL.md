---
name: ferlo-deploy
description: This skill handles deployment workflows for Laravel projects on Plesk, shared hosting, or VPS. Use when user asks for "deploy", "deploy to production", "server setup", "plesk deploy", "deployment script", or "go live".
version: 1.0.0
---

# Deployment Workflow

Gestisce il deploy di progetti Laravel su vari ambienti.

## Pre-Deploy Checklist

### 1. Verifica Codice
```bash
# Status git
git status

# Test passano
php artisan test

# Code style OK
./vendor/bin/pint --test

# Static analysis
./vendor/bin/phpstan analyse
```

### 2. Verifica Configurazione
- [ ] `.env.production` preparato
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] Database credentials corrette
- [ ] Mail settings configurati
- [ ] Storage path corretto

### 3. Build Assets
```bash
npm run build
```

## Script Deploy Standard

### deploy-production.sh
```bash
#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# 1. Maintenance mode
php artisan down --retry=60

# 2. Pull latest code
git pull origin main

# 3. Install dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# 4. Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 5. Run migrations
php artisan migrate --force

# 6. Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan icons:cache

# 7. Restart queue (if using)
php artisan queue:restart

# 8. Exit maintenance
php artisan up

echo "✅ Deployment completed!"
```

### deploy-quick.sh (solo codice)
```bash
#!/bin/bash
echo "⚡ Quick deploy..."

git pull origin main
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Done!"
```

## Deploy su Plesk

### Configurazione Iniziale
1. **Document Root**: `httpdocs/public`
2. **PHP Version**: 8.2+
3. **SSL**: Let's Encrypt attivo

### .htaccess (public/)
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
```

### Scheduled Tasks (Plesk)
```
* * * * * cd /var/www/vhosts/domain.com/httpdocs && php artisan schedule:run >> /dev/null 2>&1
```

### Storage Link
```bash
php artisan storage:link
```
O manualmente:
```bash
ln -s ../storage/app/public public/storage
```

## Deploy con Git (automatico)

### Post-receive hook
```bash
#!/bin/bash
# .git/hooks/post-receive

TARGET="/var/www/vhosts/domain.com/httpdocs"
GIT_DIR="/var/www/vhosts/domain.com/repo.git"

while read oldrev newrev ref
do
    BRANCH=$(git rev-parse --symbolic --abbrev-ref $ref)

    if [ "$BRANCH" == "main" ]; then
        echo "Deploying main branch..."
        git --work-tree=$TARGET --git-dir=$GIT_DIR checkout -f

        cd $TARGET
        composer install --no-dev --optimize-autoloader
        php artisan migrate --force
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
    fi
done
```

## Rollback

### Rollback Migration
```bash
php artisan migrate:rollback --step=1
```

### Rollback Codice
```bash
# Trova ultimo commit funzionante
git log --oneline -10

# Rollback
git revert HEAD
# oppure
git reset --hard <commit-hash>
git push --force origin main
```

## Monitoring Post-Deploy

### Verifica Immediata
```bash
# Log errori
tail -f storage/logs/laravel.log

# Health check
curl -I https://domain.com/health
```

### Checklist Post-Deploy
- [ ] Homepage carica
- [ ] Login funziona
- [ ] Form submission OK
- [ ] Upload file funziona
- [ ] Email inviate correttamente
- [ ] Queue processing attivo
