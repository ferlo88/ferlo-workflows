---
name: extract
description: Estrae e documenta una feature da un progetto esistente per replicarla altrove
---

# /extract - Feature Extraction

Analizza una funzionalità esistente e genera documentazione completa per replicarla.

## Uso

```
/extract Quote              # Analizza per nome modello
/extract "preventivo"       # Analizza per keyword
/extract Invoice --legacy   # Include migrazione dati legacy
```

## Workflow

### Step 1: Raccogli Informazioni

Chiedi all'utente:

1. **Cosa vuoi estrarre?**
   - Nome modello/entità (es. Quote, Invoice, Order)
   - OPPURE keyword da cercare

2. **Directory progetto** (se diversa da pwd)

3. **Ci sono dati legacy da migrare?**
   - Se sì, chiedi dettagli sul sistema legacy

4. **Includere entità correlate?**
   - Es. per "Quote" → includere "Customer", "Product"?

### Step 2: Analizza il Codebase

Usa l'agente `feature-extractor` per:

1. Cercare tutti i file correlati
2. Analizzare:
   - Database schema (migrations, modelli)
   - Backend logic (controllers, services, validation)
   - Frontend UI (views, components, forms)
   - API endpoints (se presenti)

### Step 3: Genera Documentazione

Crea in `docs/features/[nome-feature]/`:

| File | Contenuto |
|------|-----------|
| `FEATURE-OVERVIEW.md` | Descrizione funzionale completa |
| `DATABASE-SCHEMA.md` | Tabelle, relazioni, indici |
| `BACKEND-LOGIC.md` | Modelli, validazioni, business logic |
| `FRONTEND-UI.md` | Schermate, form, componenti |
| `API-ENDPOINTS.md` | REST API (se presente) |
| `DATA-MIGRATION.md` | Mapping legacy (se richiesto) |

### Step 4: Riepilogo

Mostra:
- Numero file analizzati
- Entità trovate
- File generati
- Suggerimenti per l'implementazione

## Esempio Output

```
docs/features/quotes/
├── FEATURE-OVERVIEW.md      # Cosa fa la feature
├── DATABASE-SCHEMA.md       # 3 tabelle, 5 relazioni
├── BACKEND-LOGIC.md         # 2 modelli, 15 validazioni
├── FRONTEND-UI.md           # 4 schermate, 12 campi form
├── API-ENDPOINTS.md         # 6 endpoints REST
└── DATA-MIGRATION.md        # Mapping da sistema legacy
```

## Note

- I file generati sono **agnostici** rispetto al framework
- Possono essere usati con `/roadmap` per pianificare l'implementazione
- Possono essere usati con qualsiasi stack target
