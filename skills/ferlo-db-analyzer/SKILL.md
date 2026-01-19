---
name: ferlo-db-analyzer
description: Analizza database per performance, indici mancanti e ottimizzazioni. Usa quando l'utente chiede "analizza database", "indici mancanti", "ottimizza query", "slow query", "database performance", o "EXPLAIN".
version: 1.0.0
---

# DB Analyzer - Analisi Performance Database

Analizza il database MySQL/PostgreSQL per identificare problemi di performance, indici mancanti e ottimizzazioni.

## Aree di Analisi

| Area | Cosa Analizza |
|------|---------------|
| **Schema** | Struttura tabelle, tipi dati, normalizzazione |
| **Indici** | Indici mancanti, ridondanti, non utilizzati |
| **Query** | Query lente, N+1, full table scan |
| **Relazioni** | FK mancanti, integrità referenziale |
| **Storage** | Dimensioni tabelle, frammentazione |

## Comandi Diagnostici

### MySQL

```sql
-- Dimensioni tabelle
SELECT
    table_name,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY data_length DESC;

-- Indici per tabella
SHOW INDEX FROM {table_name};

-- Query lente (se slow query log abilitato)
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 20;

-- Stato connessioni
SHOW PROCESSLIST;

-- Variabili performance
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'max_connections';
```

### PostgreSQL

```sql
-- Dimensioni tabelle
SELECT
    relname as table_name,
    pg_size_pretty(pg_total_relation_size(relid)) as total_size,
    pg_size_pretty(pg_relation_size(relid)) as data_size,
    pg_size_pretty(pg_indexes_size(relid)) as index_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Indici non utilizzati
SELECT
    schemaname || '.' || relname as table,
    indexrelname as index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) as size,
    idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE idx_scan = 0
    AND NOT indisunique
    AND NOT indisprimary;

-- Query lente attive
SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query
FROM pg_stat_activity
WHERE state = 'active'
    AND now() - pg_stat_activity.query_start > interval '5 seconds';
```

## Analisi Indici

### Trova Indici Mancanti

```php
// In Laravel - Log query lente
DB::listen(function ($query) {
    if ($query->time > 100) { // > 100ms
        Log::channel('slow-queries')->info('Slow Query', [
            'sql' => $query->sql,
            'time' => $query->time,
            'bindings' => $query->bindings,
        ]);
    }
});
```

### Pattern che Richiedono Indici

```sql
-- WHERE su colonne non indicizzate
EXPLAIN SELECT * FROM orders WHERE status = 'pending';
-- Se "type: ALL" = full table scan = serve indice

-- JOIN su colonne senza indice
EXPLAIN SELECT * FROM orders o
JOIN users u ON o.user_id = u.id;
-- user_id dovrebbe avere indice

-- ORDER BY su colonne non indicizzate
EXPLAIN SELECT * FROM products ORDER BY created_at DESC;
-- Se "Using filesort" = serve indice

-- GROUP BY
EXPLAIN SELECT category_id, COUNT(*) FROM products GROUP BY category_id;
-- category_id dovrebbe avere indice
```

### Crea Indici Mancanti

```php
// Migration per aggiungere indici
Schema::table('orders', function (Blueprint $table) {
    // Indice singolo
    $table->index('status');

    // Indice composto (ordine colonne importante!)
    $table->index(['user_id', 'status']);

    // Indice per ORDER BY
    $table->index('created_at');

    // Indice parziale (MySQL 8.0+ / PostgreSQL)
    // CREATE INDEX idx_pending ON orders(status) WHERE status = 'pending';
});
```

## Analisi Query

### EXPLAIN Guida

```sql
EXPLAIN SELECT * FROM orders WHERE user_id = 1;
```

| Valore type | Significato | Azione |
|-------------|-------------|--------|
| `ALL` | Full table scan | AGGIUNGI INDICE! |
| `index` | Full index scan | Ottimizza query |
| `range` | Range di indice | OK |
| `ref` | Non-unique index | Buono |
| `eq_ref` | Unique index | Ottimo |
| `const` | Una riga | Perfetto |

### Ottimizzazione Query Comuni

