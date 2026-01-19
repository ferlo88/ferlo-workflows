---
name: deploy
description: Workflow di deploy per progetti Laravel su Plesk o server
---

# /deploy - Deploy Progetto

Esegue il workflow di deploy seguendo le best practices.

## Uso

```
/deploy              # Deploy standard
/deploy production   # Deploy in produzione
/deploy staging      # Deploy in staging
/deploy quick        # Deploy veloce (solo codice)
```

## Pre-Deploy Checklist

Prima del deploy, verifica automaticamente:

1. **Git Status**
   ```bash
   git status
   ```
   - [ ] Nessun file non committato
   - [ ] Branch corretto (main/master per production)

2. **Test**
   ```bash
   php artisan test
   ```
   - [ ] Tutti i test passano

3. **Build Assets**
   ```bash
   npm run build
   ```
   - [ ] Assets compilati senza errori

4. **Configurazione**
   - [ ] `.env.example` aggiornato
   - [ ] Nuove variabili d'ambiente documentate

## Deploy Workflow

### Standard Deploy
```bash
# 1. Pull changes
git pull origin main

# 2. Install dependencies
composer install --no-dev --optimize-autoloader

# 3. Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 4. Run migrations
php artisan migrate --force

# 5. Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Restart queue workers (se presenti)
php artisan queue:restart
```

### Quick Deploy (solo codice)
```bash
git pull origin main
php artisan config:cache
php artisan route:cache
```

## Post-Deploy

1. **Verifica applicazione**
   - [ ] Homepage carica
   - [ ] Login funziona
   - [ ] Funzionalità critiche OK

2. **Monitora log**
   ```bash
   tail -f storage/logs/laravel.log
   ```

## Script Deploy

Se esiste `deploy-production.sh` o `deploy-plesk.sh`, usalo:
```bash
./deploy-production.sh
```
