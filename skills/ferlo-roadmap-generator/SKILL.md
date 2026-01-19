---
name: ferlo-roadmap-generator
description: Genera roadmap e TODO da documentazione feature esistente. Usa quando l'utente chiede di "generare roadmap", "creare TODO da docs", "pianificare implementazione", "fasi sviluppo", "convertire specifiche in task", o ha file MD di feature da trasformare in piano di lavoro.
version: 1.0.0
---

# Roadmap Generator - Da Documentazione a Piano di Lavoro

Trasforma la documentazione di una feature (generata da `/extract` o manuale) in un piano di implementazione strutturato con fasi, TODO e stime.

## Input Atteso

Directory con file MD di documentazione feature:

```
docs/features/[feature-name]/
├── FEATURE-OVERVIEW.md      # Obbligatorio
├── DATABASE-SCHEMA.md       # Opzionale
├── BACKEND-LOGIC.md         # Opzionale
├── FRONTEND-UI.md           # Opzionale
├── API-ENDPOINTS.md         # Opzionale
└── DATA-MIGRATION.md        # Opzionale
```

## Output Generato

```
docs/roadmap/[feature-name]/
├── ROADMAP.md               # Panoramica fasi
├── FASE-00-SETUP.md         # Setup iniziale
├── FASE-01-DATABASE.md      # Schema e migrazioni
├── FASE-02-BACKEND.md       # Modelli e logica
├── FASE-03-FRONTEND.md      # UI e componenti
├── FASE-04-API.md           # Endpoints (se presente)
├── FASE-05-MIGRATION.md     # Dati legacy (se presente)
├── FASE-06-TEST.md          # Testing
└── TODO.md                  # Checklist completa
```

## Workflow

### Step 1: Leggi Documentazione Feature

```bash
# Trova i file di documentazione
ls docs/features/[feature-name]/

# Leggi ogni file
cat docs/features/[feature-name]/FEATURE-OVERVIEW.md
cat docs/features/[feature-name]/DATABASE-SCHEMA.md
# ... etc
```

### Step 2: Analizza e Struttura

Per ogni file MD, estrai:

| File Sorgente | Informazioni da Estrarre |
|---------------|--------------------------|
| FEATURE-OVERVIEW | Funzionalità, dipendenze, flussi |
| DATABASE-SCHEMA | Tabelle, campi, relazioni, indici |
| BACKEND-LOGIC | Modelli, validazioni, business rules |
| FRONTEND-UI | Schermate, form, componenti |
| API-ENDPOINTS | Endpoints, metodi, payload |
| DATA-MIGRATION | Mapping, trasformazioni, validazioni |

### Step 3: Genera Fasi Roadmap

## Template File Output

### ROADMAP.md

```markdown
# [Feature Name] - Roadmap Implementazione

## Overview
- **Feature**: [nome]
- **Complessità stimata**: [Bassa/Media/Alta]
- **Fasi totali**: [N]
- **Dipendenze esterne**: [elenco]

## Fasi

| Fase | Nome | Dipende da | Priorità |
|------|------|------------|----------|
| 0 | Setup Progetto | - | Critica |
| 1 | Database Schema | Fase 0 | Critica |
| 2 | Backend Logic | Fase 1 | Alta |
| 3 | Frontend UI | Fase 2 | Alta |
| 4 | API Endpoints | Fase 2 | Media |
| 5 | Data Migration | Fase 1 | Media |
| 6 | Testing & QA | Fase 3,4 | Alta |

## Diagramma Dipendenze

```
Fase 0 (Setup)
    │
    ▼
Fase 1 (Database)
    │
    ├──────────────┐
    ▼              ▼
Fase 2 (Backend)  Fase 5 (Migration)
    │
    ├──────────────┐
    ▼              ▼
Fase 3 (Frontend) Fase 4 (API)
    │              │
    └──────┬───────┘
           ▼
    Fase 6 (Testing)
```

## Quick Start

1. Leggi `FASE-00-SETUP.md` e completa i prerequisiti
2. Procedi in ordine seguendo le dipendenze
3. Usa `TODO.md` come checklist di avanzamento
```

### FASE-00-SETUP.md

```markdown
# Fase 0 - Setup Progetto

## Obiettivo
Preparare l'ambiente e le dipendenze per l'implementazione della feature.

## Prerequisiti
- [ ] Ambiente di sviluppo configurato
- [ ] Accesso al repository
- [ ] Database locale funzionante

## TODO

### 0.1 Creazione Branch
```bash
git checkout -b feature/[feature-name]
```

### 0.2 Dipendenze (se necessarie)
```bash
# Composer packages
composer require [packages]

