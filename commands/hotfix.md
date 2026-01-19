---
name: hotfix
description: Git Flow - Gestisce hotfix urgenti su produzione
---

# /hotfix - Git Flow Hotfix

Gestisce hotfix urgenti per correzioni in produzione.

## Uso

```
/hotfix start 1.2.1 "descrizione bug"   # Crea hotfix da main
/hotfix finish                           # Merge in main e develop, crea tag
/hotfix list                             # Lista hotfix attivi
```

## Comportamento

### /hotfix start [version] [descrizione]

1. Crea branch `hotfix/[version]` da `main`
2. Incrementa patch version automaticamente se non specificata

```bash
git checkout main
git pull origin main
git checkout -b hotfix/1.2.1

# Aggiorna version
echo "1.2.1" > VERSION

git add VERSION
git commit -m "chore: start hotfix 1.2.1"
git push -u origin hotfix/1.2.1
```

### /hotfix finish

1. Verifica che tutti i fix siano committati
2. Merge in `main` con tag
3. Merge in `develop`
4. Cancella branch hotfix
5. **Notifica Slack** (urgente!)

```bash
VERSION=$(git branch --show-current | sed 's/hotfix\///')

# Merge in main
git checkout main
git pull origin main
git merge --no-ff hotfix/$VERSION -m "Hotfix $VERSION"
git tag -a v$VERSION -m "Hotfix $VERSION"
git push origin main --tags

# Merge in develop
git checkout develop
git pull origin develop
git merge --no-ff hotfix/$VERSION -m "Merge hotfix/$VERSION into develop"
git push origin develop

# Cleanup
git branch -d hotfix/$VERSION
git push origin --delete hotfix/$VERSION

# Notifica Slack
[ -n "$SLACK_WEBHOOK_URL" ] && curl -s -X POST -H 'Content-type: application/json' \
  -d '{"text":"🚨 HOTFIX v'$VERSION' rilasciato in produzione!"}' \
  "$SLACK_WEBHOOK_URL"
```

## Workflow Tipico

1. Bug critico segnalato in produzione
2. `/hotfix start` da main
3. Fix del bug con test
4. Code review rapido
5. `/hotfix finish` → deploy automatico

## Convenzioni

- Version: incrementa PATCH (1.2.0 → 1.2.1)
- Commit message: `fix: [descrizione bug]`
- Tag: `v1.2.1`
- Priorità massima su altre feature

## Checklist Pre-Hotfix

- [ ] Bug confermato in produzione
- [ ] Test per riprodurre il bug
- [ ] Fix minimale (no refactoring!)
- [ ] Review completata
- [ ] Test passano
