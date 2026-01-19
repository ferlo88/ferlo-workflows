---
name: ferlo-new-project-completo
description: This skill provides the complete 10-step AI-first workflow from client call to development-ready documentation. Use when user asks for "complete project setup", "full workflow", "from client call to code", "AI-first methodology", or "10 step workflow".
version: 1.0.0
---

# Workflow Completo AI-First (10 Step)

Trasforma le note di una chiamata cliente in documentazione completa per lo sviluppo.

## Overview

| Step | Output | Tool |
|------|--------|------|
| 1 | 00_kickoff.md | ChatGPT |
| 2 | 01_user_stories.md | ChatGPT |
| 3 | 02_requisiti_funzionali.md | Gemini |
| 4 | 03_requisiti_non_funzionali.md | Gemini |
| 5 | 04_scope.md | Gemini |
| 6 | 05_data_model.md | Claude |
| 7 | 06_api_contract.md | Claude |
| 8 | 07_architecture.md | Claude |
| 9 | ROADMAP.md | Claude |
| 10 | todo_fase_XX.md | Claude |

## Step 1-5: Discovery Phase

### Step 1: Kickoff Document
Input: Note chiamata cliente
Output: Documento strutturato con obiettivi, stakeholder, vincoli

### Step 2: User Stories
Input: Kickoff document
Output: Epic e user stories in formato "As a... I want... So that..."

### Step 3: Requisiti Funzionali
Input: User stories
Output: Lista requisiti con ID, priorità, criteri accettazione

### Step 4: Requisiti Non Funzionali
Input: Contesto progetto
Output: Performance, sicurezza, scalabilità, manutenibilità

### Step 5: Scope & Boundaries
Input: Tutti i documenti precedenti
Output: In scope, out of scope, assunzioni, dipendenze

## Step 6-10: Design Phase

### Step 6: Data Model
```markdown
## Entità

### User
| Campo | Tipo | Note |
|-------|------|------|
| id | UUID | PK |
| email | string | unique |
| name | string | |

### Relazioni
- User hasMany Orders
- Order belongsTo User
```

### Step 7: API Contract
```markdown
## Endpoints

### POST /api/orders
**Request:**
{
  "product_id": "uuid",
  "quantity": 1
}

**Response 201:**
{
  "id": "uuid",
  "status": "pending"
}
```

### Step 8: Architecture
- Component diagram
- Sequence diagram per flussi chiave
- Decisioni architetturali (ADR)

### Step 9: Roadmap
```markdown
## Fasi

### Fase 1: Foundation (2 settimane)
- Setup progetto
- Autenticazione
- CRUD base

### Fase 2: Core Features (3 settimane)
- Feature principale 1
- Feature principale 2

### Fase 3: Polish (1 settimana)
- Testing
- Documentazione
- Deploy
```

### Step 10: TODO per Fase
Per ogni fase, genera:
```markdown
# TODO Fase 1: Foundation

## Backend
- [ ] Setup Laravel
- [ ] Configurare database
- [ ] Implementare auth

## Frontend
- [ ] Setup Vue/React
- [ ] Componenti base

## DevOps
- [ ] Docker setup
- [ ] CI/CD pipeline
```

## Output Directory

```
docs/
├── 00_kickoff.md
├── 01_user_stories.md
├── 02_requisiti_funzionali.md
├── 03_requisiti_non_funzionali.md
├── 04_scope.md
├── 05_data_model.md
├── 06_api_contract.md
├── 07_architecture.md
└── roadmap/
    ├── ROADMAP.md
    ├── todo_fase_01.md
    ├── todo_fase_02.md
    └── todo_fase_03.md
```
