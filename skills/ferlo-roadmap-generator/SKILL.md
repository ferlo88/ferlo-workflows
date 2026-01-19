---
name: ferlo-roadmap-generator
description: Genera roadmap e file todo_fase_XX.md compatibili con ferlo-laravel-phase-executor. Usa quando l'utente chiede di "generare roadmap", "creare TODO da docs", "pianificare implementazione", "fasi sviluppo", o ha file MD di feature da trasformare in piano di lavoro eseguibile.
version: 2.0.0
---

# Roadmap Generator - Da Documentazione a Piano Eseguibile

Trasforma la documentazione di una feature in un piano di implementazione strutturato con fasi e TODO **compatibili con ferlo-laravel-phase-executor**.

## Output Compatibile

I file generati sono direttamente eseguibili con:
```
"Esegui la fase 01 del progetto"
```

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
docs/roadmap/
├── ROADMAP.md                      # Panoramica e dipendenze
├── todo_fase_00_setup.md           # Setup iniziale
├── todo_fase_01_database.md        # Schema e migrazioni
├── todo_fase_02_backend.md         # Modelli e logica
├── todo_fase_03_frontend.md        # UI e componenti
├── todo_fase_04_api.md             # Endpoints (se presente)
├── todo_fase_05_migration.md       # Dati legacy (se presente)
└── todo_fase_06_testing.md         # Testing
```

**IMPORTANTE**: Il naming `todo_fase_XX_nome.md` è obbligatorio per compatibilità con phase-executor.

---

## Template File Output

### ROADMAP.md

```markdown
# [Feature/Project Name] - Roadmap Implementazione

## Overview

| Campo | Valore |
|-------|--------|
| **Progetto** | [nome] |
| **Complessità** | [Bassa/Media/Alta] |
| **Fasi totali** | [N] |
| **Generato il** | [data] |

## Fasi

| Fase | File | Nome | Dipende da | Priorità |
|------|------|------|------------|----------|
| 00 | todo_fase_00_setup.md | Setup Progetto | - | Critica |
| 01 | todo_fase_01_database.md | Database Schema | Fase 00 | Critica |
| 02 | todo_fase_02_backend.md | Backend Logic | Fase 01 | Alta |
| 03 | todo_fase_03_frontend.md | Frontend UI | Fase 02 | Alta |
| 04 | todo_fase_04_api.md | API Endpoints | Fase 02 | Media |
| 05 | todo_fase_05_migration.md | Data Migration | Fase 01 | Media |
| 06 | todo_fase_06_testing.md | Testing & QA | Fase 03,04 | Alta |

## Diagramma Dipendenze

```
Fase 00 (Setup)
    │
    ▼
Fase 01 (Database)
    │
    ├──────────────┐
    ▼              ▼
Fase 02 (Backend)  Fase 05 (Migration)
    │
    ├──────────────┐
    ▼              ▼
Fase 03 (Frontend) Fase 04 (API)
    │              │
    └──────┬───────┘
           ▼
    Fase 06 (Testing)
```

## Quick Start

1. Leggi ogni file `todo_fase_XX_*.md` in ordine
2. Oppure usa: `"Esegui la fase 01 del progetto"`
3. Il phase-executor gestirà automaticamente branch, commit e quality gates
```

---

### Template todo_fase_XX_nome.md

**FORMATO OBBLIGATORIO** per compatibilità con phase-executor:

```markdown
# Fase {XX}: {NOME_FASE}

