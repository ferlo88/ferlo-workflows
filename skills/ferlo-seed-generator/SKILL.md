---
name: ferlo-seed-generator
description: Genera seeder e factory da dati esistenti nel database. Usa quando l'utente chiede "genera seeder", "crea factory", "esporta dati", "seed da database", "dati di test", o "popola database".
version: 1.0.0
---

# Seed Generator - Genera Seeder e Factory da Dati Esistenti

Analizza dati esistenti nel database e genera Seeder e Factory Laravel.

## Casi d'Uso

| Scenario | Output |
|----------|--------|
| Backup dati per test | Seeder con dati reali (sanitizzati) |
| Creare dati fittizi | Factory con regole Faker |
| Setup ambiente dev | Seeder + Factory combinati |
| Migrazione dati | Seeder da DB legacy |

## Workflow

### Step 1: Analizza Tabella

```bash
# Schema tabella
php artisan db:table {table_name}

# Conta record
php artisan tinker --execute="DB::table('{table}')->count()"

# Sample dati
php artisan tinker --execute="DB::table('{table}')->limit(5)->get()"
```

### Step 2: Genera Factory

Analizza tipi colonne e genera regole Faker appropriate:

```php
<?php

namespace Database\Factories;

use App\Models\{Model};
use Illuminate\Database\Eloquent\Factories\Factory;

class {Model}Factory extends Factory
{
    protected $model = {Model}::class;

    public function definition(): array
    {
        return [
            // Mapping automatico per tipo colonna
            // varchar/string
            'name' => fake()->name(),
            'title' => fake()->sentence(3),
            'description' => fake()->paragraph(),
            'slug' => fake()->slug(),

            // text
            'body' => fake()->paragraphs(3, true),
            'notes' => fake()->text(200),

            // numeri
            'quantity' => fake()->numberBetween(1, 100),
            'price' => fake()->randomFloat(2, 10, 1000),
            'percentage' => fake()->randomFloat(2, 0, 100),

            // boolean
            'is_active' => fake()->boolean(80), // 80% true
            'is_published' => fake()->boolean(),

            // date/time
            'date' => fake()->date(),
            'datetime' => fake()->dateTime(),
            'birth_date' => fake()->dateTimeBetween('-60 years', '-18 years'),
            'published_at' => fake()->dateTimeBetween('-1 year', 'now'),

            // contatti
            'email' => fake()->unique()->safeEmail(),
            'phone' => fake()->phoneNumber(),
            'website' => fake()->url(),

            // indirizzi
            'address' => fake()->streetAddress(),
            'city' => fake()->city(),
            'state' => fake()->state(),
            'zip' => fake()->postcode(),
            'country' => fake()->country(),

            // altri
            'uuid' => fake()->uuid(),
            'ip' => fake()->ipv4(),
            'color' => fake()->hexColor(),
            'file_path' => fake()->filePath(),

            // foreign keys
            'user_id' => User::factory(),
            'category_id' => Category::factory(),

            // enum (analizza valori esistenti)
            'status' => fake()->randomElement(['draft', 'pending', 'published']),
            'type' => fake()->randomElement(['A', 'B', 'C']),

            // json
            'metadata' => [
                'key1' => fake()->word(),
                'key2' => fake()->numberBetween(1, 10),
            ],
        ];
    }

    // States basati su dati reali
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
            'status' => 'published',
        ]);
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
            'status' => 'draft',
        ]);
    }

    public function withRelations(): static
    {
        return $this->has(RelatedModel::factory()->count(3));
    }
}
```

### Step 3: Genera Seeder

#### Seeder da Dati Esistenti

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class {Model}Seeder extends Seeder
{
    public function run(): void
    {
        // Dati estratti dal database (sanitizzati)
        $records = [
            [
                'id' => 1,
                'name' => 'Record 1',
                'email' => 'user1@example.com', // sanitizzato
                'created_at' => '2024-01-01 00:00:00',
                'updated_at' => '2024-01-01 00:00:00',
            ],
            [
                'id' => 2,
                'name' => 'Record 2',
                'email' => 'user2@example.com',
                'created_at' => '2024-01-02 00:00:00',
                'updated_at' => '2024-01-02 00:00:00',
            ],
            // ... altri record
        ];

        DB::table('{table}')->insert($records);
    }
}
```

#### Seeder con Factory

```php
<?php

