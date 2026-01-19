---
name: ferlo-feature-integrator
description: This skill helps integrate new features into existing Laravel projects following EXTRAWEB conventions. Use when user asks to "add feature", "integrate feature", "implement feature", "add new functionality", or "extend the application".
version: 1.0.0
---

# Feature Integration Workflow

Integra nuove feature in progetti Laravel esistenti seguendo le convenzioni EXTRAWEB.

## Fasi di Integrazione

### 1. Analisi Codebase
Prima di implementare, analizza:
- Struttura esistente del progetto
- Pattern già in uso (Repository, Service, Action)
- Convenzioni di naming
- Dipendenze correlate

### 2. Pianificazione

Crea un piano con:
```markdown
## Feature: [Nome]

### File da Creare
- app/Models/NewModel.php
- app/Http/Controllers/NewController.php
- app/Services/NewService.php

### File da Modificare
- routes/api.php
- app/Providers/AppServiceProvider.php

### Migrazioni
- create_new_table

### Test
- tests/Feature/NewFeatureTest.php
- tests/Unit/NewServiceTest.php
```

### 3. Implementazione

**Ordine consigliato:**
1. Migration e Model
2. Service/Action con business logic
3. Controller
4. Routes
5. Policy (se serve autorizzazione)
6. Test

### 4. Struttura EXTRAWEB

```
app/
├── Actions/           # Single-purpose classes
│   └── CreateOrderAction.php
├── Http/
│   ├── Controllers/
│   │   └── OrderController.php
│   └── Requests/
│       └── StoreOrderRequest.php
├── Models/
│   └── Order.php
├── Services/          # Business logic complessa
│   └── OrderService.php
└── Policies/
    └── OrderPolicy.php
```

### 5. Convenzioni

**Controller**: Thin, delega a Service/Action
```php
public function store(StoreOrderRequest $request)
{
    $order = app(CreateOrderAction::class)->execute($request->validated());
    return new OrderResource($order);
}
```

**Model**: Relazioni, scopes, casts
```php
class Order extends Model
{
    use HasUuids, SoftDeletes;

    protected $fillable = ['user_id', 'total', 'status'];
    protected $casts = ['status' => OrderStatus::class];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

## Checklist Pre-Merge

- [ ] Migrazione con rollback funzionante
- [ ] Test feature e unit
- [ ] Policy per autorizzazione
- [ ] Form Request per validazione
- [ ] Resource per API response
- [ ] Quality gates passano
