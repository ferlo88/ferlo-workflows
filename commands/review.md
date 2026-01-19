---
name: review
description: Code review rapido sui file modificati o su un path specifico
---

# /review - Code Review Rapido

Esegui una code review seguendo gli standard EXTRAWEB.

## Comportamento

1. **Identifica i file da revieware**:
   - Se l'utente specifica un path, usa quello
   - Altrimenti, usa `git diff --name-only` per trovare i file modificati
   - Se non ci sono modifiche git, chiedi all'utente cosa revieware

2. **Per ogni file, verifica**:

### Security (OWASP Top 10)
- [ ] SQL Injection (usa sempre query parametrizzate)
- [ ] XSS (escape output con `e()` o `{{ }}`)
- [ ] CSRF (token presenti nei form)
- [ ] Mass Assignment (usa `$fillable` o `$guarded`)
- [ ] Authentication/Authorization (middleware e policy)

### Laravel Best Practices
- [ ] Eloquent invece di query raw
- [ ] Form Request per validazione
- [ ] Resource per API responses
- [ ] Service classes per logica complessa
- [ ] Repository pattern dove appropriato

### Codice
- [ ] Nomi descrittivi (variabili, metodi, classi)
- [ ] Metodi brevi (max 20 righe idealmente)
- [ ] Single Responsibility Principle
- [ ] No codice duplicato
- [ ] Commenti solo dove necessario

3. **Output**:
   Fornisci un report con:
   - Problemi critici (da fixare subito)
   - Warning (da considerare)
   - Suggerimenti (nice to have)