namespace Database\Seeders;

use App\Models\{Model};
use Illuminate\Database\Seeder;

class {Model}Seeder extends Seeder
{
    public function run(): void
    {
        // Record specifici (master data)
        {Model}::create([
            'name' => 'Default Item',
            'is_system' => true,
        ]);

        // Record casuali per test
        {Model}::factory()
            ->count(50)
            ->create();

        // Con relazioni
        {Model}::factory()
            ->count(10)
            ->has(RelatedModel::factory()->count(5))
            ->create();

        // Con stati specifici
        {Model}::factory()
            ->count(5)
            ->active()
            ->create();

        {Model}::factory()
            ->count(3)
            ->inactive()
            ->create();
    }
}
```

### Step 4: Script Estrazione Dati

```php
<?php
// scripts/export-to-seeder.php

$table = $argv[1] ?? 'users';
$limit = $argv[2] ?? 100;

$records = DB::table($table)->limit($limit)->get();

$output = "<?php\n\n";
$output .= "// Seeder data for {$table}\n";
$output .= "\$records = [\n";

foreach ($records as $record) {
    $output .= "    [\n";
    foreach ((array) $record as $key => $value) {
        // Sanitizza dati sensibili
        if (in_array($key, ['password', 'remember_token', 'api_token'])) {
            continue;
        }
        if (in_array($key, ['email'])) {
            $value = sanitizeEmail($value);
        }

        $value = var_export($value, true);
        $output .= "        '{$key}' => {$value},\n";
    }
    $output .= "    ],\n";
}

$output .= "];\n";

file_put_contents("database/seeders/data/{$table}_data.php", $output);

function sanitizeEmail($email) {
    $parts = explode('@', $email);
    return substr($parts[0], 0, 2) . '***@example.com';
}
```

## Comandi

```bash
# Genera factory
php artisan make:factory {Model}Factory --model={Model}

# Genera seeder
php artisan make:seeder {Model}Seeder

# Esegui seeder specifico
php artisan db:seed --class={Model}Seeder

# Esegui tutti i seeder
php artisan db:seed

# Fresh + seed
php artisan migrate:fresh --seed
```

## Sanitizzazione Dati

### Campi da Sanitizzare

| Campo | Metodo |
|-------|--------|
| email | hash o fake |
| password | rimuovi |
| phone | maschera |
| address | generalizza |
| credit_card | rimuovi |
| ssn | rimuovi |
| api_token | rimuovi |

### Script Sanitizzazione

```php
function sanitize(array $record): array
{
    // Email: mantieni dominio ma cambia local part
    if (isset($record['email'])) {
        $record['email'] = fake()->safeEmail();
    }

    // Rimuovi campi sensibili
    unset($record['password']);
    unset($record['remember_token']);
    unset($record['api_token']);

    // Maschera telefono
    if (isset($record['phone'])) {
        $record['phone'] = preg_replace('/\d/', '*', $record['phone']);
        $record['phone'] = substr_replace($record['phone'], '1234', -4);
    }

    return $record;
}
```

## DatabaseSeeder Completo

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Ordine importante per FK
        $this->call([
            // 1. Tabelle senza dipendenze
            RoleSeeder::class,
            PermissionSeeder::class,
            CategorySeeder::class,

            // 2. Users (dipende da roles)
            UserSeeder::class,

            // 3. Contenuti (dipende da users, categories)
            ProductSeeder::class,
            OrderSeeder::class,

            // 4. Relazioni M:N
            RolePermissionSeeder::class,
            UserRoleSeeder::class,
        ]);
    }
}
```

## Tips

1. **Ordine FK**: Seed prima le tabelle padre
2. **Truncate**: Usa `DB::table()->truncate()` prima di seed in dev
3. **ID fissi**: Per master data, usa ID fissi per riferimenti
4. **Faker locale**: `fake('it_IT')->name()` per dati italiani
5. **Performance**: Usa `insert()` batch invece di `create()` singoli per grandi volumi
