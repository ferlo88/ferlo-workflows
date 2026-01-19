---
name: ferlo-i18n
description: This skill manages Laravel translations and localization files. Use when user asks for "translations", "i18n", "localization", "translate", "add language", "missing translations", or "sync translations".
version: 1.0.0
---

# i18n Manager - Laravel Translations

Gestisce traduzioni e localizzazione per progetti Laravel.

## Struttura File Laravel

```
lang/
├── en/
│   ├── auth.php
│   ├── pagination.php
│   ├── passwords.php
│   ├── validation.php
│   └── messages.php      # Custom
├── it/
│   ├── auth.php
│   ├── pagination.php
│   ├── passwords.php
│   ├── validation.php
│   └── messages.php
└── en.json               # JSON translations
└── it.json
```

## Operazioni Comuni

### Trova Stringhe Non Tradotte

Cerca `__()` e `trans()` nel codice:

```bash
grep -r "__('[^']*')" app/ resources/ --include="*.php" --include="*.blade.php" |
  grep -oP "__\('\K[^']*" | sort | uniq
```

### Confronta File Lingua

Trova chiavi mancanti tra due lingue:

```php
// Confronta it vs en
$en = include lang_path('en/messages.php');
$it = include lang_path('it/messages.php');

$missing = array_diff_key($en, $it);
```

### Aggiungi Nuova Lingua

1. Copia struttura da lingua base:
```bash
cp -r lang/en lang/es
```

2. Traduci ogni file

3. Crea JSON per stringhe inline:
```bash
touch lang/es.json
echo "{}" > lang/es.json
```

## Formato File PHP

```php
<?php
// lang/it/messages.php

return [
    'welcome' => 'Benvenuto nella nostra applicazione!',
    'greeting' => 'Ciao, :name!',

    'user' => [
        'profile' => 'Profilo Utente',
        'settings' => 'Impostazioni',
        'logout' => 'Esci',
    ],

    'validation' => [
        'required' => 'Il campo :attribute è obbligatorio.',
        'email' => 'Il campo :attribute deve essere un indirizzo email valido.',
    ],
];
```

## Formato File JSON

Per stringhe usate direttamente con `__()`:

```json
{
    "Welcome to our application!": "Benvenuto nella nostra applicazione!",
    "Hello, :name!": "Ciao, :name!",
    "Your order has been placed.": "Il tuo ordine è stato effettuato."
}
```

## Uso in Blade

```blade
{{-- Da file PHP --}}
{{ __('messages.welcome') }}
{{ trans('messages.greeting', ['name' => $user->name]) }}

{{-- Da file JSON --}}
{{ __('Welcome to our application!') }}

{{-- Pluralizzazione --}}
{{ trans_choice('messages.items', $count) }}

@lang('messages.welcome')
```

## Pluralizzazione

```php
// lang/it/messages.php
return [
    'items' => '{0} Nessun elemento|{1} Un elemento|[2,*] :count elementi',
    'apples' => '{0} nessuna mela|{1} una mela|[2,10] alcune mele|[11,*] molte mele',
];
```

## Sync Traduzioni

Script per sincronizzare chiavi tra lingue:

```php
// Trova chiavi mancanti in IT rispetto a EN
$enKeys = array_keys(Arr::dot(include lang_path('en/messages.php')));
$itKeys = array_keys(Arr::dot(include lang_path('it/messages.php')));

$missing = array_diff($enKeys, $itKeys);

foreach ($missing as $key) {
    echo "Manca in IT: $key\n";
}
```

## Checklist Nuova Lingua

- [ ] Copiata struttura da lingua base
- [ ] Tradotti file auth.php, pagination.php, passwords.php
- [ ] Tradotto validation.php (importante!)
- [ ] Creati file custom (messages.php, etc.)
- [ ] Creato file JSON per stringhe inline
- [ ] Testata visualizzazione nell'app
- [ ] Aggiunto a config/app.php `available_locales`

## Best Practices

1. **Chiavi descrittive**: `user.profile.edit` non `str1`
2. **Usa placeholder**: `:name` non concatenazione
3. **Raggruppa logicamente**: per feature/modulo
4. **Mantieni sync**: EN come lingua base
5. **Non tradurre codice**: solo testo utente
