---
name: ferlo-performance
description: This skill analyzes and optimizes Laravel application performance. Use when user asks for "performance", "slow query", "optimize", "N+1", "profiling", "speed up", "memory usage", or "bottleneck".
version: 1.0.0
---

# Performance Profiling & Optimization

Analizza e ottimizza le performance di applicazioni Laravel.

## Quick Diagnosis

### 1. Abilita Query Log

```php
// In AppServiceProvider o tinker
DB::enableQueryLog();

// Esegui operazioni...

// Vedi queries
dd(DB::getQueryLog());
```

### 2. Debugbar (sviluppo)

```bash
composer require barryvdh/laravel-debugbar --dev
```

Mostra: queries, tempo, memoria, views, route.

### 3. Telescope (sviluppo)

```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

Accedi a `/telescope` per analisi dettagliata.

## Problemi Comuni

### N+1 Query Problem

**Sintomo**: Molte query identiche con ID diversi

**Diagnosi**:
```php
// Debugbar mostra "N+1 detected"
// O in query log vedi:
// SELECT * FROM posts WHERE user_id = 1
// SELECT * FROM posts WHERE user_id = 2
// SELECT * FROM posts WHERE user_id = 3...
```

**Soluzione**: Eager Loading
```php
// ❌ Male
$users = User::all();
foreach ($users as $user) {
    echo $user->posts->count(); // Query per ogni user!
}

// ✅ Bene
$users = User::with('posts')->get();
foreach ($users as $user) {
    echo $user->posts->count(); // Nessuna query aggiuntiva
}
```

### Slow Queries

**Diagnosi**:
```php
// Log query lente (> 100ms)
DB::listen(function ($query) {
    if ($query->time > 100) {
        Log::warning('Slow query', [
            'sql' => $query->sql,
            'time' => $query->time,
            'bindings' => $query->bindings,
        ]);
    }
});
```

**Soluzioni**:
1. Aggiungi indici
2. Ottimizza WHERE clause
3. Limita SELECT columns
4. Usa pagination

### Missing Indexes

```sql
-- Trova query senza indice
EXPLAIN SELECT * FROM orders WHERE user_id = 1;

-- Aggiungi indice
ALTER TABLE orders ADD INDEX idx_user_id (user_id);
```

**In Migration**:
```php
$table->index('user_id');
$table->index(['status', 'created_at']); // Composite
```

## Ottimizzazioni Laravel

### Cache

```php
// Config cache (produzione)
php artisan config:cache

// Route cache
php artisan route:cache

// View cache
php artisan view:cache

// Query cache
$users = Cache::remember('users.all', 3600, function () {
    return User::all();
});
```

### Lazy Loading Prevention

```php
// In AppServiceProvider (sviluppo)
Model::preventLazyLoading(!app()->isProduction());
```

### Chunking per Dataset Grandi

```php
// ❌ Memory killer
$users = User::all(); // Carica tutto in memoria

// ✅ Chunking
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Process
    }
});

// ✅ Lazy collection
User::lazy()->each(function ($user) {
    // Process
});
```

### Select Solo Colonne Necessarie

```php
// ❌ Carica tutto
$users = User::all();

// ✅ Solo necessario
$users = User::select(['id', 'name', 'email'])->get();
```

## Profiling Memoria

```php
// Memory usage
$start = memory_get_usage();

// ... operazioni ...

$end = memory_get_usage();
$used = ($end - $start) / 1024 / 1024; // MB

Log::info("Memory used: {$used} MB");
```

## Benchmark

```php
$start = microtime(true);

// ... codice da misurare ...

$time = microtime(true) - $start;
Log::info("Execution time: {$time} seconds");
```

## Checklist Ottimizzazione

- [ ] N+1 queries risolti?
- [ ] Indici su colonne WHERE/JOIN?
- [ ] Cache abilitata in produzione?
- [ ] Query SELECT ottimizzate?
- [ ] Pagination su liste lunghe?
- [ ] Assets minificati?
- [ ] Immagini ottimizzate?
- [ ] CDN per asset statici?

## Comandi Utili

```bash
# Clear all caches
php artisan optimize:clear

# Optimize for production
php artisan optimize

# Analizza route
php artisan route:list --columns=method,uri,name
```
