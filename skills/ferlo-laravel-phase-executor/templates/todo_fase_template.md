# Fase {XX}: {NOME_FASE}

<!--
ISTRUZIONI PER CLAUDE:
1. Leggi questo file dall'inizio
2. Verifica i pre-requisiti
3. Esegui ogni task [ ] in ordine
4. Dopo ogni task: testa, committa
5. Alla fine: quality gates, aggiorna questo file, push
-->

## Metadata

| Campo | Valore |
|-------|--------|
| **ID Fase** | {XX} |
| **Nome** | {Nome descrittivo} |
| **Durata stimata** | {X} giorni |
| **Dipende da** | Fase {YY} |
| **Status** | TODO |
| **Branch** | `feature/fase-{XX}-{nome-slug}` |
| **Assegnato** | Claude Code |

## Obiettivo

{Descrizione chiara in 2-3 righe di cosa deve essere completato in questa fase}

## Pre-requisiti

Prima di iniziare, verifica che:

- [ ] Fase {YY} completata e mergiata
- [ ] Branch `develop` aggiornato
- [ ] Database migrato
- [ ] `.env` configurato correttamente
- [ ] {Altro prerequisito specifico}

---

## Task List

### Setup

- [ ] `TASK-{XX}-001` **Creare branch**
  ```bash
  git checkout develop && git pull
  git checkout -b feature/fase-{XX}-{nome}
  ```

- [ ] `TASK-{XX}-002` **Installare dipendenze** (se necessario)
  ```bash
  composer require {package}
  ```

---

### Sviluppo Core

- [ ] `TASK-{XX}-010` **{Titolo task}**
  - **File:** `app/Models/{Model}.php`
  - **Descrizione:** {Cosa deve fare questo task}
  - **Acceptance criteria:**
    - [ ] {Criterio 1}
    - [ ] {Criterio 2}
  - **Note:** {Eventuali note tecniche}

- [ ] `TASK-{XX}-011` **{Titolo task}**
  - **File:** `app/Http/Controllers/{Controller}.php`
  - **Descrizione:** {Cosa deve fare}
  - **Acceptance criteria:**
    - [ ] {Criterio 1}

- [ ] `TASK-{XX}-012` **{Titolo task}**
  - **File:** `database/migrations/{migration}.php`
  - **Descrizione:** {Cosa deve fare}
  - **Comando post:** `php artisan migrate`

---

### Testing

- [ ] `TASK-{XX}-020` **Unit test per {Component}**
  - **File:** `tests/Unit/{Component}Test.php`
  - **Coverage minimo:** 80%
  - **Test cases:**
    - [ ] Test case 1
    - [ ] Test case 2
    - [ ] Edge case

- [ ] `TASK-{XX}-021` **Feature test per {Feature}**
  - **File:** `tests/Feature/{Feature}Test.php`
  - **Test cases:**
    - [ ] Happy path
    - [ ] Validation errors
    - [ ] Authorization (403)
    - [ ] Not found (404)

---

### Documentazione

- [ ] `TASK-{XX}-030` **Aggiornare documentazione API**
  - **File:** `docs/06_api_contract.md`
  - **Sezioni:** {Quali endpoint aggiungere}

- [ ] `TASK-{XX}-031` **Aggiornare README** (se necessario)

---

## Quality Gates

Esegui tutti i gate dopo aver completato i task:

| Gate | Comando | Bloccante | Status |
|------|---------|-----------|--------|
| Unit Tests | `php artisan test --testsuite=Unit` | Si | |
| Feature Tests | `php artisan test --testsuite=Feature` | Si | |
| Code Style | `./vendor/bin/pint --test` | Si | |
| Static Analysis | `./vendor/bin/phpstan analyse` | Si | |
| Security | `composer audit` | Si | |

### Script rapido

```bash
#!/bin/bash
echo "Running tests..."
php artisan test || exit 1

echo "Checking code style..."
./vendor/bin/pint --test || exit 1

echo "Running static analysis..."
./vendor/bin/phpstan analyse || exit 1

echo "Security audit..."
composer audit || exit 1

echo "All gates passed!"
```

---

## Finalizzazione

Dopo i quality gates:

- [ ] Aggiorna questo file (segna [x] tutti i task)
- [ ] Aggiorna `CHANGELOG.md`
- [ ] Commit finale: `docs(fase-{XX}): complete phase {XX} - {nome}`
- [ ] Push: `git push origin feature/fase-{XX}-{nome}`

---

## Progress

```
Completamento: 0/{TOTAL} task (0%)
```

---

## Note di Sviluppo

| Data | Nota |
|------|------|
| {DATA} | {Nota iniziale} |

---

## Issue Riscontrati

| ID | Descrizione | Severita | Status | Soluzione |
|----|-------------|----------|--------|-----------|

---

## Riferimenti

- Requisiti: `docs/01_requirements.md`
- User Stories: `docs/03_personas_userstories.md`
- API Spec: `docs/06_api_contract.md`
- Schema DB: `docs/05_db_schema.md`

---

<!--
TEMPLATE COMMIT MESSAGES:

feat(fase-{XX}): TASK-{XX}-{NNN} - {descrizione breve}
fix(fase-{XX}): {descrizione fix}
test(fase-{XX}): add tests for {component}
docs(fase-{XX}): update {cosa}
style(fase-{XX}): fix code style
refactor(fase-{XX}): {descrizione refactor}
-->
