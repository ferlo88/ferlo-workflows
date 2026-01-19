---
name: project-design
description: Genera la documentazione di design tecnico (doc 06 API contract + architettura) partendo dai documenti di discovery (00-05). Usa quando l'utente chiede "fase design", "genera API contract", "architettura tecnica", "design sistema", o dopo aver completato project-discovery.
---

# Project Design Agent

Sei un agente specializzato nella fase di Design tecnico. Generi `06_api_contract.md` e documentazione architetturale partendo dai documenti di discovery.

## Obiettivo

Trasformare i requisiti e il data model in specifiche tecniche implementabili.

## Prerequisiti

Prima di eseguire, verifica che esistano i documenti di discovery:

```
docs/
├── 00_kickoff.md           # Obbligatorio
├── 01_stakeholders.md      # Opzionale
├── 02_requisiti.md         # Obbligatorio
├── 03_scope.md             # Obbligatorio
├── 04_user_stories.md      # Obbligatorio
└── 05_data_model.md        # Obbligatorio
```

Se mancano documenti obbligatori:
```
I seguenti documenti di discovery sono mancanti:
- [lista file mancanti]

Opzioni:
1. Esegui prima `project-discovery` per generarli
2. Fornisci le informazioni mancanti manualmente
```

## Output Generato

```
docs/
├── 06_api_contract.md      # Specifiche API OpenAPI-style
└── 07_architecture.md      # Architettura sistema (opzionale)
```

---

## Workflow di Esecuzione

### STEP 1: Lettura Documenti Discovery

Leggi e analizza tutti i documenti disponibili:

```bash
# Leggi tutti i docs
cat docs/00_kickoff.md
cat docs/02_requisiti.md
cat docs/03_scope.md
cat docs/04_user_stories.md
cat docs/05_data_model.md
```

Estrai:
- Entità dal data model
- Operazioni dalle user stories
- Vincoli dai requisiti
- Integrazioni dallo scope

### STEP 2: Mappatura Endpoints

Per ogni entità e user story, identifica gli endpoint necessari:

| User Story | Entità | Operazione | Endpoint |
|------------|--------|------------|----------|
| US-001 | User | Create | POST /api/users |
| US-002 | User | List | GET /api/users |
| ... | ... | ... | ... |

### STEP 3: Generazione API Contract

Genera `06_api_contract.md` seguendo il template.

### STEP 4: Generazione Architettura (opzionale)

Se il progetto è complesso (>10 endpoints, integrazioni esterne), genera anche `07_architecture.md`.

---

## Template Documenti

### 06_api_contract.md

```markdown
# [Nome Progetto] - API Contract

## Overview

| Campo | Valore |
|-------|--------|
| **Versione API** | v1 |
| **Base URL** | `/api/v1` |
| **Formato** | JSON |
| **Autenticazione** | Bearer Token / Sanctum / etc. |

## Autenticazione

### Tipo
[Descrizione del meccanismo di autenticazione]

### Headers Richiesti
```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

### Endpoints Auth

#### POST /api/auth/login
**Descrizione:** Autenticazione utente

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response 200:**
```json
{
  "token": "string",
  "user": {
    "id": "integer",
    "name": "string",
    "email": "string"
  },
  "expires_at": "datetime"
}
```

**Response 401:**
```json
{
  "message": "Invalid credentials"
}
```

---

## Resources

### [Resource Name]

Base path: `/api/v1/[resources]`

#### GET /api/v1/[resources]
**Descrizione:** Lista risorse con paginazione

**Query Parameters:**
| Param | Tipo | Required | Default | Descrizione |
|-------|------|----------|---------|-------------|
| page | integer | No | 1 | Pagina corrente |
| per_page | integer | No | 15 | Items per pagina |
| search | string | No | - | Ricerca testuale |
| sort | string | No | created_at | Campo ordinamento |
| order | string | No | desc | Direzione (asc/desc) |

**Response 200:**
```json
{
  "data": [
    {
      "id": "integer",
      "field_1": "string",
      "field_2": "integer",
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150
  },
  "links": {
    "first": "string",
    "last": "string",
    "prev": "string|null",
    "next": "string|null"
  }
}
```

---

#### GET /api/v1/[resources]/{id}
**Descrizione:** Dettaglio singola risorsa

**Path Parameters:**
| Param | Tipo | Descrizione |
|-------|------|-------------|
| id | integer | ID risorsa |

**Response 200:**
```json
{
  "data": {
    "id": "integer",
    "field_1": "string",
    "field_2": "integer",
    "relations": [...],
    "created_at": "datetime",
    "updated_at": "datetime"
  }
}
```

**Response 404:**
```json
{
  "message": "Resource not found"
}
```

---

#### POST /api/v1/[resources]
**Descrizione:** Crea nuova risorsa

**Request Body:**
```json
{
  "field_1": "string (required)",
  "field_2": "integer (optional)"
}
```

**Validation Rules:**
| Campo | Regole |
|-------|--------|
| field_1 | required, string, max:255 |
| field_2 | nullable, integer, min:0 |

**Response 201:**
```json
{
  "data": {
    "id": "integer",
    "field_1": "string",
    "field_2": "integer",
    "created_at": "datetime"
  },
  "message": "Resource created successfully"
}
```

**Response 422:**
```json
{
  "message": "Validation failed",
  "errors": {
    "field_1": ["The field_1 field is required."]
  }
}
```

---

#### PUT /api/v1/[resources]/{id}
**Descrizione:** Aggiorna risorsa esistente

**Request Body:**
```json
{
  "field_1": "string",
  "field_2": "integer"
}
```

**Response 200:**
```json
{
  "data": {...},
  "message": "Resource updated successfully"
}
```

---

#### DELETE /api/v1/[resources]/{id}
**Descrizione:** Elimina risorsa

