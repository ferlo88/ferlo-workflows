---
name: ferlo-feature-roadmap-generator
description: Aggiunge fasi di implementazione per nuove feature a una ROADMAP esistente. Legge i docs generati da feature-analyzer e chiede dove inserire le nuove fasi. Output compatibile con ferlo-phase-executor. Usa quando l'utente chiede "genera roadmap per feature", "aggiungi fasi per [feature]", "pianifica implementazione feature", "crea todo per nuova feature".
version: 1.0.0
triggers:
  - "genera roadmap per feature"
  - "aggiungi fasi feature"
  - "pianifica feature"
  - "crea todo feature"
  - "feature roadmap"
---

# Feature Roadmap Generator

Skill per aggiungere fasi di implementazione a una ROADMAP esistente, partendo dall'analisi generata da `feature-analyzer`.

## Obiettivo

Trasformare l'analisi di una feature in fasi implementative che si integrano con la roadmap esistente del progetto.

## Input Atteso

### Documenti di feature-analyzer
```
docs/features/[feature-name]/
├── codebase-analysis.md        # Architettura esistente
├── patterns-conventions.md     # Pattern da seguire
├── dependencies-map.md         # Dipendenze
├── database-schema.md          # Schema DB attuale
├── api-existing.md             # API esistenti
├── integration-points.md       # Punti integrazione
├── legacy-compatibility.md     # Note legacy
└── feature-requirements.md     # Requisiti feature
```

### ROADMAP esistente (opzionale)
```
docs/roadmap/
├── ROADMAP.md
└── todo_fase_XX_*.md
```

---

## Workflow di Esecuzione

### STEP 1: Verifica Input

```bash
# Cerca docs feature-analyzer
ls docs/features/*/

# Verifica ROADMAP esistente
ls docs/roadmap/ROADMAP.md
```

Se manca `docs/features/[feature-name]/`:
```
Non trovo documenti di analisi feature.

Opzioni:
1. Esegui prima `feature-analyzer` per analizzare il codebase
2. Indica manualmente il nome della feature: [nome]
```

### STEP 2: Lettura Analisi

Leggi tutti i file in `docs/features/[feature-name]/`:

```bash
cat docs/features/[feature-name]/codebase-analysis.md
cat docs/features/[feature-name]/feature-requirements.md
cat docs/features/[feature-name]/database-schema.md
# ... etc
```

Estrai:
- User stories da implementare
- Nuove entità database
- Nuovi endpoints API
- Modifiche a codice esistente
- Note di compatibilità legacy

### STEP 3: Determina Posizione Fasi

**CHIEDI ALL'UTENTE:**

```markdown
Ho analizzato la feature "[nome]" e identificato X fasi da aggiungere.

### Roadmap Attuale
[Se esiste ROADMAP.md, mostra le fasi esistenti]

| Fase | Nome | Status |
|------|------|--------|
| 00 | Setup | Completata |
| 01 | Database | Completata |
| 02 | Backend | In corso |
| 03 | Frontend | TODO |

### Nuove Fasi per [Feature]
1. Database [feature]
2. Backend [feature]
3. API [feature]
4. Frontend [feature]
5. Testing [feature]

**Dove vuoi inserire le nuove fasi?**

1. **Dopo l'ultima fase esistente** (04, 05, 06...)
   - Consigliato se la feature è indipendente

2. **In una posizione specifica**
   - Indica il numero: "dopo fase 02"
   - Utile se ci sono dipendenze

3. **Come sotto-fasi**
   - Es: 02a, 02b, 02c
   - Utile per feature minori

Rispondi con l'opzione preferita.
```

### STEP 4: Generazione Fasi

Genera i file `todo_fase_XX_*.md` nel formato compatibile con `ferlo-phase-executor`.

---

## Template Output

### Aggiornamento ROADMAP.md

Aggiungi le nuove fasi alla tabella esistente:

```markdown
## Fasi

| Fase | File | Nome | Dipende da | Priorità | Status |
|------|------|------|------------|----------|--------|
| 00 | todo_fase_00_setup.md | Setup Progetto | - | Critica | OK |
| 01 | todo_fase_01_database.md | Database Schema | Fase 00 | Critica | OK |
| 02 | todo_fase_02_backend.md | Backend Logic | Fase 01 | Alta | IN CORSO |
| 03 | todo_fase_03_frontend.md | Frontend UI | Fase 02 | Alta | TODO |
<!-- NUOVE FASI - [Feature Name] -->
| 04 | todo_fase_04_feature_db.md | [Feature] Database | Fase 01 | Alta | TODO |
| 05 | todo_fase_05_feature_backend.md | [Feature] Backend | Fase 04 | Alta | TODO |
| 06 | todo_fase_06_feature_api.md | [Feature] API | Fase 05 | Media | TODO |
| 07 | todo_fase_07_feature_frontend.md | [Feature] Frontend | Fase 06 | Alta | TODO |
| 08 | todo_fase_08_feature_testing.md | [Feature] Testing | Fase 07 | Alta | TODO |
```

