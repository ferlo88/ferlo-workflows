---
name: roadmap
description: Genera roadmap e file todo_fase_XX.md compatibili con phase-executor
---

# /roadmap - Genera Piano di Implementazione

Trasforma la documentazione di una feature in file `todo_fase_XX_nome.md` direttamente eseguibili con phase-executor.

## Uso

```bash
/roadmap quotes                    # Da docs/features/quotes/
/roadmap docs/features/invoices    # Path esplicito
/roadmap --stack=filament          # Con stack specifico
/roadmap --detail=high             # Dettaglio alto (più task)
```

## Prerequisiti

Deve esistere la documentazione feature generata da `/extract`:

```
docs/features/[feature-name]/
├── FEATURE-OVERVIEW.md      # Obbligatorio
├── DATABASE-SCHEMA.md
├── BACKEND-LOGIC.md
├── FRONTEND-UI.md
└── ...
```

## Output Generato

```
docs/roadmap/
├── ROADMAP.md                      # Overview fasi e dipendenze
├── todo_fase_00_setup.md           # Setup iniziale
├── todo_fase_01_database.md        # Schema e migrazioni
├── todo_fase_02_backend.md         # Modelli e logica
├── todo_fase_03_frontend.md        # UI e componenti
├── todo_fase_04_api.md             # Endpoints (se presenti)
├── todo_fase_05_migration.md       # Legacy data (se presente)
└── todo_fase_06_testing.md         # Testing strategy
```

**IMPORTANTE**: I file generati sono compatibili con `ferlo-laravel-phase-executor`.

## Workflow

### Step 1: Identifica Sorgente

1. Chiedi la **directory** della documentazione feature
2. Verifica che esista `FEATURE-OVERVIEW.md`
3. Elenca i file disponibili

### Step 2: Raccogli Preferenze

Chiedi all'utente:

1. **Stack target**: Laravel vanilla / Filament / Livewire / Vue / React
2. **Livello dettaglio**:
   - Alto (ogni campo, ogni metodo) → più TASK
   - Medio (per componente) → bilanciato
   - Basso (solo macro-task) → meno TASK
3. **Include stime?**: Sì/No
4. **Tipi test**: Unit / Feature / Browser / Tutti / Nessuno

### Step 3: Genera File

Per ogni fase, crea file `todo_fase_XX_nome.md` con:

1. **Metadata**: ID, Nome, Branch, Dipendenze, Status
2. **Obiettivo**: 2-3 righe descrittive
3. **Pre-requisiti**: Checkbox verificabili
4. **Task List**: Con ID `TASK-XX-NNN` e acceptance criteria
5. **Quality Gates**: Tabella con comandi
6. **Finalizzazione**: Commit e push
7. **Progress**: Contatore task

### Step 4: Genera ROADMAP.md

1. Tabella fasi con file, dipendenze, priorità
2. Diagramma dipendenze ASCII
3. Istruzioni quick start

## Formato Task (obbligatorio)

```markdown
- [ ] `TASK-01-001` **Creare migration users**
  - **File:** `database/migrations/xxx_create_users_table.php`
  - **Descrizione:** Definire schema tabella utenti
  - **Acceptance criteria:**
    - [ ] Migration creata con tutti i campi
    - [ ] Indici configurati
    - [ ] Foreign keys definite
```

## Esempio Completo

```bash
# 1. Estrai feature da progetto esistente
/extract Quote

# 2. Genera roadmap per implementazione
/roadmap quotes --stack=filament

# Output:
# ✓ Letti 5 file sorgente
# ✓ Generate 7 fasi (todo_fase_00 → todo_fase_06)
# ✓ Creati 45 TASK totali
#
# File generati:
# - docs/roadmap/ROADMAP.md
# - docs/roadmap/todo_fase_00_setup.md
# - docs/roadmap/todo_fase_01_database.md
# - docs/roadmap/todo_fase_02_backend.md
# - docs/roadmap/todo_fase_03_frontend.md
# - docs/roadmap/todo_fase_06_testing.md
#
# Prossimi passi:
# 1. "Esegui la fase 00 del progetto"
# 2. Oppure leggi docs/roadmap/ROADMAP.md

# 3. Esegui fase con phase-executor
"Esegui la fase 01 del progetto"
```

## Opzioni

| Flag | Descrizione | Default |
|------|-------------|---------|
| `--stack=` | Stack target (laravel, filament, livewire, vue) | laravel |
| `--detail=` | Livello dettaglio (high, medium, low) | medium |
| `--estimates` | Include stime temporali | false |
| `--tests=` | Tipi test (unit, feature, browser, all, none) | all |

## Integrazione Workflow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  /extract       │ ──▶ │  /roadmap        │ ──▶ │  phase-executor │
│  (documenta)    │     │  (pianifica)     │     │  (esegue)       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                        │
         ▼                       ▼                        ▼
   docs/features/          docs/roadmap/            Codice finale
   FEATURE-OVERVIEW.md     todo_fase_XX.md          + Test + Commit
```

## Convenzioni Naming

- **File**: `todo_fase_XX_nome.md` (lowercase, underscore)
- **Task ID**: `TASK-XX-NNN` (es. TASK-01-001, TASK-01-002, TASK-01-010)
- **Branch**: `feature/fase-XX-nome`
- **Commit**: `feat(fase-XX): TASK-XX-NNN - descrizione`

## Post-Generazione

Dopo aver generato la roadmap, puoi:

1. **Esecuzione manuale**: Leggi ogni `todo_fase_XX.md` e implementa
2. **Esecuzione automatica**: `"Esegui la fase 01 del progetto"`

Il phase-executor gestirà:
- Creazione branch
- Esecuzione task in ordine
- Quality gates
- Commit atomici
- Report finale