**Response 200:**
```json
{
  "message": "Resource deleted successfully"
}
```

**Response 409:** (se ha dipendenze)
```json
{
  "message": "Cannot delete resource with dependencies"
}
```

---

## Error Handling

### Standard Error Response
```json
{
  "message": "string",
  "errors": {
    "field": ["error message"]
  },
  "code": "ERROR_CODE"
}
```

### HTTP Status Codes
| Code | Significato |
|------|-------------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Validation Error |
| 500 | Server Error |

---

## Rate Limiting

| Endpoint | Limite | Finestra |
|----------|--------|----------|
| Auth | 5 req | 1 min |
| API generale | 60 req | 1 min |

Headers di risposta:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1609459200
```

---

## Versioning

- Versione in URL: `/api/v1/...`
- Header deprecation: `Deprecation: true`
- Sunset header: `Sunset: Sat, 31 Dec 2025 23:59:59 GMT`

---

## Changelog

| Versione | Data | Modifiche |
|----------|------|-----------|
| v1.0.0 | [data] | Release iniziale |
```

### 07_architecture.md (opzionale)

```markdown
# [Nome Progetto] - Architettura Sistema

## Overview

[Descrizione ad alto livello dell'architettura]

## Stack Tecnologico

| Layer | Tecnologia | Versione |
|-------|------------|----------|
| Backend | Laravel | 11.x |
| Frontend | [Vue/Livewire/Filament] | X.x |
| Database | MySQL/PostgreSQL | X.x |
| Cache | Redis | X.x |
| Queue | Redis/SQS | - |

## Diagramma Architetturale

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │   Web    │  │  Mobile  │  │   API    │                   │
│  │  Browser │  │   App    │  │  Client  │                   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                   │
└───────┼─────────────┼─────────────┼─────────────────────────┘
        │             │             │
        └─────────────┼─────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    Laravel App                        │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐        │   │
│  │  │ Controllers│ │  Services  │ │   Actions  │        │   │
│  │  └────────────┘ └────────────┘ └────────────┘        │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐        │   │
│  │  │   Models   │ │  Policies  │ │   Events   │        │   │
│  │  └────────────┘ └────────────┘ └────────────┘        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│   Database   │ │   Cache  │ │    Queue     │
│  MySQL/PGSQL │ │   Redis  │ │    Jobs      │
└──────────────┘ └──────────┘ └──────────────┘
```

## Layer Application

### Directory Structure
```
app/
├── Actions/           # Single-purpose action classes
├── Http/
│   ├── Controllers/   # HTTP request handling
│   ├── Requests/      # Form validation
│   └── Resources/     # API transformers
├── Models/            # Eloquent models
├── Services/          # Business logic
├── Policies/          # Authorization
├── Events/            # Domain events
├── Listeners/         # Event handlers
└── Jobs/              # Queue jobs
```

### Design Patterns

| Pattern | Utilizzo |
|---------|----------|
| Action Pattern | Operazioni singole (CreateUserAction) |
| Service Layer | Logica business complessa |
| Repository | Se necessario per testing |
| Observer | Eventi model |
| Strategy | Logiche intercambiabili |

## Sicurezza

### Autenticazione
- [Laravel Sanctum / Passport / etc.]
- Token expiration: [durata]
- Refresh token: [sì/no]

### Autorizzazione
- Policy-based
- Ruoli: [lista ruoli]
- Permessi: [granularità]

### Data Protection
- Encryption at rest: [sì/no]
- Campi sensibili: [lista]
- GDPR compliance: [note]

## Scalabilità

### Horizontal Scaling
- Stateless application
- Session in Redis
- File storage esterno (S3)

### Caching Strategy
| Tipo | TTL | Invalidation |
|------|-----|--------------|
| Query cache | 1h | On update |
| Response cache | 5m | On mutation |
| Config cache | Deploy | Manual |

## Integrazioni Esterne

| Sistema | Tipo | Scopo |
|---------|------|-------|
| [Sistema 1] | REST API | [Scopo] |
| [Sistema 2] | Webhook | [Scopo] |

## Deployment

### Environments
| Ambiente | URL | Scopo |
|----------|-----|-------|
| Local | localhost | Sviluppo |
| Staging | staging.app.com | Test |
| Production | app.com | Live |

### CI/CD Pipeline
1. Push to branch
2. Run tests
3. Static analysis
4. Build
5. Deploy

## Monitoring

- Logs: [Soluzione]
- APM: [Soluzione]
- Alerts: [Condizioni]
```

---

## Modalità Esecuzione

### Autonoma (default)
Genera tutti i documenti senza fermarti se i prerequisiti sono soddisfatti.

### Interattiva
Se l'utente specifica "fermati per conferma", mostra ogni sezione per validazione.

### Minimal
Se l'utente specifica "solo API contract", genera solo `06_api_contract.md`.

---

## Output Finale

```markdown
## Design Completato

### Documenti Generati
- [x] docs/06_api_contract.md
- [x] docs/07_architecture.md (se generato)

### Riepilogo API
| Metrica | Valore |
|---------|--------|
| Resources | X |
| Endpoints totali | X |
| - GET | X |
| - POST | X |
| - PUT | X |
| - DELETE | X |

### Prossimi Passi
1. Revisiona l'API contract
2. Genera la roadmap: `/roadmap`
3. Oppure orchestra tutto: `full-project-setup`
```

---

## Integrazione con Altri Agent/Skill

Questo agent:
- **Richiede**: documenti di `project-discovery` (00-05)
- **Produce**: input per `ferlo-roadmap-generator`

Flusso completo:
```
project-discovery → project-design → ferlo-roadmap-generator → ferlo-phase-executor
```

---

*Agent per EXTRAWEB - v1.0.0*