### todo_fase_XX_feature_db.md

```markdown
# Fase {XX}: [Feature] - Database

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
| **Nome** | [Feature] - Database |
| **Feature** | [Nome Feature] |
| **Durata stimata** | X giorni |
| **Dipende da** | Fase {YY} |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-[feature]-database` |
| **Assegnato** | Claude Code |

## Obiettivo

Creare lo schema database per la feature [nome], mantenendo compatibilità con il database esistente.

## Pre-requisiti

Prima di iniziare, verifica che:

- [ ] Fase {YY} completata e mergiata
- [ ] Branch `develop` aggiornato
- [ ] Database locale sincronizzato
- [ ] Letto `docs/features/[feature]/legacy-compatibility.md`

---

## Task List

### Migrations

- [ ] `TASK-{XX}-001` **Creare migration tabella [entity]**
  - **File:** `database/migrations/{timestamp}_create_[entity]_table.php`
  - **Schema:** Vedi `docs/features/[feature]/database-schema.md`
  - **Note legacy:** [Note da legacy-compatibility.md]
  - **Acceptance criteria:**
    - [ ] Migration creata con tutti i campi
    - [ ] Indici configurati
    - [ ] Foreign keys definite
    - [ ] Compatibilità legacy verificata

- [ ] `TASK-{XX}-002` **Creare migration relazioni**
  - **File:** `database/migrations/{timestamp}_create_[pivot]_table.php`
  - **Descrizione:** Pivot table per relazione N:M
  - **Acceptance criteria:**
    - [ ] Pivot table creata
    - [ ] FK verso entrambe le tabelle

### Models

- [ ] `TASK-{XX}-010` **Creare model [Entity]**
  - **File:** `app/Models/[Entity].php`
  - **Pattern:** Seguire `docs/features/[feature]/patterns-conventions.md`
  - **Acceptance criteria:**
    - [ ] Model creato con fillable/casts
    - [ ] Relazioni definite
    - [ ] Scopes se necessari

### Seeders (opzionale)

- [ ] `TASK-{XX}-020` **Creare seeder dati test**
  - **File:** `database/seeders/[Entity]Seeder.php`
  - **Acceptance criteria:**
    - [ ] Seeder funzionante
    - [ ] Dati coerenti con schema

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Migrations | `php artisan migrate:fresh --seed` | Si | |
| Unit Tests | `php artisan test --testsuite=Unit` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |

---

## Note Compatibilità

### Da legacy-compatibility.md
[Inserire note rilevanti per questa fase]

### Mapping Campi Legacy
| Campo Legacy | Campo Nuovo | Trasformazione |
|--------------|-------------|----------------|
| [campo] | [campo] | [trasformazione] |

---

## Finalizzazione

- [ ] Aggiorna questo file (segna [x] tutti i task)
- [ ] Commit: `feat(fase-{XX}): [feature] database schema`
- [ ] Push: `git push origin feature/fase-{XX}-[feature]-database`

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```
```

### todo_fase_XX_feature_backend.md

```markdown
# Fase {XX}: [Feature] - Backend

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | [Feature] - Backend |
| **Feature** | [Nome Feature] |
| **Dipende da** | Fase {YY} (Database) |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-[feature]-backend` |

## Obiettivo

Implementare la logica di business per [feature], seguendo i pattern esistenti nel codebase.

## Pre-requisiti

- [ ] Fase {YY} ([feature] database) completata
- [ ] Letto `docs/features/[feature]/patterns-conventions.md`
- [ ] Letto `docs/features/[feature]/integration-points.md`

---

## Task List

### Actions/Services

- [ ] `TASK-{XX}-001` **Creare Create[Entity]Action**
  - **File:** `app/Actions/[Feature]/Create[Entity]Action.php`
  - **Pattern:** Action pattern (vedi patterns-conventions.md)
  - **Acceptance criteria:**
    - [ ] Action creata
    - [ ] Validazione input
    - [ ] Eventi dispatchati se necessario

- [ ] `TASK-{XX}-002` **Creare Update[Entity]Action**
  - **File:** `app/Actions/[Feature]/Update[Entity]Action.php`
  - **Acceptance criteria:**
    - [ ] Action creata
    - [ ] Gestione autorizzazioni

