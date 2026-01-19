---
name: ferlo-changelog
description: This skill generates and maintains CHANGELOG.md from git commits following Keep a Changelog format. Use when user asks for "changelog", "generate changelog", "update changelog", "release notes", or "what changed".
version: 1.0.0
---

# Changelog Generator

Genera e mantiene CHANGELOG.md seguendo il formato [Keep a Changelog](https://keepachangelog.com/).

## Formato Output

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description

## [1.2.0] - 2026-01-19

### Added
- User authentication system (#123)
- Payment gateway integration (#145)

### Fixed
- Login redirect issue (#156)

## [1.1.0] - 2026-01-10
...
```

## Categorizzazione Automatica

Mappa prefissi commit → sezioni changelog:

| Prefisso | Sezione |
|----------|---------|
| `feat:` | Added |
| `fix:` | Fixed |
| `docs:` | Documentation |
| `style:` | Changed |
| `refactor:` | Changed |
| `perf:` | Changed |
| `test:` | Changed |
| `chore:` | Changed |
| `BREAKING CHANGE:` | Breaking Changes |
| `deprecate:` | Deprecated |
| `remove:` | Removed |
| `security:` | Security |

## Comandi Utili

### Genera changelog da ultimo tag
```bash
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD \
  --pretty=format:"%s" --no-merges
```

### Lista tutti i tag
```bash
git tag -l --sort=-version:refname | head -10
```

### Commit tra due tag
```bash
git log v1.1.0..v1.2.0 --pretty=format:"- %s (%h)" --no-merges
```

## Workflow

1. **Analizza commit** dall'ultimo tag
2. **Categorizza** per prefisso
3. **Formatta** in markdown
4. **Aggiungi** issue/PR references se presenti
5. **Inserisci** in CHANGELOG.md

## Template Nuova Release

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
-

### Changed
-

### Fixed
-

### Security
-
```

## Best Practices

1. **Un commit = una voce** (evita commit generici)
2. **Usa prefissi** consistenti (feat, fix, etc.)
3. **Riferisci issue** quando possibile (#123)
4. **Descrivi impatto** utente, non dettagli tecnici
5. **Mantieni Unreleased** per work in progress
