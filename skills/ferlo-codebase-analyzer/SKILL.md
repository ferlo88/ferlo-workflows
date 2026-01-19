---
name: ferlo-codebase-analyzer
description: This skill analyzes existing codebases to understand structure, patterns, and conventions. Use when user asks to "analyze codebase", "understand this project", "explore the code", "what does this project do", or "explain the architecture".
version: 1.0.0
---

# Codebase Analysis Workflow

Analizza codebase esistenti per comprendere struttura, pattern e convenzioni.

## Analisi Rapida

### 1. Struttura Progetto
```bash
# Visualizza struttura
find app -type f -name "*.php" | head -50

# Conta file per tipo
find app -name "*.php" | wc -l
find tests -name "*.php" | wc -l
```

### 2. Entry Points
Analizza:
- `routes/web.php` - Route web
- `routes/api.php` - Route API
- `app/Console/Kernel.php` - Comandi schedulati
- `app/Providers/` - Service providers

### 3. Pattern Detection

**Repository Pattern:**
```bash
ls app/Repositories/ 2>/dev/null
```

**Service Pattern:**
```bash
ls app/Services/ 2>/dev/null
```

**Action Pattern:**
```bash
ls app/Actions/ 2>/dev/null
```

## Report di Analisi

```markdown
# Codebase Analysis Report

## Overview
- **Framework**: Laravel [version]
- **PHP Version**: [version]
- **Lines of Code**: [count]

## Architecture

### Patterns Used
- [ ] Repository Pattern
- [ ] Service Layer
- [ ] Action Classes
- [ ] Event/Listener
- [ ] Jobs/Queues

### Directory Structure
app/
├── Http/Controllers/    [X files]
├── Models/              [X files]
├── Services/            [X files]
└── ...

## Dependencies
[Lista composer.json require]

## Database
- Tables: [count]
- Key relationships: [descrizione]

## API Endpoints
[Lista route principali]

## Test Coverage
- Feature tests: [count]
- Unit tests: [count]

## Observations
- [Pattern notevoli]
- [Convenzioni particolari]
- [Aree di miglioramento]
```

## Checklist Analisi

- [ ] Struttura directory mappata
- [ ] Pattern architetturali identificati
- [ ] Dipendenze principali note
- [ ] Schema database compreso
- [ ] API endpoints documentati
- [ ] Convenzioni di naming identificate