- [ ] `TASK-{XX}-003` **Creare Delete[Entity]Action**
  - **File:** `app/Actions/[Feature]/Delete[Entity]Action.php`
  - **Acceptance criteria:**
    - [ ] Soft delete se richiesto
    - [ ] Gestione dipendenze

### Policies

- [ ] `TASK-{XX}-010` **Creare [Entity]Policy**
  - **File:** `app/Policies/[Entity]Policy.php`
  - **Acceptance criteria:**
    - [ ] Policy registrata
    - [ ] Metodi: view, create, update, delete

### Events/Listeners (se necessari)

- [ ] `TASK-{XX}-020` **Creare [Entity]CreatedEvent**
  - **File:** `app/Events/[Entity]CreatedEvent.php`
  - **Listener:** [Descrizione]

### Tests

- [ ] `TASK-{XX}-030` **Unit test per Actions**
  - **File:** `tests/Unit/Actions/[Feature]/`
  - **Acceptance criteria:**
    - [ ] Test per ogni action
    - [ ] Edge cases coperti

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Unit Tests | `php artisan test --testsuite=Unit --filter=[Feature]` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```
```

### todo_fase_XX_feature_api.md

```markdown
# Fase {XX}: [Feature] - API

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | [Feature] - API |
| **Feature** | [Nome Feature] |
| **Dipende da** | Fase {YY} (Backend) |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-[feature]-api` |

## Obiettivo

Esporre API REST per [feature], coerenti con le API esistenti.

## Pre-requisiti

- [ ] Fase {YY} ([feature] backend) completata
- [ ] Letto `docs/features/[feature]/api-existing.md`

---

## Task List

### Controllers

- [ ] `TASK-{XX}-001` **Creare [Entity]Controller**
  - **File:** `app/Http/Controllers/Api/[Entity]Controller.php`
  - **Metodi:** index, show, store, update, destroy
  - **Acceptance criteria:**
    - [ ] Tutti i metodi CRUD
    - [ ] Autorizzazione via Policy
    - [ ] Response format coerente

### Form Requests

- [ ] `TASK-{XX}-010` **Creare Store[Entity]Request**
  - **File:** `app/Http/Requests/[Feature]/Store[Entity]Request.php`
  - **Validazione:** [regole]

- [ ] `TASK-{XX}-011` **Creare Update[Entity]Request**
  - **File:** `app/Http/Requests/[Feature]/Update[Entity]Request.php`

### API Resources

- [ ] `TASK-{XX}-020` **Creare [Entity]Resource**
  - **File:** `app/Http/Resources/[Entity]Resource.php`
  - **Formato:** Coerente con api-existing.md

### Routes

- [ ] `TASK-{XX}-030` **Aggiungere routes API**
  - **File:** `routes/api.php`
  - **Endpoints:** Vedi feature-requirements.md
  - **Acceptance criteria:**
    - [ ] Routes registrate
    - [ ] Middleware corretto
    - [ ] Rate limiting se necessario

### Tests

- [ ] `TASK-{XX}-040` **Feature test endpoints**
  - **File:** `tests/Feature/Api/[Entity]Test.php`
  - **Acceptance criteria:**
    - [ ] Test per ogni endpoint
    - [ ] Test autorizzazioni
    - [ ] Test validazione

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Feature Tests | `php artisan test --testsuite=Feature --filter=[Entity]` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```
```

### todo_fase_XX_feature_frontend.md

```markdown
# Fase {XX}: [Feature] - Frontend

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | [Feature] - Frontend |
| **Feature** | [Nome Feature] |
| **Dipende da** | Fase {YY} (API) |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-[feature]-frontend` |

## Obiettivo

Implementare l'interfaccia utente per [feature].

## Pre-requisiti

- [ ] Fase {YY} ([feature] API) completata
- [ ] Letto `docs/features/[feature]/codebase-analysis.md` (sezione frontend)

---

## Task List

### [Filament/Livewire/Vue - a seconda del codebase]

- [ ] `TASK-{XX}-001` **Creare Resource Filament** (se Filament)
  - **File:** `app/Filament/Resources/[Entity]Resource.php`
  - **Pages:** List, Create, Edit, View
  - **Acceptance criteria:**
    - [ ] Resource completa
    - [ ] Form con validazione
    - [ ] Table con filtri

OPPURE

- [ ] `TASK-{XX}-001` **Creare componente Livewire** (se Livewire)
  - **File:** `app/Livewire/[Feature]/[Entity]List.php`
  - **View:** `resources/views/livewire/[feature]/`
  - **Acceptance criteria:**
    - [ ] Componente funzionante
    - [ ] Paginazione
    - [ ] Filtri

OPPURE

