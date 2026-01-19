---
name: ferlo-queue-monitor
description: Monitora e analizza code Laravel e job. Usa quando l'utente chiede "queue", "job falliti", "monitor code", "failed jobs", "queue status", "horizon", o "worker".
version: 1.0.0
---

# Queue Monitor - Analisi Code e Job Laravel

Monitora, analizza e risolve problemi con le code Laravel.

## Quick Status

```bash
# Status code
php artisan queue:work --once --quiet && echo "Queue OK" || echo "Queue ERROR"

# Job in coda (database driver)
php artisan tinker --execute="DB::table('jobs')->count()"

# Job falliti
php artisan queue:failed

# Retry tutti i falliti
php artisan queue:retry all
```

## Dashboard Status

```bash
# Overview completo
echo "=== Queue Status ==="
echo "Pending jobs: $(php artisan tinker --execute="DB::table('jobs')->count()" 2>/dev/null)"
echo "Failed jobs: $(php artisan tinker --execute="DB::table('failed_jobs')->count()" 2>/dev/null)"
echo "Workers: $(pgrep -c -f 'queue:work' 2>/dev/null || echo 0)"
```

## Analisi Job Falliti

### Lista Dettagliata

```bash
# Ultimi 10 job falliti
php artisan queue:failed --limit=10
```

```php
// Analisi in Tinker
$failed = DB::table('failed_jobs')
    ->latest()
    ->limit(10)
    ->get();

foreach ($failed as $job) {
    $payload = json_decode($job->payload);
    echo "Job: " . $payload->displayName . "\n";
    echo "Queue: " . $job->queue . "\n";
    echo "Failed at: " . $job->failed_at . "\n";
    echo "Exception: " . Str::limit($job->exception, 200) . "\n\n";
}
```

### Pattern Errori Comuni

```php
// Raggruppa per tipo errore
$errors = DB::table('failed_jobs')
    ->selectRaw("SUBSTRING_INDEX(exception, ':', 1) as error_type, COUNT(*) as count")
    ->groupBy('error_type')
    ->orderByDesc('count')
    ->get();
```

## Configurazione Ottimale

### config/queue.php

```php
'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => env('REDIS_QUEUE', 'default'),
        'retry_after' => 90,        // Secondi prima di retry
        'block_for' => 5,           // Blocking pop timeout
        'after_commit' => true,     // Dispatch dopo DB commit
    ],

    'database' => [
        'driver' => 'database',
        'table' => 'jobs',
        'queue' => 'default',
        'retry_after' => 90,
        'after_commit' => true,
    ],
],

'failed' => [
    'driver' => 'database-uuids',
    'database' => 'mysql',
    'table' => 'failed_jobs',
],
```

### Supervisor Configuration

```ini
; /etc/supervisor/conf.d/laravel-worker.conf

[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/html/storage/logs/worker.log
stopwaitsecs=3600
```

### Systemd Alternative

```ini
; /etc/systemd/system/laravel-queue.service

[Unit]
Description=Laravel Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
RestartSec=5
WorkingDirectory=/var/www/html
ExecStart=/usr/bin/php artisan queue:work --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
```

## Job Best Practices

### Job con Retry e Backoff

```php
<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\Middleware\WithoutOverlapping;
use Illuminate\Queue\Middleware\RateLimited;

class ProcessOrder implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    // Numero massimo tentativi
    public $tries = 5;

    // Timeout in secondi
    public $timeout = 120;

    // Backoff esponenziale (secondi)
    public $backoff = [10, 30, 60, 120, 300];

    // Numero massimo eccezioni prima di fallire
    public $maxExceptions = 3;

    // Elimina job se modello non esiste più
    public $deleteWhenMissingModels = true;

    public function __construct(
        public Order $order
    ) {}

    // Middleware per evitare overlap e rate limiting
    public function middleware(): array
    {
        return [
            new WithoutOverlapping($this->order->id),
            new RateLimited('orders'),
        ];
    }

    public function handle(): void
    {
        // Process order
    }

    public function failed(\Throwable $exception): void
    {
        // Notifica admin
        Log::error('Order processing failed', [
            'order_id' => $this->order->id,
            'error' => $exception->getMessage(),
        ]);

        // Notifica utente
        $this->order->user->notify(new OrderProcessingFailed($this->order));
    }

    // Determina se il job deve essere ritentato
    public function retryUntil(): \DateTime
    {
        return now()->addHours(24);
    }
}
```