```php
// ❌ N+1 Query
$orders = Order::all();
foreach ($orders as $order) {
    echo $order->user->name; // Query per ogni order!
}

// ✅ Eager Loading
$orders = Order::with('user')->get();

// ❌ SELECT *
$users = User::all();

// ✅ Solo colonne necessarie
$users = User::select(['id', 'name', 'email'])->get();

// ❌ WHERE su colonna calcolata
User::whereRaw('YEAR(created_at) = 2024')->get();

// ✅ WHERE su range
User::whereBetween('created_at', ['2024-01-01', '2024-12-31'])->get();

// ❌ LIKE con wildcard iniziale
User::where('name', 'LIKE', '%john%')->get();

// ✅ LIKE solo finale (può usare indice)
User::where('name', 'LIKE', 'john%')->get();
```

## Report Database

### Template

```markdown
# Database Analysis Report

**Database**: {DB_NAME}
**Engine**: MySQL 8.0 / PostgreSQL 15
**Size**: {SIZE} MB
**Tables**: {N}

## Overview

| Metric | Value | Status |
|--------|-------|--------|
| Total Size | {X} MB | ✅/⚠️/❌ |
| Largest Table | {table} ({X} MB) | |
| Total Rows | {N} | |
| Avg Query Time | {X} ms | |

## Tables Analysis

### {table_name}
- **Rows**: {N}
- **Size**: {X} MB (data) + {Y} MB (indexes)
- **Indexes**: {list}
- **Missing Indexes**:
  - `{column}` - used in WHERE {N} times
- **Issues**:
  - ⚠️ No primary key
  - ⚠️ TEXT column without separate table
  - ❌ No foreign key constraint

## Index Recommendations

### High Priority

1. **Add index on `orders.status`**
   ```sql
   ALTER TABLE orders ADD INDEX idx_status (status);
   ```
   - **Impact**: ~{X}% query improvement
   - **Queries affected**: {N}

### Medium Priority

2. **Composite index on `orders`**
   ```sql
   ALTER TABLE orders ADD INDEX idx_user_status (user_id, status);
   ```

### Low Priority (Consider removing)

3. **Unused index `idx_old_column`**
   ```sql
   DROP INDEX idx_old_column ON orders;
   ```
   - Last used: Never
   - Size: {X} MB

## Slow Queries

### Query #1
```sql
{query}
```
- **Time**: {X} ms
- **Frequency**: {N}/hour
- **Issue**: Full table scan
- **Fix**: Add index on `{column}`

## Schema Issues

1. **Missing Foreign Keys**
   - `orders.user_id` → `users.id`
   - `order_items.product_id` → `products.id`

2. **Data Type Optimization**
   - `users.status` VARCHAR(255) → ENUM('active','inactive')
   - `logs.id` INT → BIGINT (approaching limit)

3. **Normalization**
   - `orders.customer_address` should be separate table

## Recommendations

1. **Immediate**
   - Add missing indexes (estimated {X}% improvement)

2. **Short-term**
   - Add foreign key constraints
   - Enable slow query log

3. **Long-term**
   - Consider partitioning for `logs` table
   - Archive old data from `orders` (>2 years)
```

## Comandi Laravel

```bash
# Info database
php artisan db:show

# Info tabella
php artisan db:table users

# Monitor query (con Telescope)
php artisan telescope:install

# Debugbar (sviluppo)
composer require barryvdh/laravel-debugbar --dev
```

## Script Analisi Automatica

```php
// app/Console/Commands/AnalyzeDatabase.php

public function handle()
{
    $tables = DB::select('SHOW TABLES');

    foreach ($tables as $table) {
        $tableName = array_values((array) $table)[0];

        // Dimensione
        $size = DB::select("
            SELECT
                ROUND((data_length + index_length) / 1024 / 1024, 2) AS size_mb
            FROM information_schema.tables
            WHERE table_name = ?
        ", [$tableName]);

        // Indici
        $indexes = DB::select("SHOW INDEX FROM {$tableName}");

        // Analizza
        $this->info("Table: {$tableName}");
        $this->info("  Size: {$size[0]->size_mb} MB");
        $this->info("  Indexes: " . count($indexes));
    }
}
```

## Checklist Ottimizzazione

- [ ] Ogni FK ha un indice
- [ ] Colonne in WHERE frequenti hanno indici
- [ ] Indici composti nell'ordine corretto
- [ ] Nessun indice duplicato/ridondante
- [ ] Nessun indice mai utilizzato
- [ ] Query N+1 eliminate
- [ ] SELECT * sostituiti con colonne specifiche
- [ ] Paginazione su liste lunghe
- [ ] Slow query log abilitato