- [ ] `TASK-{XX}-001` **Creare componente Vue** (se Vue)
  - **File:** `resources/js/components/[Feature]/`
  - **Acceptance criteria:**
    - [ ] Componenti creati
    - [ ] Integrazione API
    - [ ] State management

### Navigation

- [ ] `TASK-{XX}-010` **Aggiungere voce menu**
  - **File:** [Dipende dal setup]
  - **Acceptance criteria:**
    - [ ] Voce menu visibile
    - [ ] Permessi rispettati

### Tests (se browser testing)

- [ ] `TASK-{XX}-020` **Browser test**
  - **File:** `tests/Browser/[Feature]/`
  - **Acceptance criteria:**
    - [ ] Flussi principali testati

---

## Quality Gates

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Tests | `php artisan test` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```
```

### todo_fase_XX_feature_testing.md

```markdown
# Fase {XX}: [Feature] - Testing & QA

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | [Feature] - Testing & QA |
| **Feature** | [Nome Feature] |
| **Dipende da** | Fase {YY} (Frontend) |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-[feature]-testing` |

## Obiettivo

Completare la suite di test e verificare la qualità dell'implementazione.

---

## Task List

### Test Coverage

- [ ] `TASK-{XX}-001` **Verificare coverage**
  - **Comando:** `php artisan test --coverage`
  - **Target:** > 80%
  - **Acceptance criteria:**
    - [ ] Coverage raggiunto
    - [ ] Aree critiche coperte

### Integration Tests

- [ ] `TASK-{XX}-010` **Test integrazione completo**
  - **File:** `tests/Feature/Integration/[Feature]IntegrationTest.php`
  - **Descrizione:** Test end-to-end del flusso [feature]
  - **Acceptance criteria:**
    - [ ] Flusso completo testato
    - [ ] Edge cases coperti

### Legacy Compatibility Tests

- [ ] `TASK-{XX}-020` **Test compatibilità legacy**
  - **Descrizione:** Verificare che [feature] non rompa funzionalità esistenti
  - **Acceptance criteria:**
    - [ ] API legacy funzionanti
    - [ ] Dati legacy accessibili
    - [ ] Nessuna regressione

### Documentation

- [ ] `TASK-{XX}-030` **Aggiornare documentazione**
  - **File:** `docs/features/[feature]/README.md`
  - **Acceptance criteria:**
    - [ ] Usage documentato
    - [ ] API documentata
    - [ ] Changelog aggiornato

---

## Quality Gates Finali

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| All Tests | `php artisan test` | Si | |
| Coverage | `php artisan test --coverage --min=80` | Si | |
| Pint | `./vendor/bin/pint --test` | Si | |
| PHPStan | `./vendor/bin/phpstan analyse` | Si | |
| Security | `composer audit` | Si | |

---

## Checklist Finale

- [ ] Tutti i test passano
- [ ] Code coverage > 80%
- [ ] Nessun errore PHPStan
- [ ] Documentazione completa
- [ ] Compatibilità legacy verificata
- [ ] PR creata verso develop

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```
```

---

## Output Finale

```markdown
## Feature Roadmap Generata

### Feature
**[Nome Feature]**

### Fasi Aggiunte alla Roadmap
| Fase | File | Nome | Status |
|------|------|------|--------|
| {XX} | todo_fase_{XX}_[feature]_db.md | Database | TODO |
| {XX+1} | todo_fase_{XX+1}_[feature]_backend.md | Backend | TODO |
| {XX+2} | todo_fase_{XX+2}_[feature]_api.md | API | TODO |
| {XX+3} | todo_fase_{XX+3}_[feature]_frontend.md | Frontend | TODO |
| {XX+4} | todo_fase_{XX+4}_[feature]_testing.md | Testing | TODO |

### File Aggiornati
- [x] docs/roadmap/ROADMAP.md (aggiornato)
- [x] docs/roadmap/todo_fase_{XX}_*.md (X file creati)

### Task Totali
| Fase | Task |
|------|------|
| Database | X |
| Backend | X |
| API | X |
| Frontend | X |
| Testing | X |
| **Totale** | **X** |

### Prossimi Passi
1. Revisiona i todo files generati
2. Inizia implementazione: `"Esegui la fase {XX} del progetto"`
```

---

## Integrazione

```
feature-analyzer
       │
       └── docs/features/[name]/*.md (8 file)
                    │
                    ▼
       feature-roadmap-generator (questa skill)
                    │
                    ├── Aggiorna ROADMAP.md
                    └── Crea todo_fase_XX_*.md (5 file per feature)
                                │
                                ▼
                    ferlo-phase-executor
                                │
                                └── Esegue le fasi
```

---

*Skill per EXTRAWEB - v1.0.0*
