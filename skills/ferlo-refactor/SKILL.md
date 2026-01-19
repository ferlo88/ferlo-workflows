---
name: ferlo-refactor
description: This skill guides code refactoring following Laravel best practices. Use when user asks for "refactor", "clean up code", "improve code", "extract method", "reduce complexity", "better architecture", or "code smell".
version: 1.0.0
---

# Refactoring Workflow

Guida al refactoring sistematico di codice Laravel.

## Principi di Refactoring

1. **Mai refactoring senza test** - Assicurati di avere test prima
2. **Piccoli passi** - Un cambiamento alla volta
3. **Verifica dopo ogni passo** - Test devono passare
4. **Commit frequenti** - Ogni refactoring = 1 commit

## Code Smells Comuni

### 1. Controller Troppo Grandi

**Prima:**
```php
public function store(Request $request)
{
    $validated = $request->validate([...]);

    // 50+ righe di logica business
    $user = User::create($validated);
    $user->assignRole('customer');
    Mail::to($user)->send(new WelcomeMail($user));
    event(new UserRegistered($user));
    // ... altro codice
}
```

**Dopo:**
```php
public function store(StoreUserRequest $request, UserRegistrationService $service)
{
    $user = $service->register($request->validated());

    return new UserResource($user);
}
```

### 2. Logica nei Model (Fat Models)

**Estrai in Service:**
```php
// app/Services/OrderService.php
class OrderService
{
    public function __construct(
        private readonly InventoryService $inventory,
        private readonly PaymentService $payment,
    ) {}

    public function process(Order $order): void
    {
        $this->inventory->reserve($order->items);
        $this->payment->charge($order);
        $order->markAsProcessed();
    }
}
```

### 3. Query Complesse nei Controller

**Estrai in Repository o Query Builder:**
```php
// app/Builders/ProductQueryBuilder.php
class ProductQueryBuilder
{
    public function __construct(private Builder $query) {}

    public function active(): self
    {
        $this->query->where('status', 'active');
        return $this;
    }

    public function inCategory(int $categoryId): self
    {
        $this->query->where('category_id', $categoryId);
        return $this;
    }

    public function priceRange(float $min, float $max): self
    {
        $this->query->whereBetween('price', [$min, $max]);
        return $this;
    }

    public function get(): Collection
    {
        return $this->query->get();
    }
}
```

### 4. Duplicazione di Codice

**Estrai in Trait:**
```php
// app/Traits/HasUuid.php
trait HasUuid
{
    protected static function bootHasUuid(): void
    {
        static::creating(function ($model) {
            $model->uuid = (string) Str::uuid();
        });
    }
}
```

**Estrai in Classe Base:**
```php
// app/Services/BaseService.php
abstract class BaseService
{
    protected function logAction(string $action, array $data = []): void
    {
        Log::info("{$action}", array_merge($data, [
            'user_id' => auth()->id(),
            'timestamp' => now(),
        ]));
    }
}
```

## Pattern di Refactoring

### Extract Method
```php
// Prima
public function process()
{
    // 20 righe per validazione
    // 20 righe per calcolo
    // 20 righe per salvataggio
}

// Dopo
public function process()
{
    $this->validate();
    $result = $this->calculate();
    $this->save($result);
}

private function validate(): void { /* ... */ }
private function calculate(): array { /* ... */ }
private function save(array $data): void { /* ... */ }
```

### Replace Conditional with Polymorphism
```php
// Prima
public function calculate(string $type): float
{
    if ($type === 'basic') {
        return $this->price;
    } elseif ($type === 'premium') {
        return $this->price * 1.5;
    } elseif ($type === 'enterprise') {
        return $this->price * 2.0;
    }
}

// Dopo - Strategy Pattern
interface PricingStrategy
{
    public function calculate(float $basePrice): float;
}

class BasicPricing implements PricingStrategy
{
    public function calculate(float $basePrice): float
    {
        return $basePrice;
    }
}

class PremiumPricing implements PricingStrategy
{
    public function calculate(float $basePrice): float
    {
        return $basePrice * 1.5;
    }
}
```

### Introduce Parameter Object
```php
// Prima
public function search(
    string $query,
    ?int $categoryId,
    ?float $minPrice,
    ?float $maxPrice,
    string $sortBy,
    string $sortDir,
    int $perPage
) { }

// Dopo
public function search(ProductSearchCriteria $criteria) { }

class ProductSearchCriteria
{
    public function __construct(
        public readonly string $query,
        public readonly ?int $categoryId = null,
        public readonly ?float $minPrice = null,
        public readonly ?float $maxPrice = null,
        public readonly string $sortBy = 'created_at',
        public readonly string $sortDir = 'desc',
        public readonly int $perPage = 15,
    ) {}
}
```

## Refactoring Steps

1. **Identifica il code smell**
2. **Scrivi test se mancanti**
3. **Applica refactoring minimo**
4. **Esegui test**
5. **Commit**
6. **Ripeti**

## Strumenti

### PHPStan per trovare problemi
```bash
./vendor/bin/phpstan analyse app --level=5
```

### Pint per formattazione
```bash
./vendor/bin/pint
```

### IDE Refactoring
- Extract Method: Cmd+Alt+M
- Extract Variable: Cmd+Alt+V
- Rename: Shift+F6
- Move: F6

## Checklist Pre-Refactoring

- [ ] Test esistenti passano?
- [ ] Backup/branch creato?
- [ ] Scope definito (cosa refactorare)?
- [ ] Tempo stimato?
- [ ] Team informato?
