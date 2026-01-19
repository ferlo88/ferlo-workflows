---
name: ferlo-code-review
description: This skill performs automated code review following EXTRAWEB and Laravel standards. Use when user asks for "code review", "review my code", "check code quality", "security review", "review changes", "analyze code for issues", or "check for vulnerabilities".
version: 1.0.0
---

# Code Review Workflow

Esegui una review approfondita del codice seguendo gli standard EXTRAWEB.

## Fasi della Review

### 1. Self-Review (Pre-commit)
Analizza le modifiche staged:
```bash
git diff --staged
```

Check rapidi:
- Typo, sintassi errata, import mancanti
- Debug rimasto (console.log, dd(), dump(), var_dump)
- Commenti TODO/FIXME da risolvere
- Naming chiaro e convenzioni rispettate

### 2. Security Check (OWASP Top 10)
Verifica vulnerabilità:
- **SQL Injection**: Query parametrizzate, no DB::raw($userInput)
- **XSS**: Output escaped con {{ }}, mai {!! $userInput !!}
- **Mass Assignment**: Usa $fillable o $request->validated()
- **IDOR**: Policy/Gate per risorse sensibili
- **CSRF**: Token su tutti i form
- **Auth**: Session management sicuro

### 3. Quality Review
Analizza per categoria:
- **Readability**: Codice autoesplicativo, funzioni brevi
- **DRY**: No codice duplicato
- **Performance**: Query N+1, caching appropriato
- **Error Handling**: Eccezioni gestite, logging
- **Laravel Best Practices**: Eloquent, Form Requests, Resources

## Output Format

```markdown
# Code Review Report

## Summary
- Score: [A/B/C/D/F]
- Issues: [numero]
- Bloccanti: [numero]

## Issues

### [CRITICAL] Titolo
- File: path/file.php:42
- Problema: descrizione
- Fix: suggerimento

### [HIGH] ...
### [MEDIUM] ...
### [LOW] ...

## Quality Gates
- [ ] ./vendor/bin/pint (Code style)
- [ ] ./vendor/bin/phpstan analyse (Static analysis)
- [ ] php artisan test (Tests)
- [ ] composer audit (Security)
```
