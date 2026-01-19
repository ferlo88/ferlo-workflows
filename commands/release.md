---
name: release
description: Git Flow - Gestisce release (start, finish) con changelog automatico
---

# /release - Git Flow Release

Gestisce release seguendo Git Flow con changelog automatico.

## Uso

```
/release start 1.2.0     # Crea branch release/1.2.0 da develop
/release finish          # Merge in main e develop, crea tag, genera changelog
/release list            # Lista release branch e tag
```

## Comportamento

### /release start [version]

1. Verifica formato versione (semver: X.Y.Z)
2. Crea branch `release/[version]` da develop
3. Aggiorna VERSION file se esiste
4. Prepara CHANGELOG.md

```bash
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# Aggiorna version
echo "1.2.0" > VERSION

# Prepara changelog
echo "## [1.2.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md

git add .
git commit -m "chore: prepare release 1.2.0"
git push -u origin release/1.2.0
```

### /release finish

1. Verifica di essere su branch `release/*`
2. Genera changelog dai commit
3. Merge in `main` con tag
4. Merge back in `develop`
5. Cancella branch release

```bash
VERSION=$(git branch --show-current | sed 's/release\///')

# Merge in main
git checkout main
git pull origin main
git merge --no-ff release/$VERSION -m "Release $VERSION"
git tag -a v$VERSION -m "Release $VERSION"
git push origin main --tags

# Merge in develop
git checkout develop
git pull origin develop
git merge --no-ff release/$VERSION -m "Merge release/$VERSION into develop"
git push origin develop

# Cleanup
git branch -d release/$VERSION
git push origin --delete release/$VERSION
```

### /release list

```bash
echo "=== Release Branches ==="
git branch -a | grep release/

echo "=== Tags ==="
git tag -l "v*" | tail -10
```

## Changelog Automatico

Genera changelog dai commit tra ultimo tag e HEAD:

```bash
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s" --no-merges
```

Categorizza automaticamente:
- `feat:` → Added
- `fix:` → Fixed
- `docs:` → Documentation
- `refactor:` → Changed
- `BREAKING:` → Breaking Changes

## Esempio Output CHANGELOG.md

```markdown
## [1.2.0] - 2026-01-19

### Added
- User authentication system
- Payment gateway integration

### Fixed
- Login redirect issue
- Cart calculation bug

### Changed
- Refactored order service
```
