---
name: status
description: Mostra lo stato completo del progetto (git, TODO, roadmap, health)
---

# /status - Stato Progetto

Fornisce una panoramica completa dello stato del progetto.

## Comportamento

Raccogli e mostra informazioni su:

### 1. Git Status
```bash
git status --short
git log --oneline -5
git branch -a
```

Output:
- Branch corrente
- File modificati/staged
- Ultimi 5 commit
- Branch disponibili

### 2. TODO e Task
Cerca nei file:
```bash
grep -r "TODO" --include="*.php" app/
grep -r "FIXME" --include="*.php" app/
```

Se esiste `docs/roadmap/`:
- Leggi stato fasi
- Mostra progresso

### 3. Test Status
```bash
php artisan test --compact
```

### 4. Health Check
Verifica:
- [ ] `.env` esiste
- [ ] Database connesso (`php artisan migrate:status`)
- [ ] Cache funzionante
- [ ] Storage linkato (`storage/app/public`)

### 5. Dependencies
```bash
composer outdated --direct
npm outdated
```

## Output Format

```
╔══════════════════════════════════════════════════════╗
║                   PROJECT STATUS                      ║
╠══════════════════════════════════════════════════════╣
║ Branch: main (clean)                                  ║
║ Last commit: abc123 - feat: add user profile          ║
╠══════════════════════════════════════════════════════╣
║ Tests: 45 passed, 0 failed                           ║
║ Coverage: 78%                                         ║
╠══════════════════════════════════════════════════════╣
║ TODO: 3 items                                         ║
║ FIXME: 1 item                                         ║
╠══════════════════════════════════════════════════════╣
║ Roadmap: Fase 2/5 (40%)                              ║
╠══════════════════════════════════════════════════════╣
║ Health: All OK                                        ║
╚══════════════════════════════════════════════════════╝
```

## Quick Actions

Suggerisci azioni basate sullo stato:
- Se ci sono file uncommitted → "Vuoi fare commit?"
- Se ci sono test falliti → "Vuoi vedere i dettagli?"
- Se ci sono TODO critici → "Vuoi lavorarci?"
