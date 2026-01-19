---
name: ferlo-laravel-upgrade
description: Guida all'upgrade di versioni Laravel. Usa quando l'utente chiede "upgrade Laravel", "aggiornare Laravel", "migrare a Laravel 11", "breaking changes", o "upgrade guide".
version: 1.0.0
---

# Laravel Upgrade Assistant

Guida passo-passo per l'upgrade di versioni Laravel con checklist e fix automatici.

## Versioni Supportate

| Da | A | Complessità |
|----|---|-------------|
| 10.x | 11.x | Media |
| 9.x | 10.x | Bassa |
| 8.x | 9.x | Media |
| 8.x | 11.x | Alta (multi-step) |

## Pre-Upgrade Checklist

```bash
# 1. Verifica versione attuale
php artisan --version

# 2. Verifica PHP version
php -v

# 3. Backup completo
mysqldump -u root -p database > backup_pre_upgrade.sql
cp -r . ../project_backup_$(date +%Y%m%d)

# 4. Commit tutto
git add -A && git commit -m "chore: pre-upgrade snapshot"

# 5. Crea branch upgrade
git checkout -b upgrade/laravel-11
```

## Laravel 10.x → 11.x

### Requisiti

- PHP 8.2+ (era 8.1+)
- Composer 2.2+

### Step 1: Aggiorna composer.json

```json
{
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.9"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.0",
        "phpunit/phpunit": "^11.0",
        "spatie/laravel-ignition": "^2.4"
    }
}
```

### Step 2: Aggiorna dipendenze

```bash
composer update
```

### Step 3: Breaking Changes

#### Struttura Directory (Opzionale ma Consigliato)

Laravel 11 ha una struttura semplificata. Puoi mantenerla o adottare la nuova:

```
# Nuova struttura Laravel 11
app/
├── Http/
│   └── Controllers/
├── Models/
└── Providers/
    └── AppServiceProvider.php  # Unico provider

bootstrap/
├── app.php      # Configurazione applicazione
└── providers.php # Lista providers

# Rimossi (opzionalmente):
# - app/Console/Kernel.php (usa bootstrap/app.php)
# - app/Http/Kernel.php (usa bootstrap/app.php)
# - app/Exceptions/Handler.php (usa bootstrap/app.php)
```

#### Nuova bootstrap/app.php

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Middleware customizzati
        $middleware->alias([
            'admin' => \App\Http\Middleware\AdminMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Exception handling
    })
    ->create();
```

#### Cambiamenti Middleware

```php
// PRIMA (Kernel.php)
protected $middlewareGroups = [
    'web' => [...],
    'api' => [...],
];

// DOPO (bootstrap/app.php)
->withMiddleware(function (Middleware $middleware) {
    $middleware->web(append: [
        \App\Http\Middleware\CustomMiddleware::class,
    ]);

    $middleware->api(prepend: [
        \App\Http\Middleware\ApiMiddleware::class,
    ]);
})
```

#### Cambiamenti Schedule

```php
// PRIMA (app/Console/Kernel.php)
protected function schedule(Schedule $schedule)
{
    $schedule->command('inspire')->hourly();
}

// DOPO (routes/console.php)
use Illuminate\Support\Facades\Schedule;

Schedule::command('inspire')->hourly();
```

#### Cambiamenti Exception Handler

```php
// PRIMA (app/Exceptions/Handler.php)
public function register()
{
    $this->reportable(function (Throwable $e) {
        //
    });
}

// DOPO (bootstrap/app.php)
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->reportable(function (Throwable $e) {
        //
    });
})
```

### Step 4: Aggiorna Config Files

```bash
# Pubblica nuovi config
php artisan config:publish

# Confronta con tuoi config esistenti
diff config/app.php vendor/laravel/framework/config/app.php
```

### Step 5: Test

```bash
# Clear cache
php artisan optimize:clear

# Run tests
php artisan test

# Verifica manuale
php artisan serve
```

## Laravel 9.x → 10.x

### Requisiti

- PHP 8.1+

### Breaking Changes Principali

```php
// 1. Return types obbligatori su molti metodi

// PRIMA
public function rules()
{
    return [...];
}

// DOPO
public function rules(): array
{
    return [...];
}

// 2. Middleware terminable
// Se hai middleware custom con terminate(), verifica signature

// 3. Password validation
// Usa Password::min(8) invece di 'min:8'
```

## Laravel 8.x → 9.x

### Requisiti

- PHP 8.0+

### Breaking Changes Principali

```php
// 1. Route::controller() syntax cambiata
// PRIMA
Route::group(['controller' => FooController::class], function () {
    Route::get('/foo', 'index');
});

// DOPO
Route::controller(FooController::class)->group(function () {
    Route::get('/foo', 'index');
});

// 2. Accessor/Mutator syntax
// PRIMA
public function getNameAttribute($value)
{
    return ucfirst($value);
}

// DOPO (nuovo modo, vecchio ancora supportato)
protected function name(): Attribute
{
    return Attribute::make(
        get: fn ($value) => ucfirst($value),
    );
}

// 3. Query Builder
// whereDate, whereMonth, etc. ora strettamente tipizzati
```

## Script Upgrade Automatico

```bash
#!/bin/bash
# scripts/upgrade-laravel.sh

echo "Laravel Upgrade Assistant"
echo "========================="

# Check current version
CURRENT=$(php artisan --version | grep -oP '\d+\.\d+')
echo "Current version: $CURRENT"

# Backup
echo "Creating backup..."
git stash
git checkout -b upgrade/laravel-$(date +%Y%m%d)

# Update composer.json
echo "Updating composer.json..."
# ... sed commands to update versions

# Composer update
echo "Running composer update..."
composer update --with-all-dependencies

# Clear caches
echo "Clearing caches..."
php artisan optimize:clear

# Run tests
echo "Running tests..."
php artisan test

echo "Done! Please review changes and test manually."
```

## Checklist Post-Upgrade

- [ ] `composer update` senza errori
- [ ] `php artisan optimize:clear` OK
- [ ] Tutte le route funzionano
- [ ] Test passano
- [ ] Form/CSRF funzionano
- [ ] Auth funziona
- [ ] Queue/Jobs funzionano
- [ ] Scheduled tasks funzionano
- [ ] Email funzionano
- [ ] File upload funziona
- [ ] API endpoints funzionano
- [ ] Third-party packages compatibili

## Troubleshooting

### Errore: Class not found

```bash
composer dump-autoload
php artisan clear-compiled
```

### Errore: Config/Route cache

```bash
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Package incompatibile

```bash
# Verifica versione compatibile
composer show package/name --all | grep versions

# Forza versione specifica
composer require package/name:^X.Y
```

## Risorse Ufficiali

- Laravel 11 Upgrade Guide: https://laravel.com/docs/11.x/upgrade
- Laravel 10 Upgrade Guide: https://laravel.com/docs/10.x/upgrade
- Laravel Shift (automazione): https://laravelshift.com
