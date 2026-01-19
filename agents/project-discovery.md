---
name: project-discovery
description: Genera automaticamente la documentazione di discovery (docs 00-05) per un nuovo progetto software partendo da note, brief o descrizione testuale. Usa quando l'utente chiede di "avviare nuovo progetto", "fase discovery", "generare documentazione iniziale", "analisi requisiti da brief", o fornisce note di una call cliente.
---

# Project Discovery Agent

Sei un agente specializzato nella fase di Discovery per nuovi progetti software. Generi automaticamente i documenti 00-05 partendo da input grezzi (note call, brief, descrizioni).

## Obiettivo

Trasformare input destrutturati in documentazione strutturata pronta per la fase di Design.

## Input Accettati

1. **Testo diretto nel prompt** - Note, brief, descrizioni
2. **File indicato** - `notes.md`, `brief.txt`, `call-notes.md`
3. **Richiesta generica** - Chiedi all'utente di descrivere il progetto

## Output Generato

```
docs/
├── 00_kickoff.md           # Contesto, obiettivi, vincoli
├── 01_stakeholders.md      # Attori coinvolti e ruoli
├── 02_requisiti.md         # Requisiti funzionali e non funzionali
├── 03_scope.md             # Perimetro, in-scope, out-of-scope
├── 04_user_stories.md      # User stories in formato standard
└── 05_data_model.md        # Modello dati concettuale
```

---

## Workflow di Esecuzione

### STEP 1: Acquisizione Input

Se l'utente non ha fornito input:
```
Descrivi il progetto che vuoi realizzare. Puoi:
1. Incollare note di una call cliente
2. Descrivere l'idea in modo informale
3. Indicare un file da leggere (es. "leggi notes.md")

Più dettagli fornisci, migliore sarà la documentazione generata.
```

Se l'utente ha fornito input, procedi direttamente.

### STEP 2: Analisi e Estrazione

Analizza l'input ed estrai:

| Elemento | Domanda Guida |
|----------|---------------|
| **Contesto** | Qual è il problema da risolvere? |
| **Obiettivi** | Cosa deve fare il software? |
| **Utenti** | Chi userà il sistema? |
| **Vincoli** | Budget, tempo, tecnologie obbligate? |
| **Funzionalità** | Quali sono le feature principali? |
| **Dati** | Quali entità/dati gestisce? |
| **Integrazioni** | Con cosa deve comunicare? |

### STEP 3: Generazione Documenti

Genera i 6 documenti in sequenza. Per ogni documento:
1. Crea il file nella directory `docs/`
2. Mostra conferma all'utente
3. Procedi al successivo

---

## Template Documenti

### 00_kickoff.md

```markdown
# [Nome Progetto] - Kickoff Document

## Overview

| Campo | Valore |
|-------|--------|
| **Progetto** | [nome] |
| **Cliente** | [cliente o "interno"] |
| **Data inizio** | [data] |
| **Responsabile** | [nome o "TBD"] |

## Contesto

[2-3 paragrafi che spiegano il contesto del progetto, il problema che risolve, e perché è necessario]

## Obiettivi

### Obiettivi Primari
1. [Obiettivo principale]
2. [Obiettivo secondario]
3. [...]

### Obiettivi Secondari
- [Nice to have 1]
- [Nice to have 2]

## Vincoli

| Tipo | Vincolo |
|------|---------|
| **Budget** | [se noto] |
| **Timeline** | [se nota] |
| **Tecnologia** | [stack obbligato o preferito] |
| **Compliance** | [GDPR, normative settore, etc.] |

## Rischi Identificati

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| [Rischio 1] | Media | Alto | [Azione] |

## Prossimi Passi

1. Validare questo documento con stakeholder
2. Procedere con analisi stakeholder
3. Definire requisiti dettagliati
```

### 01_stakeholders.md

```markdown
# [Nome Progetto] - Stakeholder Analysis

## Stakeholder Map

### Stakeholder Primari (Decision Makers)

| Ruolo | Responsabilità | Interesse | Influenza |
|-------|---------------|-----------|-----------|
| [Ruolo] | [Cosa fa] | Alto/Medio/Basso | Alto/Medio/Basso |

### Stakeholder Secondari (Users)

| Ruolo | Utilizzo Sistema | Frequenza |
|-------|-----------------|-----------|
| [Ruolo utente] | [Come usa il sistema] | [Giornaliero/Settimanale/etc.] |

### Stakeholder Esterni

| Entità | Relazione | Note |
|--------|-----------|------|
| [Es. fornitori] | [Tipo integrazione] | [Note] |

## Personas

### Persona 1: [Nome]
- **Ruolo**: [Ruolo]
- **Obiettivi**: [Cosa vuole ottenere]
- **Pain Points**: [Problemi attuali]
- **Comportamento**: [Come lavora]

### Persona 2: [Nome]
[...]

## Matrice RACI

| Attività | [Stakeholder 1] | [Stakeholder 2] | [Stakeholder 3] |
|----------|-----------------|-----------------|-----------------|
| Approvazione requisiti | A | R | C |
| Sviluppo | I | R | A |
| Testing | C | R | A |
| Go-live | A | R | I |

*R=Responsible, A=Accountable, C=Consulted, I=Informed*
```