### Rate Limiter per Job

```php
// AppServiceProvider
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;

public function boot(): void
{
    RateLimiter::for('orders', function (object $job) {
        return Limit::perMinute(100);
    });

    RateLimiter::for('emails', function (object $job) {
        return Limit::perMinute(50)->by($job->user->id);
    });
}
```

## Monitoring

### Custom Artisan Command

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class QueueStatus extends Command
{
    protected $signature = 'queue:status';
    protected $description = 'Show queue status';

    public function handle(): void
    {
        // Pending jobs
        $pending = DB::table('jobs')->count();

        // Failed jobs
        $failed = DB::table('failed_jobs')->count();

        // Jobs by queue
        $byQueue = DB::table('jobs')
            ->selectRaw('queue, COUNT(*) as count')
            ->groupBy('queue')
            ->pluck('count', 'queue');

        // Recent failures
        $recentFailures = DB::table('failed_jobs')
            ->where('failed_at', '>=', now()->subHour())
            ->count();

        $this->table(
            ['Metric', 'Value'],
            [
                ['Pending Jobs', $pending],
                ['Failed Jobs', $failed],
                ['Failures (last hour)', $recentFailures],
            ]
        );

        if ($byQueue->isNotEmpty()) {
            $this->newLine();
            $this->info('Jobs by Queue:');
            $this->table(
                ['Queue', 'Count'],
                $byQueue->map(fn ($count, $queue) => [$queue, $count])->values()
            );
        }

        // Warning se troppi fallimenti
        if ($recentFailures > 10) {
            $this->error("⚠️  High failure rate in last hour!");
        }
    }
}
```

### Health Check Endpoint

```php
// routes/web.php
Route::get('/health/queue', function () {
    $pending = DB::table('jobs')->count();
    $failed = DB::table('failed_jobs')
        ->where('failed_at', '>=', now()->subHour())
        ->count();

    $healthy = $pending < 1000 && $failed < 10;

    return response()->json([
        'status' => $healthy ? 'healthy' : 'unhealthy',
        'pending_jobs' => $pending,
        'recent_failures' => $failed,
    ], $healthy ? 200 : 503);
});
```

## Horizon (Redis)

```bash
# Installa
composer require laravel/horizon

# Pubblica
php artisan horizon:install

# Avvia
php artisan horizon

# Status
php artisan horizon:status

# Pausa
php artisan horizon:pause

# Termina gracefully
php artisan horizon:terminate
```

### Horizon Metrics

```php
use Laravel\Horizon\Contracts\MetricsRepository;

$metrics = app(MetricsRepository::class);

// Jobs processati
$throughput = $metrics->throughput();

// Tempo medio
$runtime = $metrics->runtimeForQueue('default');

// Job in attesa
$pending = $metrics->queueSize('default');
```

## Troubleshooting

### Job bloccati

```bash
# Trova job vecchi (>1 ora)
php artisan tinker --execute="
    DB::table('jobs')
        ->where('created_at', '<', now()->subHour())
        ->get()
"

# Pulisci job bloccati
php artisan queue:flush
```

### Memory leak

```bash
# Riavvia worker ogni N job
php artisan queue:work --max-jobs=1000

# Riavvia ogni N secondi
php artisan queue:work --max-time=3600
```

### Retry job specifico

```bash
# Per UUID
php artisan queue:retry 5a8a5a50-4a59-4a8e-a78e-a8f5a8a5a8a5

# Tutti i falliti di un tipo
php artisan tinker --execute="
    DB::table('failed_jobs')
        ->where('payload', 'like', '%ProcessOrder%')
        ->pluck('uuid')
        ->each(fn(\$uuid) => Artisan::call('queue:retry', ['id' => \$uuid]))
"
```

## Checklist Produzione

- [ ] Redis invece di database per performance
- [ ] Supervisor/systemd configurato
- [ ] Retry policy appropriata
- [ ] Failed jobs notification
- [ ] Health check endpoint
- [ ] Log rotation per worker logs
- [ ] Monitoring/alerting attivo
- [ ] Horizon dashboard (se Redis)
