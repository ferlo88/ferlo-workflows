---
name: ferlo-new-project
description: This skill guides the creation of new Laravel projects following EXTRAWEB AI-first methodology. Use when user asks to "create new project", "start new project", "setup project", "new Laravel project", or "initialize project".
version: 1.0.0
---

# New Project Workflow (AI-First)

Guida la creazione di nuovi progetti Laravel seguendo la metodologia AI-first EXTRAWEB.

## Fasi del Progetto

### Fase 1-5: Discovery (ChatGPT/Gemini)
Dalla chiamata cliente alla documentazione:

1. **Kickoff** → `docs/00_kickoff.md`
2. **User Stories** → `docs/01_user_stories.md`
3. **Requisiti Funzionali** → `docs/02_requisiti_funzionali.md`
4. **Requisiti Non Funzionali** → `docs/03_requisiti_non_funzionali.md`
5. **Scope & Boundaries** → `docs/04_scope.md`

### Fase 6-10: Design (Claude)
Dalla documentazione al codice:

6. **Data Model** → `docs/05_data_model.md`
7. **API Contract** → `docs/06_api_contract.md`
8. **Architettura** → `docs/07_architecture.md`
9. **Roadmap** → `docs/roadmap/ROADMAP.md`
10. **TODO per Fase** → `docs/roadmap/todo_fase_XX.md`

## Setup Progetto Laravel

```bash
# Crea progetto (usa sempre ultima versione stabile)
composer create-project laravel/laravel project-name

# Setup base
cd project-name
cp .env.example .env
php artisan key:generate

# Dipendenze EXTRAWEB standard (verifica compatibilità prima)
composer require laravel/sanctum           # Auth API/SPA
composer require spatie/laravel-permission # Ruoli e permessi
composer require spatie/laravel-query-builder # Filtri API
composer require spatie/laravel-data       # DTO e validazione

# Dev dependencies
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
composer require --dev larastan/larastan   # Static analysis
composer require --dev laravel/pint        # Code style

# Se admin panel
composer require filament/filament:"^5.0"
```

## Struttura Directory

```
project-name/
├── app/
│   ├── Actions/          # Single-purpose classes
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Models/
│   ├── Policies/
│   └── Services/
├── docs/                  # Documentazione progetto
│   ├── 00_kickoff.md
│   ├── ...
│   └── roadmap/
├── tests/
│   ├── Feature/
│   └── Unit/
└── CLAUDE.md              # Istruzioni per Claude Code
```

## Verifica Versioni Prima di Iniziare

**IMPORTANTE**: Prima di creare un nuovo progetto, verifica le ultime versioni disponibili:

```bash
# Verifica ultima versione Laravel
composer show laravel/laravel --available | head -5

# Oppure visita: https://laravel.com/docs/master/releases
# Per PHP: https://www.php.net/supported-versions.php
# Per Filament: https://filamentphp.com/docs
```

## CLAUDE.md Template

```markdown
# Project Name

## Panoramica
[Descrizione breve del progetto]

## Stack
- Laravel 12.x
- PHP 8.4
- MySQL 8.0 / PostgreSQL 16
- Redis 7.x
- Filament 5.x (se admin panel)

## Convenzioni
- UUID come primary key
- Soft delete per entità principali
- Form Request per validazione
- Resource per API response
- Action per operazioni singole

## Comandi
php artisan test          # Test
./vendor/bin/pint         # Code style
./vendor/bin/phpstan      # Static analysis
```
