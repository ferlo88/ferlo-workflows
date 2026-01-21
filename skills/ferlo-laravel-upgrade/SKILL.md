---
name: ferlo-laravel-upgrade
description: Guida all'upgrade di versioni Laravel. Usa quando l'utente chiede "upgrade Laravel", "aggiornare Laravel", "migrare a Laravel 12", "breaking changes", o "upgrade guide".
version: 2.0.0
---

# Laravel Upgrade Assistant

Guida passo-passo per l'upgrade di versioni Laravel con checklist e fix automatici.

**NOTA**: Prima di procedere con qualsiasi upgrade, verifica sempre la documentazione ufficiale:
- https://laravel.com/docs/master/upgrade

## Versioni Supportate

| Da | A | Complessità | Tempo Stimato |
|----|---|-------------|---------------|
| 11.x | 12.x | Bassa | ~5 minuti |
| 10.x | 11.x | Media | ~30 minuti |
| 9.x | 10.x | Bassa | ~15 minuti |
| 8.x | 9.x | Media | ~30 minuti |
| 8.x | 12.x | Alta (multi-step) | ~2 ore |

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

## Laravel 11.x → 12.x

### Requisiti

- PHP 8.2+ (rimane invariato)
- Composer 2.2+
- Carbon 3.x (obbligatorio, Carbon 2 non più supportato)

### Step 1: Aggiorna composer.json

```json
{
    "require": {
        "php": "^8.2",
        "laravel/framework": "^12.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.10"
    },
    "require-dev": {
        "fakerphp/faker": "^1.24",
        "laravel/pint": "^1.18",
        "laravel/sail": "^1.34",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.5",
        "phpunit/phpunit": "^11.0",
        "pestphp/pest": "^3.0"
    }
}
```

### Step 2: Aggiorna dipendenze

```bash
composer update
```

### Step 3: Breaking Changes

#### Carbon 3 (IMPORTANTE)

Laravel 12 richiede Carbon 3. Se usi Carbon direttamente:

```php
// Verifica la guida migration Carbon 2 → 3
// https://carbon.nesbot.com/guide/getting-started/migration.html

// Principali cambiamenti:
// - Alcune costanti rinominate
// - Alcuni metodi deprecati rimossi
```

#### UUIDv7 per HasUuids

Il trait `HasUuids` ora genera UUIDv7 (ordinati) invece di v4:

```php
// Per continuare a usare UUIDv4:
use Illuminate\Database\Eloquent\Concerns\HasVersion4Uuids as HasUuids;

class MyModel extends Model
{
    use HasUuids;
}
```

#### Validazione Immagini (SVG esclusi)

SVG non più accettati di default dalla regola `image`:

```php
// PRIMA (Laravel 11)
'photo' => 'required|image'  // SVG accettato

// DOPO (Laravel 12)
'photo' => 'required|image'  // SVG rifiutato

// Per permettere SVG:
'photo' => 'required|image:allow_svg'

// Oppure con File rule:
use Illuminate\Validation\Rules\File;
'photo' => ['required', File::image(allowSvg: true)]
```

#### Filesystem Local Disk Path

Il disco `local` ora usa `storage/app/private` invece di `storage/app`:

```php
// Per mantenere il comportamento precedente,
// definisci esplicitamente in config/filesystems.php:
'local' => [
    'driver' => 'local',
    'root' => storage_path('app'),
    // ...
],
```

#### Container: Default Property Values

Il container ora rispetta i valori default delle proprietà:

```php
class Example {
    public function __construct(public ?Carbon $date = null) {}
}

$example = resolve(Example::class);

// Laravel 11: $example->date instanceof Carbon (auto-resolved)
// Laravel 12: $example->date === null (rispetta default)
```

#### Database Grammar Constructor

Le classi Grammar ora richiedono Connection nel costruttore:

```php
// PRIMA (Laravel 11)
$grammar = new MySqlGrammar;
$grammar->setConnection($connection);

// DOPO (Laravel 12)
$grammar = new MySqlGrammar($connection);
```

Metodi deprecati/rimossi:
- `Blueprint::getPrefix()`
- `Connection::withTablePrefix()`
- `Grammar::getTablePrefix()`, `setTablePrefix()`, `setConnection()`

#### Multi-Schema Database Inspecting

Schema methods ora includono tutti gli schemi:

```php
// Tutte le tabelle di tutti gli schemi
$tables = Schema::getTables();

// Solo uno schema specifico
$tables = Schema::getTables(schema: 'main');

// Nomi qualificati con schema (nuovo default)
$tables = Schema::getTableListing();
// ['main.migrations', 'main.users']

// Nomi non qualificati
$tables = Schema::getTableListing(schema: 'main', schemaQualified: false);
```

#### Concurrency Results con Chiavi

Array associativi ora mantengono le chiavi:

```php
$result = Concurrency::run([
    'task-1' => fn () => 1 + 1,
    'task-2' => fn () => 2 + 2,
]);

// Ritorna: ['task-1' => 2, 'task-2' => 4]
```

### Step 4: Test

```bash
# Clear cache
php artisan optimize:clear

# Run tests
php artisan test

# Verifica manuale
php artisan serve
```

### Step 5: Aggiorna Laravel Installer

```bash
composer global update laravel/installer
```

---

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

- Laravel 12 Upgrade Guide: https://laravel.com/docs/12.x/upgrade
- Laravel 11 Upgrade Guide: https://laravel.com/docs/11.x/upgrade
- Laravel 10 Upgrade Guide: https://laravel.com/docs/10.x/upgrade
- Carbon 3 Migration: https://carbon.nesbot.com/guide/getting-started/migration.html
- Laravel Shift (automazione): https://laravelshift.com
- GitHub Comparison: https://github.com/laravel/laravel/compare/11.x...12.x
