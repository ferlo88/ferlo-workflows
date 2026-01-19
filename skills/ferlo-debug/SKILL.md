---
name: ferlo-debug
description: This skill helps troubleshoot and debug Laravel applications. Use when user asks for "debug", "fix error", "troubleshoot", "why not working", "error message", "exception", "500 error", or "investigate issue".
version: 1.0.0
---

# Debug & Troubleshooting Workflow

Guida al debugging sistematico di applicazioni Laravel.

## Workflow di Debug

### 1. Raccogli Informazioni
```bash
# Log recenti
tail -100 storage/logs/laravel.log

# Ultimo errore
cat storage/logs/laravel.log | grep -A 20 "$(date +%Y-%m-%d)"
```

### 2. Riproduci il Problema
- Identifica i passi esatti per riprodurre
- Nota l'ambiente (browser, user, dati)
- Verifica se è intermittente o costante

### 3. Isola la Causa
- Commenta codice sospetto
- Aggiungi logging strategico
- Usa dd(), dump(), Log::debug()

## Errori Comuni Laravel

### 500 Internal Server Error
```bash
# Verifica permessi
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Verifica .env
php artisan config:clear

# Verifica log
tail -f storage/logs/laravel.log
```

### Class Not Found
```bash
# Ricarica autoloader
composer dump-autoload

# Clear cache
php artisan clear-compiled
php artisan optimize:clear
```

### CSRF Token Mismatch
```php
// Verifica in blade
@csrf

// Verifica in AJAX
headers: {
    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
}

// Escludi route se necessario (api)
// app/Http/Middleware/VerifyCsrfToken.php
protected $except = [
    'webhook/*',
];
```

### Database Errors

#### Connection Refused
```bash
# Verifica .env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nome_db
DB_USERNAME=user
DB_PASSWORD=password

# Testa connessione
php artisan tinker
>>> DB::connection()->getPdo()
```

#### Migration Errors
```bash
# Reset e rimigra (solo sviluppo!)
php artisan migrate:fresh --seed

# Rollback singola migration
php artisan migrate:rollback --step=1
```

### Memory/Timeout Issues
```php
// Temporaneo nel controller
ini_set('memory_limit', '256M');
set_time_limit(300);

// In php.ini
memory_limit = 256M
max_execution_time = 300
```

## Strumenti di Debug

### Laravel Telescope
```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

Accedi a: `/telescope`

### Laravel Debugbar
```bash
composer require barryvdh/laravel-debugbar --dev
```

### Tinker per Test Rapidi
```bash
php artisan tinker

# Test query
>>> User::where('email', 'test@example.com')->first()

# Test relazioni
>>> $user->posts()->count()

# Test service
>>> app(MyService::class)->process()
```

### Ray (se disponibile)
```php
ray($variable);
ray()->measure();
ray()->showQueries();
```

## Debug Specifici

### Query N+1
```php
// Installa debugbar e cerca "N+1 detected"

// Soluzione: Eager loading
$posts = Post::with(['user', 'comments'])->get();
```

### Slow Queries
```php
// Abilita query log
DB::enableQueryLog();

// Esegui operazioni...

// Vedi queries
dd(DB::getQueryLog());
```

### Queue Jobs che Falliscono
```bash
# Vedi jobs falliti
php artisan queue:failed

# Retry singolo job
php artisan queue:retry <id>

# Retry tutti
php artisan queue:retry all

# Clear failed
php artisan queue:flush
```

### Session Issues
```bash
# Clear session
php artisan session:table
php artisan migrate
php artisan config:clear

# Verifica driver
SESSION_DRIVER=file # o database, redis
```

## Logging Strategico

```php
use Illuminate\Support\Facades\Log;

// Livelli
Log::emergency($message);
Log::alert($message);
Log::critical($message);
Log::error($message);
Log::warning($message);
Log::notice($message);
Log::info($message);
Log::debug($message);

// Con contesto
Log::info('User login', [
    'user_id' => $user->id,
    'ip' => request()->ip(),
    'user_agent' => request()->userAgent(),
]);

// Channel specifico
Log::channel('slack')->critical('Server down!');
```

## Checklist Debug

- [ ] Controllato storage/logs/laravel.log?
- [ ] Verificato .env configurazione?
- [ ] Cache pulita (config, route, view)?
- [ ] Permessi corretti su storage/?
- [ ] Riprodotto il problema localmente?
- [ ] Aggiunto logging per tracciare?
- [ ] Verificato database connection?
- [ ] Controllato queue failed jobs?
