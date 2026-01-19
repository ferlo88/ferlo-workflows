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
# Crea progetto
composer create-project laravel/laravel project-name

# Setup base
cd project-name
cp .env.example .env
php artisan key:generate

# Dipendenze EXTRAWEB standard
composer require laravel/sanctum
composer require spatie/laravel-permission
composer require spatie/laravel-query-builder

# Dev dependencies
composer require --dev pestphp/pest
composer require --dev larastan/larastan
composer require --dev laravel/pint
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

## CLAUDE.md Template

```markdown
# Project Name

## Panoramica
[Descrizione breve del progetto]

## Stack
- Laravel 11.x
- PHP 8.3
- MySQL 8.0
- Redis

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