<!--
ISTRUZIONI PER CLAUDE:
1. Leggi questo file dall'inizio
2. Verifica i pre-requisiti
3. Esegui ogni task [ ] in ordine
4. Dopo ogni task: testa, committa
5. Alla fine: quality gates, aggiorna questo file, push
-->

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | {Nome descrittivo} |
| **Durata stimata** | {X} giorni |
| **Dipende da** | Fase {YY} |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-{nome-slug}` |
| **Assegnato** | Claude Code |

## Obiettivo

{Descrizione chiara in 2-3 righe di cosa deve essere completato in questa fase}

## Pre-requisiti

Prima di iniziare, verifica che:

- [ ] Fase {YY} completata e mergiata
- [ ] Branch `develop` aggiornato
- [ ] Database migrato
- [ ] `.env` configurato correttamente

---

## Task List

### {Categoria 1}

- [ ] `TASK-{XX}-001` **{Titolo task}**
  - **File:** `{percorso/file.php}`
  - **Descrizione:** {Cosa deve fare questo task}
  - **Acceptance criteria:**
    - [ ] {Criterio 1}
    - [ ] {Criterio 2}

- [ ] `TASK-{XX}-002` **{Titolo task}**
  - **File:** `{percorso/file.php}`
  - **Descrizione:** {Cosa deve fare}
  - **Acceptance criteria:**
    - [ ] {Criterio 1}

### {Categoria 2}

- [ ] `TASK-{XX}-010` **{Titolo task}**
  - **File:** `{percorso/file.php}`
  - **Descrizione:** {Cosa deve fare}

---

## Quality Gates

Esegui tutti i gate dopo aver completato i task:

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Unit Tests | `php artisan test --testsuite=Unit` | Si | |
| Feature Tests | `php artisan test --testsuite=Feature` | Si | |
| Code Style | `./vendor/bin/pint --test` | Si | |
| Static Analysis | `./vendor/bin/phpstan analyse` | Si | |
| Security | `composer audit` | Si | |

---

## Finalizzazione

Dopo i quality gates:

- [ ] Aggiorna questo file (segna [x] tutti i task)
- [ ] Aggiorna `CHANGELOG.md`
- [ ] Commit finale: `docs(fase-{XX}): complete phase {XX} - {nome}`
- [ ] Push: `git push origin feature/fase-{XX}-{nome}`

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```

---

## Note di Sviluppo

| Data | Nota |
|------|------|
| | |
```

---

## Esempi Concreti per Fase

### todo_fase_00_setup.md

```markdown
# Fase 00: Setup Progetto

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | 00 |
| **Nome** | Setup Progetto |
| **Durata stimata** | 0.5 giorni |
| **Dipende da** | - |
| **Status** | TODO |
| **Branch** | `feature/fase-00-setup` |
| **Assegnato** | Claude Code |

## Obiettivo

Preparare l'ambiente, creare la struttura directory e installare le dipendenze necessarie.

## Pre-requisiti

- [ ] Repository clonato
- [ ] Ambiente locale funzionante
- [ ] Accesso al database

---

## Task List

### Configurazione

- [ ] `TASK-00-001` **Creare branch di sviluppo**
  - **Descrizione:** Creare branch feature dalla develop
  - **Acceptance criteria:**
    - [ ] Branch creato da develop aggiornato

- [ ] `TASK-00-002` **Installare dipendenze Composer**
  - **File:** `composer.json`
  - **Descrizione:** Installare pacchetti richiesti
  - **Acceptance criteria:**
    - [ ] Pacchetti installati senza errori

- [ ] `TASK-00-003` **Configurare variabili ambiente**
  - **File:** `.env`
  - **Descrizione:** Aggiungere variabili necessarie
  - **Acceptance criteria:**
    - [ ] Variabili aggiunte
    - [ ] Applicazione funzionante

### Struttura

- [ ] `TASK-00-010` **Creare directory structure**
  - **Descrizione:** Creare cartelle per la feature
  - **Acceptance criteria:**
    - [ ] Directory create secondo convenzioni

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Tests | `php artisan test` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |

---

## Finalizzazione

- [ ] Commit: `docs(fase-00): complete setup phase`
- [ ] Push branch

## Progress

```
Completamento: 0/4 task (0%)
```
```

### todo_fase_01_database.md

```markdown
# Fase 01: Database Schema

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | 01 |
| **Nome** | Database Schema |
| **Durata stimata** | 1 giorno |
| **Dipende da** | Fase 00 |
| **Status** | TODO |
| **Branch** | `feature/fase-01-database` |
| **Assegnato** | Claude Code |

## Obiettivo

Creare lo schema database con migrations, definire indici e foreign keys.

## Pre-requisiti

- [ ] Fase 00 completata e mergiata
- [ ] Branch develop aggiornato
- [ ] Database locale accessibile

---

## Task List

### Migrations

- [ ] `TASK-01-001` **Creare migration tabella [nome]**
  - **File:** `database/migrations/xxxx_create_[nome]_table.php`
  - **Descrizione:** Definire schema tabella principale
  - **Acceptance criteria:**
    - [ ] Migration creata
    - [ ] Tutti i campi definiti
    - [ ] Indici configurati
    - [ ] Foreign keys definite

