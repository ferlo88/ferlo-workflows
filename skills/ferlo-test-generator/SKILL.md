---
name: ferlo-test-generator
description: Genera test automatici da codice esistente. Usa quando l'utente chiede di "generare test", "creare test", "scrivere test", "test coverage", "unit test", "feature test", o "testare" una classe/controller/model.
version: 1.0.0
---

# Test Generator - Genera Test da Codice Esistente

Analizza classi, controller, modelli e genera automaticamente test PHPUnit/Pest.

## Tipi di Test Supportati

| Tipo | Quando Usare | Location |
|------|--------------|----------|
| **Unit** | Modelli, Services, Actions, Helpers | `tests/Unit/` |
| **Feature** | Controllers, API, Middleware | `tests/Feature/` |
| **Browser** | UI, Form, JavaScript interactions | `tests/Browser/` |

## Workflow

### Step 1: Identifica Target

```bash
# Chiedi all'utente cosa testare
# - Classe specifica: App\Models\Quote
# - Controller: QuoteController
# - Directory: app/Services/
# - Tutto il progetto (coverage generale)
```

### Step 2: Analizza Codice

Per ogni classe, estrai:
- Metodi pubblici
- Dipendenze (constructor injection)
- Relazioni (se Model)
- Validazioni (se FormRequest)
- Routes (se Controller)

### Step 3: Genera Test

## Template Test per Model

```php
<?php

namespace Tests\Unit\Models;

use App\Models\{Model};
use App\Models\{RelatedModel};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class {Model}Test extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_be_created_with_valid_data(): void
    {
        $data = {Model}::factory()->make()->toArray();

        ${model} = {Model}::create($data);

        $this->assertDatabaseHas('{table}', [
            'id' => ${model}->id,
        ]);
    }

    /** @test */
    public function it_requires_mandatory_fields(): void
    {
        $this->expectException(\Illuminate\Database\QueryException::class);

        {Model}::create([]);
    }

    // Relazioni
    /** @test */
    public function it_belongs_to_{relation}(): void
    {
        ${model} = {Model}::factory()
            ->for({RelatedModel}::factory())
            ->create();

        $this->assertInstanceOf({RelatedModel}::class, ${model}->{relation});
    }

    /** @test */
    public function it_has_many_{relations}(): void
    {
        ${model} = {Model}::factory()
            ->has({RelatedModel}::factory()->count(3))
            ->create();

        $this->assertCount(3, ${model}->{relations});
    }

    // Scopes
    /** @test */
    public function it_can_filter_by_{scope}(): void
    {
        {Model}::factory()->count(3)->{state}()->create();
        {Model}::factory()->count(2)->create();

        $filtered = {Model}::{scope}()->get();

        $this->assertCount(3, $filtered);
    }

    // Accessors
    /** @test */
    public function it_formats_{attribute}_correctly(): void
    {
        ${model} = {Model}::factory()->create([
            '{field}' => {value},
        ]);

        $this->assertEquals({expected}, ${model}->{attribute});
    }
}
```

## Template Test per Controller

```php
<?php

namespace Tests\Feature\Controllers;

use App\Models\User;
use App\Models\{Model};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class {Model}ControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    /** @test */
    public function guest_cannot_access_{model}_index(): void
    {
        $response = $this->get(route('{model}.index'));

        $response->assertRedirect(route('login'));
    }

    /** @test */
    public function user_can_view_{model}_index(): void
    {
        {Model}::factory()->count(3)->create();

        $response = $this->actingAs($this->user)
            ->get(route('{model}.index'));

        $response->assertOk()
            ->assertViewIs('{model}.index')
            ->assertViewHas('{models}');
    }

    /** @test */
    public function user_can_view_create_{model}_form(): void
    {
        $response = $this->actingAs($this->user)
            ->get(route('{model}.create'));

        $response->assertOk()
            ->assertViewIs('{model}.create');
    }

    /** @test */
    public function user_can_create_{model}_with_valid_data(): void
    {
        $data = {Model}::factory()->make()->toArray();

        $response = $this->actingAs($this->user)
            ->post(route('{model}.store'), $data);

        $response->assertRedirect(route('{model}.index'));
        $this->assertDatabaseHas('{table}', [
            '{field}' => $data['{field}'],
        ]);
    }

    /** @test */
    public function user_cannot_create_{model}_with_invalid_data(): void
    {
        $response = $this->actingAs($this->user)
            ->post(route('{model}.store'), []);

        $response->assertSessionHasErrors(['{required_field}']);
    }

    /** @test */
    public function user_can_view_{model}_detail(): void
    {
        ${model} = {Model}::factory()->create();

        $response = $this->actingAs($this->user)
            ->get(route('{model}.show', ${model}));

        $response->assertOk()
            ->assertViewIs('{model}.show')
            ->assertViewHas('{model}');
    }

    /** @test */
    public function user_can_update_{model}(): void
    {
        ${model} = {Model}::factory()->create();
        $newData = ['{field}' => 'Updated Value'];

        $response = $this->actingAs($this->user)
            ->put(route('{model}.update', ${model}), $newData);

        $response->assertRedirect();
        $this->assertDatabaseHas('{table}', $newData);
    }

    /** @test */
    public function user_can_delete_{model}(): void
    {
        ${model} = {Model}::factory()->create();

        $response = $this->actingAs($this->user)
            ->delete(route('{model}.destroy', ${model}));

        $response->assertRedirect();
        $this->assertDatabaseMissing('{table}', ['id' => ${model}->id]);
    }
}
```

