---
name: scaffold
description: Genera CRUD completo per una nuova entità (Model, Migration, Controller, Views, Tests, Factory)
---

# /scaffold - Generatore CRUD Completo

Genera tutti i file necessari per una nuova entità in un solo comando.

## Uso

```bash
/scaffold Product                           # Base CRUD
/scaffold Product --fields="name,price,description"  # Con campi
/scaffold Product --api                     # Include API
/scaffold Product --filament               # Include Filament Resource
/scaffold Product --full                   # Tutto incluso
```

## Output Generato

```
/scaffold Product --full

Generating scaffold for Product...

✓ database/migrations/2024_01_15_create_products_table.php
✓ app/Models/Product.php
✓ app/Http/Controllers/ProductController.php
✓ app/Http/Controllers/Api/ProductController.php
✓ app/Http/Requests/ProductRequest.php
✓ app/Filament/Resources/ProductResource.php
✓ app/Filament/Resources/ProductResource/Pages/ListProducts.php
✓ app/Filament/Resources/ProductResource/Pages/CreateProduct.php
✓ app/Filament/Resources/ProductResource/Pages/EditProduct.php
✓ resources/views/products/index.blade.php
✓ resources/views/products/create.blade.php
✓ resources/views/products/edit.blade.php
✓ resources/views/products/show.blade.php
✓ database/factories/ProductFactory.php
✓ database/seeders/ProductSeeder.php
✓ tests/Unit/Models/ProductTest.php
✓ tests/Feature/Controllers/ProductControllerTest.php
✓ routes added to web.php and api.php

Done! 17 files generated.
```

## Workflow Interattivo

### Step 1: Definisci Campi

```
? Enter fields for Product (name:type, comma separated):
> name:string, price:decimal:10:2, description:text, category_id:foreignId, is_active:boolean
```

### Step 2: Opzioni

```
? What do you want to generate?
  [x] Migration
  [x] Model
  [x] Controller (Web)
  [ ] Controller (API)
  [x] Form Request
  [x] Views (Blade)
  [ ] Filament Resource
  [x] Factory
  [x] Seeder
  [x] Tests
```

### Step 3: Relazioni

```
? Does Product have relationships?
> belongsTo:Category, hasMany:Review, belongsToMany:Tag
```

## Template Files

### Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('{table}', function (Blueprint $table) {
            $table->id();
            // Generated fields
            {fields}
            $table->timestamps();
            $table->softDeletes(); // if --soft-deletes
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('{table}');
    }
};
```

### Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class {Model} extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        {fillable}
    ];

    protected $casts = [
        {casts}
    ];

    // Relationships
    {relationships}
}
```

### Controller

```php
<?php

namespace App\Http\Controllers;

use App\Models\{Model};
use App\Http\Requests\{Model}Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class {Model}Controller extends Controller
{
    public function index(): View
    {
        ${models} = {Model}::latest()->paginate(15);

        return view('{models}.index', compact('{models}'));
    }

    public function create(): View
    {
        return view('{models}.create');
    }

    public function store({Model}Request $request): RedirectResponse
    {
        {Model}::create($request->validated());

        return redirect()
            ->route('{models}.index')
            ->with('success', '{Model} created successfully.');
    }

    public function show({Model} ${model}): View
    {
        return view('{models}.show', compact('{model}'));
    }

    public function edit({Model} ${model}): View
    {
        return view('{models}.edit', compact('{model}'));
    }

    public function update({Model}Request $request, {Model} ${model}): RedirectResponse
    {
        ${model}->update($request->validated());

        return redirect()
            ->route('{models}.index')
            ->with('success', '{Model} updated successfully.');
    }

    public function destroy({Model} ${model}): RedirectResponse
    {
        ${model}->delete();

        return redirect()
            ->route('{models}.index')
            ->with('success', '{Model} deleted successfully.');
    }
}
```

### Form Request

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class {Model}Request extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            {rules}
        ];
    }

    public function messages(): array
    {
        return [
            {messages}
        ];
    }
}
```

### Blade Views

#### index.blade.php
```blade
@extends('layouts.app')

@section('content')
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>{Models}</h1>
        <a href="{{ route('{models}.create') }}" class="btn btn-primary">
            Create {Model}
        </a>
    </div>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <div class="card">
        <div class="card-body">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        {table_headers}
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse(${models} as ${model})
                        <tr>
                            <td>{{ ${model}->id }}</td>
                            {table_cells}
                            <td>
                                <a href="{{ route('{models}.show', ${model}) }}" class="btn btn-sm btn-info">View</a>
                                <a href="{{ route('{models}.edit', ${model}) }}" class="btn btn-sm btn-warning">Edit</a>
                                <form action="{{ route('{models}.destroy', ${model}) }}" method="POST" class="d-inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">Delete</button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="100%" class="text-center">No {models} found.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>

            {{ ${models}->links() }}
        </div>
    </div>
</div>
@endsection
```

### API Controller

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\{Model};
use App\Http\Requests\{Model}Request;
use App\Http\Resources\{Model}Resource;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class {Model}Controller extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return {Model}Resource::collection(
            {Model}::latest()->paginate(15)
        );
    }

    public function store({Model}Request $request): {Model}Resource
    {
        ${model} = {Model}::create($request->validated());

        return new {Model}Resource(${model});
    }

    public function show({Model} ${model}): {Model}Resource
    {
        return new {Model}Resource(${model});
    }

    public function update({Model}Request $request, {Model} ${model}): {Model}Resource
    {
        ${model}->update($request->validated());

        return new {Model}Resource(${model});
    }

    public function destroy({Model} ${model}): Response
    {
        ${model}->delete();

        return response()->noContent();
    }
}
```

### Routes

```php
// routes/web.php
Route::resource('{models}', {Model}Controller::class);

// routes/api.php
Route::apiResource('{models}', Api\{Model}Controller::class);
```

## Opzioni

| Flag | Descrizione |
|------|-------------|
| `--fields=` | Campi separati da virgola |
| `--api` | Include API controller e resource |
| `--filament` | Include Filament resource |
| `--soft-deletes` | Aggiunge soft deletes |
| `--policy` | Genera policy |
| `--full` | Tutto incluso |
| `--force` | Sovrascrivi file esistenti |

## Mapping Tipi Campo

| Input | Migration | Cast | Faker |
|-------|-----------|------|-------|
| `string` | `$table->string()` | - | `fake()->sentence()` |
| `text` | `$table->text()` | - | `fake()->paragraph()` |
| `integer` | `$table->integer()` | `'integer'` | `fake()->randomNumber()` |
| `decimal:10:2` | `$table->decimal(10, 2)` | `'decimal:2'` | `fake()->randomFloat(2)` |
| `boolean` | `$table->boolean()` | `'boolean'` | `fake()->boolean()` |
| `date` | `$table->date()` | `'date'` | `fake()->date()` |
| `datetime` | `$table->dateTime()` | `'datetime'` | `fake()->dateTime()` |
| `foreignId:users` | `$table->foreignId()->constrained()` | - | `User::factory()` |
| `enum:a,b,c` | `$table->enum([...])` | - | `fake()->randomElement()` |
| `json` | `$table->json()` | `'array'` | `['key' => 'value']` |

## Post-Scaffold

```bash
# Esegui migration
php artisan migrate

# Seed dati di test
php artisan db:seed --class={Model}Seeder

# Esegui test
php artisan test --filter={Model}
```