- [ ] `TASK-01-002` **Creare migration tabella [nome2]**
  - **File:** `database/migrations/xxxx_create_[nome2]_table.php`
  - **Descrizione:** Definire schema tabella correlata
  - **Acceptance criteria:**
    - [ ] Migration creata
    - [ ] Relazioni definite

### Esecuzione

- [ ] `TASK-01-010` **Eseguire migrations**
  - **Descrizione:** Applicare migrations al database
  - **Acceptance criteria:**
    - [ ] `php artisan migrate` eseguito senza errori
    - [ ] Schema verificato con `db:show`

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Tests | `php artisan test` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |

---

## Finalizzazione

- [ ] Commit: `docs(fase-01): complete database phase`
- [ ] Push branch

## Progress

```
Completamento: 0/3 task (0%)
```
```

---

## Workflow di Generazione

### Step 1: Leggi Documentazione Feature

```bash
# Trova i file di documentazione
ls docs/features/[feature-name]/

# Leggi ogni file
cat docs/features/[feature-name]/FEATURE-OVERVIEW.md
cat docs/features/[feature-name]/DATABASE-SCHEMA.md
# ... etc
```

### Step 2: Estrai Informazioni

Per ogni file MD, estrai:

| File Sorgente | Genera | Task ID Range |
|---------------|--------|---------------|
| FEATURE-OVERVIEW | todo_fase_00_setup.md | TASK-00-XXX |
| DATABASE-SCHEMA | todo_fase_01_database.md | TASK-01-XXX |
| BACKEND-LOGIC | todo_fase_02_backend.md | TASK-02-XXX |
| FRONTEND-UI | todo_fase_03_frontend.md | TASK-03-XXX |
| API-ENDPOINTS | todo_fase_04_api.md | TASK-04-XXX |
| DATA-MIGRATION | todo_fase_05_migration.md | TASK-05-XXX |
| (sempre) | todo_fase_06_testing.md | TASK-06-XXX |

### Step 3: Genera File

Per ogni fase:

1. **Crea file** con nome `todo_fase_XX_nome.md`
2. **Compila Metadata** con ID, dipendenze, branch
3. **Genera Task List** con ID progressivi `TASK-XX-NNN`
4. **Aggiungi Quality Gates** standard
5. **Calcola Progress** totale task

### Step 4: Genera ROADMAP.md

1. Elenca tutte le fasi generate
2. Definisci dipendenze
3. Crea diagramma ASCII
4. Aggiungi istruzioni quick start

---

## Domande da Fare all'Utente

Prima di generare, chiedi:

1. **Stack target?** (Laravel, Filament, Livewire, Vue)
2. **Livello dettaglio?**
   - Alto: ogni campo, ogni metodo → più TASK
   - Medio: per componente → bilanciato
   - Basso: solo macro-task → meno TASK
3. **Includere stime?** (Sì/No)
4. **Testing?** (Unit, Feature, Browser, tutti)

---

## Convenzioni Naming

### File
- `todo_fase_XX_nome.md` (lowercase, underscore)
- XX = numero fase con zero padding (00, 01, 02...)
- nome = slug lowercase (database, backend, frontend...)

### Task ID
- `TASK-XX-NNN`
- XX = numero fase
- NNN = numero task progressivo (001, 002, 010, 011...)
- Lasciare gap per inserimenti (001, 002, 010, 011, 020...)

### Branch
- `feature/fase-XX-nome`

### Commit
- `feat(fase-XX): TASK-XX-NNN - descrizione`
- `docs(fase-XX): complete phase XX`

---

## Integrazione con Phase Executor

Dopo aver generato la roadmap, l'utente può eseguire:

```
"Esegui la fase 01 del progetto"
```

Il phase-executor:
1. Legge `docs/roadmap/todo_fase_01_*.md`
2. Crea branch `feature/fase-01-*`
3. Esegue ogni TASK in ordine
4. Applica quality gates
5. Committa e pusha
6. Genera report

---

## Best Practices

1. **Task atomici**: Un TASK = un'azione completabile e testabile
2. **Acceptance criteria**: Sempre verificabili oggettivamente
3. **File espliciti**: Indicare sempre il file da creare/modificare
4. **Gap negli ID**: TASK-01-001, 002, 010, 011 (permette inserimenti)
5. **Dipendenze chiare**: Ogni fase indica da cosa dipende
6. **Quality gates**: Sempre presenti in ogni fase

---

*Skill aggiornata per compatibilità con ferlo-laravel-phase-executor - v2.0.0*