# NPM packages
npm install [packages]
```

### 0.3 Configurazione
- [ ] Variabili .env necessarie
- [ ] Config files da creare/modificare

### 0.4 Directory Structure
```
app/
├── Models/[Feature]/
├── Http/Controllers/[Feature]/
├── Services/[Feature]/
└── ...
```

## Criteri di Completamento
- [ ] Branch creato
- [ ] Dipendenze installate
- [ ] Configurazione completata
- [ ] Struttura directory pronta

## Prossima Fase
→ [FASE-01-DATABASE.md](./FASE-01-DATABASE.md)
```

### FASE-01-DATABASE.md

```markdown
# Fase 1 - Database Schema

## Obiettivo
Creare lo schema database per la feature.

## Dipendenze
- ✅ Fase 0 completata

## TODO

### 1.1 Migrations

Per ogni tabella in DATABASE-SCHEMA.md:

#### Tabella: `[table_name]`
```bash
php artisan make:migration create_[table_name]_table
```

```php
Schema::create('[table_name]', function (Blueprint $table) {
    $table->id();
    // [campi da DATABASE-SCHEMA.md]
    $table->timestamps();
});
```

**Campi:**
- [ ] `campo1` - tipo - descrizione
- [ ] `campo2` - tipo - descrizione
- [ ] ...

**Indici:**
- [ ] Index su `campo_x`
- [ ] Unique su `campo_y`

**Foreign Keys:**
- [ ] `field_id` → `other_table.id`

### 1.2 Esegui Migrations
```bash
php artisan migrate
```

### 1.3 Verifica Schema
```bash
php artisan db:show --table=[table_name]
```

## Criteri di Completamento
- [ ] Tutte le migrations create
- [ ] Migrations eseguite senza errori
- [ ] Schema verificato corrisponde a DATABASE-SCHEMA.md
- [ ] Indici e FK funzionanti

## Prossima Fase
→ [FASE-02-BACKEND.md](./FASE-02-BACKEND.md)
```

### FASE-02-BACKEND.md

```markdown
# Fase 2 - Backend Logic

## Obiettivo
Implementare modelli, validazioni e business logic.

## Dipendenze
- ✅ Fase 1 completata (schema DB esistente)

## TODO

### 2.1 Models

Per ogni modello in BACKEND-LOGIC.md:

#### Model: `[ModelName]`
```bash
php artisan make:model [ModelName]
```

- [ ] Definire `$fillable`
- [ ] Definire `$casts`
- [ ] Implementare relazioni:
  - [ ] `relationName()` → BelongsTo
  - [ ] `relationName()` → HasMany
- [ ] Implementare scopes:
  - [ ] `scopeName()`
- [ ] Implementare accessors/mutators

### 2.2 Form Requests (Validazione)

```bash
php artisan make:request [ModelName]Request
```

Regole da BACKEND-LOGIC.md:
- [ ] `campo1` → `required|string|max:255`
- [ ] `campo2` → `nullable|date`
- [ ] ...

### 2.3 Services/Actions

```bash
mkdir -p app/Services/[Feature]
```

- [ ] `Create[Model]Action`
- [ ] `Update[Model]Action`
- [ ] `Delete[Model]Action`
- [ ] Business logic specifica

### 2.4 Controllers

```bash
php artisan make:controller [Feature]/[Model]Controller --resource
```

- [ ] `index()` - lista
- [ ] `create()` - form creazione
- [ ] `store()` - salva nuovo
- [ ] `show()` - dettaglio
- [ ] `edit()` - form modifica
- [ ] `update()` - salva modifiche
- [ ] `destroy()` - elimina

### 2.5 Routes

```php
// routes/web.php
Route::resource('[feature]', [Model]Controller::class);
```

### 2.6 Policies (se necessarie)

```bash
php artisan make:policy [Model]Policy --model=[Model]
```

## Criteri di Completamento
- [ ] Models con relazioni funzionanti
- [ ] Validazioni implementate
- [ ] Services/Actions testabili
- [ ] Routes registrate
- [ ] CRUD base funzionante

## Prossima Fase
→ [FASE-03-FRONTEND.md](./FASE-03-FRONTEND.md)
```

### FASE-03-FRONTEND.md