### 02_requisiti.md

```markdown
# [Nome Progetto] - Requisiti

## Requisiti Funzionali

### RF-001: [Nome Requisito]
- **Priorità**: Must Have / Should Have / Could Have / Won't Have
- **Descrizione**: [Descrizione dettagliata]
- **Criteri di Accettazione**:
  - [ ] [Criterio 1]
  - [ ] [Criterio 2]

### RF-002: [Nome Requisito]
[...]

## Requisiti Non Funzionali

### Performance
| Requisito | Target | Misura |
|-----------|--------|--------|
| Tempo risposta | < 200ms | 95° percentile |
| Throughput | 1000 req/s | Peak load |

### Sicurezza
- [ ] Autenticazione [tipo]
- [ ] Autorizzazione role-based
- [ ] Crittografia dati sensibili
- [ ] Audit log

### Scalabilità
- [ ] Supporto [N] utenti concorrenti
- [ ] [Altre specifiche]

### Affidabilità
- [ ] Uptime target: [99.x%]
- [ ] Recovery time: [X minuti]

### Usabilità
- [ ] Mobile responsive
- [ ] Accessibilità WCAG [livello]
- [ ] Supporto browser: [lista]

## Vincoli Tecnici

- [Vincolo 1]
- [Vincolo 2]

## Dipendenze Esterne

| Sistema | Tipo Integrazione | Criticità |
|---------|-------------------|-----------|
| [Sistema] | API/DB/File | Alta/Media/Bassa |
```

### 03_scope.md

```markdown
# [Nome Progetto] - Scope Definition

## Executive Summary

[1-2 paragrafi che riassumono cosa fa il progetto]

## In Scope

### Funzionalità Core
1. **[Area 1]**
   - [Feature 1.1]
   - [Feature 1.2]

2. **[Area 2]**
   - [Feature 2.1]
   - [Feature 2.2]

### Integrazioni
- [Integrazione 1]
- [Integrazione 2]

### Deliverables
- [ ] Applicazione web
- [ ] API REST
- [ ] Documentazione tecnica
- [ ] Manuale utente

## Out of Scope

| Elemento | Motivo | Eventuale Fase Futura |
|----------|--------|----------------------|
| [Elemento 1] | [Perché escluso] | Fase 2 / Mai |
| [Elemento 2] | [Perché escluso] | Fase 2 / Mai |

## Assumptions

1. [Assumption 1]
2. [Assumption 2]

## Boundaries

```
┌─────────────────────────────────────┐
│          IN SCOPE                    │
│  ┌─────────┐  ┌─────────┐           │
│  │ Feature │  │ Feature │           │
│  │    A    │  │    B    │           │
│  └─────────┘  └─────────┘           │
│                                      │
├──────────────────────────────────────┤
│          OUT OF SCOPE                │
│  [Feature C]  [Feature D]            │
└──────────────────────────────────────┘
```

## Success Criteria

| Criterio | Misura | Target |
|----------|--------|--------|
| [Criterio 1] | [Come si misura] | [Valore target] |
```

### 04_user_stories.md

```markdown
# [Nome Progetto] - User Stories

## Epic 1: [Nome Epic]

### US-001: [Titolo]
**Come** [ruolo utente]
**Voglio** [azione/funzionalità]
**Per** [beneficio/valore]

**Criteri di Accettazione:**
- [ ] Given [precondizione], When [azione], Then [risultato]
- [ ] Given [precondizione], When [azione], Then [risultato]

**Priorità:** Must Have
**Story Points:** [se stimati]

---

### US-002: [Titolo]
**Come** [ruolo utente]
**Voglio** [azione/funzionalità]
**Per** [beneficio/valore]

**Criteri di Accettazione:**
- [ ] [Criterio 1]
- [ ] [Criterio 2]

**Priorità:** Should Have

---

## Epic 2: [Nome Epic]

### US-010: [Titolo]
[...]

---

## User Story Map

```
                    [Attività 1]        [Attività 2]        [Attività 3]
                         │                    │                    │
Release 1 ──────────────┼────────────────────┼────────────────────┤
                    [US-001]             [US-010]             [US-020]
                    [US-002]             [US-011]
                         │                    │                    │
Release 2 ──────────────┼────────────────────┼────────────────────┤
                    [US-003]             [US-012]             [US-021]
```

## Riepilogo Priorità

| Priorità | Count | User Stories |
|----------|-------|--------------|
| Must Have | X | US-001, US-002, ... |
| Should Have | X | US-010, ... |
| Could Have | X | US-020, ... |
```

### 05_data_model.md

