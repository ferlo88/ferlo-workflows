---
name: env
description: Gestisce variabili ambiente tra dev, staging e produzione
---

# /env - Environment Manager

Gestisce file .env e variabili d'ambiente tra diversi environment.

## Uso

```bash
/env                    # Mostra stato attuale
/env compare            # Confronta .env con .env.example
/env sync               # Sincronizza variabili mancanti
/env switch staging     # Passa a environment staging
/env export prod        # Esporta variabili per produzione
/env encrypt            # Cripta .env per commit sicuro
```

## Comandi

### `/env` - Status

Mostra:
- Environment attuale (APP_ENV)
- Variabili critiche configurate
- Variabili mancanti rispetto a .env.example
- Warning per valori di default pericolosi

```bash
# Check environment
grep "APP_ENV=" .env

# Variabili critiche
grep -E "^(APP_KEY|DB_|MAIL_|QUEUE_|CACHE_)" .env
```

### `/env compare` - Confronta

Confronta `.env` con `.env.example`:

```bash
# Variabili in .example ma non in .env
comm -23 <(grep -oP "^[A-Z_]+(?==)" .env.example | sort) \
         <(grep -oP "^[A-Z_]+(?==)" .env | sort)

# Variabili in .env ma non in .example
comm -13 <(grep -oP "^[A-Z_]+(?==)" .env.example | sort) \
         <(grep -oP "^[A-Z_]+(?==)" .env | sort)
```

Output:
```
Missing in .env (from .example):
  - NEW_SERVICE_KEY
  - FEATURE_FLAG_X

Extra in .env (not in .example):
  - LEGACY_API_KEY
  - DEBUG_MODE

Differences:
  APP_DEBUG: true → false (example)
```

### `/env sync` - Sincronizza

Aggiunge variabili mancanti da .env.example:

```bash
# Backup prima
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Aggiungi mancanti con valore di default
while IFS='=' read -r key value; do
    if ! grep -q "^$key=" .env; then
        echo "$key=$value" >> .env
        echo "Added: $key"
    fi
done < .env.example
```

### `/env switch [environment]` - Cambia Environment

Mantiene file separati per ogni environment:

```
.env                 # Attivo
.env.local           # Sviluppo locale
.env.staging         # Staging
.env.production      # Produzione (solo reference, mai usare direttamente)
```

```bash
# Backup corrente
cp .env .env.$(grep APP_ENV .env | cut -d= -f2)

# Switch
cp .env.staging .env
echo "Switched to staging environment"
```

### `/env export [environment]` - Esporta

Genera file per deploy:

```bash
# Per Docker
/env export docker
# Output: .env.docker con formato KEY=value

# Per server (escaped)
/env export server
# Output: export KEY="value"

# Per CI/CD (GitHub Actions format)
/env export github
# Output: KEY=value (per $GITHUB_ENV)
```

### `/env encrypt` - Cripta

Cripta .env per commit sicuro:

```bash
# Richiede: LARAVEL_ENV_ENCRYPTION_KEY

# Encrypt
php artisan env:encrypt --env=production

# Output: .env.production.encrypted

# Decrypt (in deploy)
php artisan env:decrypt --env=production --key=$LARAVEL_ENV_ENCRYPTION_KEY
```

## Struttura Consigliata

```
project/
├── .env                      # Attivo (gitignored)
├── .env.example              # Template (committed)
├── .env.local                # Dev locale (gitignored)
├── .env.staging              # Staging (gitignored)
├── .env.testing              # Per test (committed)
├── .env.production.encrypted # Prod criptato (committed)
└── .gitignore
```

## .gitignore Raccomandato

```gitignore
.env
.env.local
.env.staging
.env.production
.env.backup.*
!.env.example
!.env.testing
!.env.*.encrypted
```

## Variabili Critiche da Verificare

### Sicurezza
```bash
# Deve essere unica e lunga
APP_KEY=base64:...

# Mai true in produzione
APP_DEBUG=false

# HTTPS in produzione
APP_URL=https://...
```

### Database
```bash
DB_CONNECTION=mysql
DB_HOST=127.0.0.1    # o hostname produzione
DB_DATABASE=app_db
DB_USERNAME=app_user
DB_PASSWORD=strong_password  # Mai vuoto!
```

### Cache/Session
```bash
CACHE_DRIVER=redis      # Non 'file' in produzione
SESSION_DRIVER=redis    # Non 'file' in produzione
QUEUE_CONNECTION=redis  # Non 'sync' in produzione
```

### Mail
```bash
MAIL_MAILER=smtp        # Non 'log' in produzione
MAIL_FROM_ADDRESS=noreply@domain.com  # Valido!
```

## Validazione Pre-Deploy

Checklist automatica:

- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_KEY` è impostato
- [ ] `APP_URL` usa HTTPS
- [ ] `DB_PASSWORD` non è vuoto
- [ ] `CACHE_DRIVER` non è 'array' o 'file'
- [ ] `SESSION_DRIVER` non è 'array' o 'file'
- [ ] `QUEUE_CONNECTION` non è 'sync'
- [ ] `MAIL_MAILER` non è 'log' o 'array'
- [ ] Nessuna variabile con 'password', 'secret', 'key' ha valore di default

## Script Validazione

```bash
#!/bin/bash
# scripts/validate-env.sh

ERRORS=0

check_var() {
    local var=$1
    local forbidden=$2
    local value=$(grep "^$var=" .env | cut -d= -f2)

    if [ -z "$value" ]; then
        echo "❌ $var is not set"
        ERRORS=$((ERRORS+1))
    elif [ "$value" = "$forbidden" ]; then
        echo "❌ $var should not be '$forbidden'"
        ERRORS=$((ERRORS+1))
    else
        echo "✓ $var is set"
    fi
}

echo "Validating .env for production..."
echo ""

check_var "APP_KEY" ""
check_var "APP_DEBUG" "true"
check_var "DB_PASSWORD" ""
check_var "CACHE_DRIVER" "array"
check_var "SESSION_DRIVER" "array"
check_var "QUEUE_CONNECTION" "sync"

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "❌ Found $ERRORS error(s)"
    exit 1
else
    echo "✓ All checks passed"
fi
```
