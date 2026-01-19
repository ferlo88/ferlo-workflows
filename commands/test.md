---
name: test
description: Genera test per una classe, controller o feature specifica
---

# /test - Genera Test

Genera test automatici seguendo le convenzioni Laravel/Pest.

## Uso

```
/test                     # Test per file modificati
/test UserController      # Test per controller specifico
/test App\Models\User     # Test per model specifico
/test feature login       # Feature test per login
```

## Comportamento

1. **Analizza il target**:
   - Leggi il codice della classe/controller/model
   - Identifica i metodi pubblici da testare
   - Comprendi le dipendenze e relazioni

2. **Genera test appropriati**:

### Per Controller
```php
it('can list resources', function () {
    $user = User::factory()->create();

    $this->actingAs($user)
        ->get(route('resources.index'))
        ->assertOk();
});

it('can create resource', function () {
    $user = User::factory()->create();

    $this->actingAs($user)
        ->post(route('resources.store'), [
            'name' => 'Test',
        ])
        ->assertRedirect();

    $this->assertDatabaseHas('resources', ['name' => 'Test']);
});
```

### Per Model
```php
it('has correct fillable attributes', function () {
    $model = new Resource();
    expect($model->getFillable())->toContain('name');
});

it('belongs to user', function () {
    $resource = Resource::factory()->create();
    expect($resource->user)->toBeInstanceOf(User::class);
});
```

### Per Service
```php
it('processes data correctly', function () {
    $service = new MyService();
    $result = $service->process(['input' => 'data']);
    expect($result)->toBeArray();
});
```

3. **Posiziona i test**:
   - Feature tests: `tests/Feature/`
   - Unit tests: `tests/Unit/`
   - Usa Pest syntax (preferito) o PHPUnit

4. **Esegui verifica**:
   ```bash
   php artisan test --filter=NomeTest
   ```
