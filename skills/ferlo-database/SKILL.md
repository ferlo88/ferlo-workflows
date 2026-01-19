---
name: ferlo-database
description: This skill handles database design, migrations, seeders, and relationships for Laravel projects. Use when user asks for "create migration", "database schema", "add column", "create seeder", "database relationship", "foreign key", or "eloquent relationship".
version: 1.0.0
---

# Database Development Workflow

Gestisce schema database, migrations, seeders e relazioni.

## Migration Best Practices

### Creazione Migration
```bash
php artisan make:migration create_products_table
php artisan make:migration add_status_to_orders_table
php artisan make:migration create_user_role_pivot_table
```

### Schema Standard
```php
Schema::create('products', function (Blueprint $table) {
    $table->id();
    $table->uuid('uuid')->unique();

    // Foreign keys
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();

    // Campi principali
    $table->string('name');
    $table->string('slug')->unique();
    $table->text('description')->nullable();
    $table->decimal('price', 10, 2)->default(0);
    $table->integer('quantity')->default(0);

    // Stati e flags
    $table->enum('status', ['draft', 'published', 'archived'])->default('draft');
    $table->boolean('is_featured')->default(false);

    // Date
    $table->timestamp('published_at')->nullable();
    $table->timestamps();
    $table->softDeletes();

    // Indici
    $table->index(['status', 'is_featured']);
    $table->fullText(['name', 'description']);
});
```

### Modifica Tabelle Esistenti
```php
Schema::table('products', function (Blueprint $table) {
    $table->string('sku')->nullable()->after('name');
    $table->index('sku');
});
```

### Rollback Sicuro
```php
public function down(): void
{
    Schema::table('products', function (Blueprint $table) {
        $table->dropIndex(['sku']);
        $table->dropColumn('sku');
    });
}
```

## Relazioni Eloquent

### One-to-Many
```php
// User.php
public function posts(): HasMany
{
    return $this->hasMany(Post::class);
}

// Post.php
public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}
```

### Many-to-Many
```php
// Migration pivot
Schema::create('role_user', function (Blueprint $table) {
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('role_id')->constrained()->cascadeOnDelete();
    $table->primary(['user_id', 'role_id']);
    $table->timestamps();
});

// User.php
public function roles(): BelongsToMany
{
    return $this->belongsToMany(Role::class)->withTimestamps();
}
```

### Polymorphic
```php
// Migration
Schema::create('comments', function (Blueprint $table) {
    $table->id();
    $table->morphs('commentable'); // commentable_id, commentable_type
    $table->text('body');
    $table->timestamps();
});

// Comment.php
public function commentable(): MorphTo
{
    return $this->morphTo();
}

// Post.php / Video.php
public function comments(): MorphMany
{
    return $this->morphMany(Comment::class, 'commentable');
}
```

## Seeders

### Factory-based Seeder
```php
// database/seeders/ProductSeeder.php
public function run(): void
{
    Product::factory()
        ->count(50)
        ->has(Review::factory()->count(3))
        ->create();
}

// DatabaseSeeder.php
public function run(): void
{
    $this->call([
        UserSeeder::class,
        CategorySeeder::class,
        ProductSeeder::class,
    ]);
}
```

### Seeder con Dati Fissi
```php
public function run(): void
{
    $statuses = [
        ['name' => 'Pending', 'slug' => 'pending', 'color' => 'yellow'],
        ['name' => 'Approved', 'slug' => 'approved', 'color' => 'green'],
        ['name' => 'Rejected', 'slug' => 'rejected', 'color' => 'red'],
    ];

    foreach ($statuses as $status) {
        Status::updateOrCreate(
            ['slug' => $status['slug']],
            $status
        );
    }
}
```

## Factories

```php
// database/factories/ProductFactory.php
public function definition(): array
{
    return [
        'user_id' => User::factory(),
        'name' => fake()->sentence(3),
        'slug' => fake()->unique()->slug(),
        'description' => fake()->paragraphs(3, true),
        'price' => fake()->randomFloat(2, 10, 1000),
        'quantity' => fake()->numberBetween(0, 100),
        'status' => fake()->randomElement(['draft', 'published']),
        'is_featured' => fake()->boolean(20),
    ];
}

// Stati personalizzati
public function published(): static
{
    return $this->state(fn (array $attributes) => [
        'status' => 'published',
        'published_at' => now(),
    ]);
}

public function featured(): static
{
    return $this->state(fn (array $attributes) => [
        'is_featured' => true,
    ]);
}
```

## Query Optimization

### Eager Loading
```php
// Evita N+1
$posts = Post::with(['user', 'comments.user'])->get();

// Conditional loading
$posts = Post::when($includeComments, fn ($q) => $q->with('comments'))->get();
```

### Chunking per grandi dataset
```php
Product::chunk(100, function ($products) {
    foreach ($products as $product) {
        // Process
    }
});
```
