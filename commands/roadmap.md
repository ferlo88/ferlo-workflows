---
name: roadmap
description: Genera roadmap e TODO da documentazione feature estratta
---

# /roadmap - Genera Piano di Implementazione

Trasforma la documentazione di una feature in un piano di lavoro strutturato.

## Uso

```bash
/roadmap quotes                    # Da docs/features/quotes/
/roadmap docs/features/invoices    # Path esplicito
/roadmap --stack=filament          # Con stack specifico
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

## Workflow

### Step 1: Identifica Sorgente

1. Chiedi la **directory** della documentazione feature
2. Verifica che esista `FEATURE-OVERVIEW.md`
3. Elenca i file disponibili

### Step 2: Raccogli Preferenze

Chiedi all'utente:

1. **Stack target**: Laravel vanilla / Filament / Livewire / Vue / React
2. **Livello dettaglio**:
   - Alto (ogni campo, ogni metodo)
   - Medio (per componente)
   - Basso (solo macro-task)
3. **Include stime?**: Sì/No
4. **Tipi test**: Unit / Feature / Browser / Tutti / Nessuno

### Step 3: Genera Roadmap

Leggi ogni file MD sorgente e genera:

```
docs/roadmap/[feature-name]/
├── ROADMAP.md               # Overview fasi e dipendenze
├── FASE-00-SETUP.md         # Preparazione ambiente
├── FASE-01-DATABASE.md      # Schema e migrations
├── FASE-02-BACKEND.md       # Models, services, controllers
├── FASE-03-FRONTEND.md      # Views, components
├── FASE-04-API.md           # REST endpoints (se presenti)
├── FASE-05-MIGRATION.md     # Legacy data (se presente)
├── FASE-06-TEST.md          # Testing strategy
└── TODO.md                  # Checklist completa
```

### Step 4: Output

Mostra riepilogo:
- Fasi generate
- TODO totali
- Dipendenze identificate
- Suggerimenti per iniziare

## Esempio Completo

```bash
# 1. Estrai feature da progetto esistente
/extract Quote

# 2. Genera roadmap per implementazione
/roadmap quotes --stack=filament

# Output:
# ✓ Letti 5 file sorgente
# ✓ Generate 7 fasi
# ✓ Creati 45 TODO
#
# Prossimi passi:
# 1. Leggi docs/roadmap/quotes/ROADMAP.md
# 2. Inizia da FASE-00-SETUP.md
# 3. Usa TODO.md come checklist
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
│  /extract       │ ──▶ │  /roadmap        │ ──▶ │  Implementa     │
│  (documenta)    │     │  (pianifica)     │     │  (sviluppa)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                        │
         ▼                       ▼                        ▼
   docs/features/          docs/roadmap/            Codice finale
```
