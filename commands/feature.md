---
name: feature
description: Git Flow - Gestisce feature branch (start, finish, list)
---

# /feature - Git Flow Feature Branch

Gestisce feature branch seguendo Git Flow.

## Uso

```
/feature start nome-feature    # Crea branch feature/nome-feature da develop
/feature finish                # Merge feature in develop e cancella branch
/feature list                  # Lista feature branch attive
```

## Comportamento

### /feature start [nome]

1. Verifica di essere su `develop` (o chiedi conferma)
2. Pull ultime modifiche
3. Crea branch `feature/[nome]`
4. Push branch su origin

```bash
git checkout develop
git pull origin develop
git checkout -b feature/nome-feature
git push -u origin feature/nome-feature
```

### /feature finish

1. Verifica di essere su un branch `feature/*`
2. Assicurati che tutti i cambiamenti siano committati
3. Merge in develop
4. Cancella branch locale e remoto

```bash
# Salva nome feature corrente
FEATURE_BRANCH=$(git branch --show-current)

# Merge in develop
git checkout develop
git pull origin develop
git merge --no-ff $FEATURE_BRANCH -m "Merge $FEATURE_BRANCH into develop"
git push origin develop

# Cancella branch
git branch -d $FEATURE_BRANCH
git push origin --delete $FEATURE_BRANCH
```

### /feature list

```bash
git branch -a | grep feature/
```

## Pre-requisiti

- Branch `develop` deve esistere
- Working directory pulita (no uncommitted changes)

## Convenzioni

- Nome feature: kebab-case (es. `user-authentication`, `payment-gateway`)
- Prefisso automatico: `feature/`
- Merge con `--no-ff` per mantenere storia