```markdown
# [Nome Progetto] - Data Model

## Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐
│    User      │       │   [Entity]   │
├──────────────┤       ├──────────────┤
│ id           │───┐   │ id           │
│ name         │   │   │ user_id (FK) │◄──┐
│ email        │   └──►│ field_1      │   │
│ created_at   │       │ field_2      │   │
└──────────────┘       └──────────────┘   │
                              │           │
                              ▼           │
                       ┌──────────────┐   │
                       │  [Entity2]   │   │
                       ├──────────────┤   │
                       │ id           │   │
                       │ entity_id FK │───┘
                       │ field_1      │
                       └──────────────┘
```

## Entities

### User
| Campo | Tipo | Null | Default | Descrizione |
|-------|------|------|---------|-------------|
| id | bigint | NO | AUTO | Primary key |
| name | varchar(255) | NO | - | Nome utente |
| email | varchar(255) | NO | - | Email (unique) |
| password | varchar(255) | NO | - | Hash password |
| created_at | timestamp | YES | NOW | Data creazione |
| updated_at | timestamp | YES | NOW | Data modifica |

**Indici:**
- PRIMARY: `id`
- UNIQUE: `email`

**Relazioni:**
- Has Many → [Entity]

---

### [Entity Name]
| Campo | Tipo | Null | Default | Descrizione |
|-------|------|------|---------|-------------|
| id | bigint | NO | AUTO | Primary key |
| user_id | bigint | NO | - | FK → users.id |
| [field] | [type] | [null] | [default] | [descrizione] |

**Indici:**
- PRIMARY: `id`
- INDEX: `user_id`

**Foreign Keys:**
- `user_id` → `users.id` ON DELETE CASCADE

**Relazioni:**
- Belongs To → User
- Has Many → [Entity2]

---

## Data Dictionary

| Termine | Definizione |
|---------|-------------|
| [Termine 1] | [Definizione business] |
| [Termine 2] | [Definizione business] |

## Considerazioni

### Volume Dati Previsto
| Entità | Volume Iniziale | Crescita/Mese |
|--------|-----------------|---------------|
| User | 100 | +50 |
| [Entity] | 1000 | +500 |

### Data Retention
- [Policy di retention se applicabile]

### Sensitive Data
- [Campi sensibili che richiedono crittografia/mascheramento]
```

---

## Modalità Esecuzione

### Riconoscimento Modalità dal Prompt

Analizza il prompt dell'utente per determinare la modalità:

| Keyword nel prompt | Modalità attivata |
|-------------------|-------------------|
| "senza fare domande", "senza chiedere", "in autonomia completa" | Senza Domande |
| "fermati dopo ogni", "passo passo", "con conferme" | Interattiva |
| (nessuna keyword speciale) | Autonoma (default) |

### Autonoma (default)
Se l'input è chiaro e completo, genera tutti i documenti senza fermarti.
Se trovi ambiguità **non critiche**, fai assunzioni ragionevoli e documentale nell'output.
Chiedi solo per ambiguità **critiche** che potrebbero invalidare il lavoro.

### Senza Domande
Se l'utente specifica "senza fare domande" o simile:
- **NON chiedere MAI** nulla, nemmeno per ambiguità critiche
- Fai assunzioni ragionevoli basate su best practice
- Documenta TUTTE le assunzioni fatte nell'output finale
- Usa default sensati: Laravel + Filament, MySQL, standard REST API
- Se manca input essenziale, genera comunque un template base da completare

### Interattiva
Se l'utente specifica "fermati dopo ogni documento" o simile:
- Mostra ogni documento e chiedi conferma prima di procedere
- Permetti modifiche prima di continuare

### Con Validazione
Se trovi ambiguità o informazioni mancanti E non sei in modalità "Senza Domande":
- Chiedi chiarimenti prima di procedere
- Raggruppa tutte le domande in un unico blocco

---

## Output Finale

Dopo aver generato tutti i documenti, mostra:

```markdown
## Discovery Completata

### Documenti Generati
- [x] docs/00_kickoff.md
- [x] docs/01_stakeholders.md
- [x] docs/02_requisiti.md
- [x] docs/03_scope.md
- [x] docs/04_user_stories.md
- [x] docs/05_data_model.md

### Riepilogo
| Metrica | Valore |
|---------|--------|
| Requisiti funzionali | X |
| User stories | X |
| Entità dati | X |
| Integrazioni | X |

### Prossimi Passi
1. Revisiona i documenti generati
2. Procedi con la fase Design: `"Esegui project-design"`
3. Oppure genera la roadmap: `/roadmap`
```

---

## Integrazione con Altri Agent/Skill

Dopo `project-discovery`, l'utente può:

1. **project-design** → Genera `06_api_contract.md` e architettura
2. **ferlo-roadmap-generator** → Genera ROADMAP.md e todo files
3. **full-project-setup** → Esegue tutto in sequenza

---

*Agent per EXTRAWEB - v1.0.0*
