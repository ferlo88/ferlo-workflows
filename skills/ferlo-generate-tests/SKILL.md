---
name: ferlo-generate-tests
description: This skill generates tests for Laravel projects using Pest or PHPUnit. Use when user asks to "generate tests", "write tests", "create test cases", "add unit tests", "add feature tests", or "test coverage".
version: 1.0.0
---

# Test Generation Workflow

Genera test completi per progetti Laravel usando Pest/PHPUnit.

## Strategia di Test

### 1. Analisi del Codice
Prima di generare test, analizza:
- Tipo di classe (Controller, Model, Service, Action)
- Metodi pubblici da testare
- Dipendenze da mockare
- Edge cases da coprire

### 2. Tipi di Test

**Unit Tests** - Per classi isolate:
```php
test('calculates total correctly', function () {
    $service = new PriceCalculator();
    expect($service->calculate(100, 0.22))->toBe(122.0);
});
```

**Feature Tests** - Per endpoint API/web:
```php
test('user can create order', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/orders', ['product_id' => 1]);

    $response->assertStatus(201);
    $this->assertDatabaseHas('orders', ['user_id' => $user->id]);
});
```

### 3. Pattern EXTRAWEB

```php
// Struttura test consigliata
describe('OrderService', function () {
    beforeEach(function () {
        $this->service = new OrderService();
    });

    describe('create', function () {
        test('creates order with valid data', function () {
            // Arrange
            $data = ['product_id' => 1, 'quantity' => 2];

            // Act
            $order = $this->service->create($data);

            // Assert
            expect($order)->toBeInstanceOf(Order::class);
        });

        test('throws exception for invalid quantity', function () {
            $this->service->create(['quantity' => -1]);
        })->throws(ValidationException::class);
    });
});
```

### 4. Coverage Minima

| Tipo | Coverage Target |
|------|-----------------|
| Models | 80% |
| Services/Actions | 90% |
| Controllers | 70% (feature tests) |
| Policies | 100% |

## Comandi Utili

```bash
# Run tests
php artisan test

# Con coverage
php artisan test --coverage

# Solo un file
php artisan test tests/Feature/OrderTest.php

# Filtra per nome
php artisan test --filter="can create order"
```