```markdown
# Fase 3 - Frontend UI

## Obiettivo
Implementare interfaccia utente e componenti.

## Dipendenze
- ✅ Fase 2 completata (backend funzionante)

## TODO

### 3.1 Views/Pages

Da FRONTEND-UI.md, per ogni schermata:

#### Lista [Feature]
- [ ] Creare view `resources/views/[feature]/index.blade.php`
- [ ] Tabella con colonne: [elenco]
- [ ] Filtri: [elenco]
- [ ] Azioni: [elenco]
- [ ] Paginazione

#### Form Crea/Modifica
- [ ] Creare view `resources/views/[feature]/form.blade.php`
- [ ] Campi form:
  | Campo | Tipo Input | Validazione JS |
  |-------|------------|----------------|
  | ... | ... | ... |
- [ ] Feedback errori
- [ ] Submit con loading state

#### Dettaglio
- [ ] Creare view `resources/views/[feature]/show.blade.php`
- [ ] Sezioni: [elenco]
- [ ] Azioni: [elenco]

### 3.2 Componenti Riutilizzabili

- [ ] Componente 1: [descrizione]
- [ ] Componente 2: [descrizione]

### 3.3 Filament Resources (se applicabile)

```bash
php artisan make:filament-resource [Model] --generate
```

- [ ] Configurare `$table` columns
- [ ] Configurare `$form` fields
- [ ] Configurare filters
- [ ] Configurare actions

### 3.4 Assets

- [ ] CSS/Tailwind specifici
- [ ] JavaScript interazioni
- [ ] Build assets: `npm run build`

## Criteri di Completamento
- [ ] Tutte le schermate implementate
- [ ] Form funzionanti con validazione
- [ ] Componenti riutilizzabili
- [ ] UI responsive
- [ ] UX conforme a FRONTEND-UI.md

## Prossima Fase
→ [FASE-04-API.md](./FASE-04-API.md) (se presente)
→ [FASE-06-TEST.md](./FASE-06-TEST.md) (se no API)
```

### TODO.md

```markdown
# [Feature Name] - TODO Completo

## Legenda
- [ ] Da fare
- [x] Completato
- [~] In corso
- [!] Bloccato

---

## Fase 0 - Setup
- [ ] Creare branch feature
- [ ] Installare dipendenze
- [ ] Configurare ambiente

## Fase 1 - Database
- [ ] Migration `create_table1_table`
- [ ] Migration `create_table2_table`
- [ ] Verificare schema

## Fase 2 - Backend
- [ ] Model `Model1`
  - [ ] Fillable
  - [ ] Relazioni
  - [ ] Scopes
- [ ] Model `Model2`
  - [ ] ...
- [ ] FormRequest validazioni
- [ ] Controller CRUD
- [ ] Routes
- [ ] Policy

## Fase 3 - Frontend
- [ ] View lista
- [ ] View form
- [ ] View dettaglio
- [ ] Componenti
- [ ] Filament Resource

## Fase 4 - API (se presente)
- [ ] GET /api/resource
- [ ] POST /api/resource
- [ ] PUT /api/resource/{id}
- [ ] DELETE /api/resource/{id}

## Fase 5 - Migration Dati (se presente)
- [ ] Script migrazione
- [ ] Validazione dati
- [ ] Rollback plan

## Fase 6 - Testing
- [ ] Unit tests models
- [ ] Feature tests controllers
- [ ] Browser tests UI
- [ ] Test coverage > 80%

---

## Note e Blocchi

[Spazio per annotazioni durante lo sviluppo]

---

## Changelog Implementazione

| Data | Fase | Completato | Note |
|------|------|------------|------|
| | | | |
```

## Domande da Fare all'Utente

Prima di generare, chiedi:

1. **Stack target?** (Laravel, Filament, Livewire, Vue, etc.)
2. **Livello dettaglio TODO?** (Alto/Medio/Basso)
3. **Includere stime temporali?** (Sì/No)
4. **Testing richiesto?** (Unit, Feature, Browser, tutti)
5. **Convenzioni naming progetto?** (Se diverse da default)

## Comandi Utili

```bash
# Verifica file sorgente esistono
ls -la docs/features/[feature-name]/

# Crea directory output
mkdir -p docs/roadmap/[feature-name]/

# Conta TODO generati
grep -c "\- \[ \]" docs/roadmap/[feature-name]/TODO.md
```

## Best Practices

1. **Ordine fasi**: Rispetta sempre le dipendenze
2. **Granularità TODO**: Un TODO = un'azione atomica completabile
3. **Verifiche**: Ogni fase deve avere criteri di completamento chiari
4. **Flessibilità**: L'utente può riordinare fasi non dipendenti
5. **Tracciabilità**: Collegare ogni TODO al file sorgente di riferimento