## Template Test per API

```php
<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\{Model};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class {Model}ApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Sanctum::actingAs(User::factory()->create());
    }

    /** @test */
    public function it_returns_{models}_list(): void
    {
        {Model}::factory()->count(3)->create();

        $response = $this->getJson('/api/{models}');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', '{field1}', '{field2}']
                ]
            ]);
    }

    /** @test */
    public function it_creates_{model}(): void
    {
        $data = {Model}::factory()->make()->toArray();

        $response = $this->postJson('/api/{models}', $data);

        $response->assertCreated()
            ->assertJsonPath('data.{field}', $data['{field}']);
    }

    /** @test */
    public function it_validates_required_fields(): void
    {
        $response = $this->postJson('/api/{models}', []);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['{required_field}']);
    }

    /** @test */
    public function it_shows_{model}(): void
    {
        ${model} = {Model}::factory()->create();

        $response = $this->getJson("/api/{models}/{${model}->id}");

        $response->assertOk()
            ->assertJsonPath('data.id', ${model}->id);
    }

    /** @test */
    public function it_updates_{model}(): void
    {
        ${model} = {Model}::factory()->create();

        $response = $this->putJson("/api/{models}/{${model}->id}", [
            '{field}' => 'Updated'
        ]);

        $response->assertOk();
        $this->assertDatabaseHas('{table}', ['{field}' => 'Updated']);
    }

    /** @test */
    public function it_deletes_{model}(): void
    {
        ${model} = {Model}::factory()->create();

        $response = $this->deleteJson("/api/{models}/{${model}->id}");

        $response->assertNoContent();
        $this->assertDatabaseMissing('{table}', ['id' => ${model}->id]);
    }
}
```

## Template Test Pest (alternativo)

```php
<?php

use App\Models\{Model};
use App\Models\User;

beforeEach(function () {
    $this->user = User::factory()->create();
});

describe('{Model}', function () {

    it('can be created', function () {
        ${model} = {Model}::factory()->create();

        expect(${model})->toBeInstanceOf({Model}::class)
            ->and(${model}->id)->toBeInt();
    });

    it('belongs to {relation}', function () {
        ${model} = {Model}::factory()->create();

        expect(${model}->{relation})->toBeInstanceOf({RelatedModel}::class);
    });

});

describe('{Model} Controller', function () {

    it('requires authentication', function () {
        $this->get(route('{model}.index'))
            ->assertRedirect(route('login'));
    });

    it('lists all {models}', function () {
        {Model}::factory()->count(3)->create();

        $this->actingAs($this->user)
            ->get(route('{model}.index'))
            ->assertOk()
            ->assertViewHas('{models}');
    });

    it('creates {model} with valid data', function () {
        $data = {Model}::factory()->make()->toArray();

        $this->actingAs($this->user)
            ->post(route('{model}.store'), $data)
            ->assertRedirect();

        $this->assertDatabaseHas('{table}', ['{field}' => $data['{field}']]);
    });

});
```

## Genera Factory se Mancante

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
            // Genera in base ai tipi campo
            '{string_field}' => fake()->sentence(),
            '{text_field}' => fake()->paragraph(),
            '{integer_field}' => fake()->randomNumber(),
            '{decimal_field}' => fake()->randomFloat(2, 0, 1000),
            '{boolean_field}' => fake()->boolean(),
            '{date_field}' => fake()->date(),
            '{datetime_field}' => fake()->dateTime(),
            '{email_field}' => fake()->unique()->safeEmail(),
            '{phone_field}' => fake()->phoneNumber(),
            '{url_field}' => fake()->url(),
            '{foreign_id}' => {RelatedModel}::factory(),
        ];
    }

    // States
    public function {state}(): static
    {
        return $this->state(fn (array $attributes) => [
            '{field}' => {value},
        ]);
    }
}
```

## Comandi Utili

```bash
# Esegui test specifici
php artisan test --filter={Model}Test

# Coverage
php artisan test --coverage --min=80

# Pest
./vendor/bin/pest --filter={Model}

# Genera factory mancante
php artisan make:factory {Model}Factory --model={Model}
```

## Checklist Test Generati

- [ ] Test creazione con dati validi
- [ ] Test validazione campi obbligatori
- [ ] Test relazioni (belongsTo, hasMany, etc.)
- [ ] Test scopes
- [ ] Test accessors/mutators
- [ ] Test autorizzazione (guest vs user vs admin)
- [ ] Test CRUD completo
- [ ] Test edge cases
- [ ] Factory creata/aggiornata
