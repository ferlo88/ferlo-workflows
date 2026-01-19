---
name: ferlo-laravel-phase-executor
description: Esegue autonomamente fasi di sviluppo Laravel leggendo i file todo_fase_XX.md, completando task con test e commit appropriati, e applicando quality gates
version: 1.0.0
triggers:
  - "esegui la fase"
  - "completa la fase"
  - "sviluppa il modulo"
  - "porta avanti il progetto"
  - "execute phase"
---

# Laravel Phase Executor

Skill per eseguire autonomamente fasi di sviluppo Laravel con quality gates integrati.

## Quando si attiva

Questa skill si attiva quando l'utente dice:
- "Esegui la fase X"
- "Completa la fase di [nome]"
- "Sviluppa il modulo [nome]"
- "Porta avanti il progetto dalla fase X"

## File Richiesti

La skill si aspetta questa struttura nel progetto:

```
project/
├── docs/
│   └── roadmap/
│       ├── ROADMAP.md
│       └── todo_fase_XX_nome.md
├── composer.json
└── artisan
```

---

## Workflow di Esecuzione

### STEP 1: Inizializzazione

```bash
# Verifica stato git
git status
git stash  # se ci sono modifiche non committate

# Aggiorna develop
git checkout develop
git pull origin develop

# Crea branch per la fase
git checkout -b feature/fase-{XX}-{nome}
```

### STEP 2: Parsing del TODO

Leggi il file `docs/roadmap/todo_fase_XX_nome.md` e identifica:

1. **Metadata**: fase, nome, dipendenze, branch
2. **Pre-requisiti**: verifica che siano soddisfatti
3. **Task list**: estrai tutti i task con formato `TASK-XX-XXX`
4. **Quality gates**: identifica quali sono obbligatori

### STEP 3: Esecuzione Task (Loop)

Per ogni task non completato `[ ]`:

```
1. ANALIZZA il task
   - Cosa deve essere implementato?
   - Quali file sono coinvolti?
   - Ci sono dipendenze da altri task?

2. IMPLEMENTA
   - Scrivi il codice necessario
   - Segui le convenzioni Laravel
   - Usa i pattern definiti nel progetto

3. TESTA
   - Scrivi unit test se è logica
   - Scrivi feature test se è endpoint/controller
   - Verifica che i test passino

4. VERIFICA
   - Il codice funziona come atteso?
   - Rispetta le convenzioni?
   - Non introduce regressioni?

5. COMMITTA
   - Messaggio: feat(fase-XX): TASK-XX-XXX - [descrizione breve]
   - Includi solo i file relativi al task
```

### STEP 4: Quality Gates

Dopo tutti i task, esegui i quality gates:

```bash
# GATE 1: Tests (BLOCCANTE)
php artisan test --testsuite=Unit
php artisan test --testsuite=Feature

# GATE 2: Code Style (BLOCCANTE)
./vendor/bin/pint --test
# Se fallisce: ./vendor/bin/pint && git add . && git commit -m "style: fix code style"

# GATE 3: Static Analysis (BLOCCANTE)
./vendor/bin/phpstan analyse
# Se fallisce: correggi errori e committa

# GATE 4: Security (BLOCCANTE)
composer audit
# Se ci sono vulnerabilità critiche: aggiorna dipendenze
```

### STEP 5: Finalizzazione

```bash
# Aggiorna il TODO file
# Cambia [ ] in [x] per tutti i task completati
# Aggiorna la progress bar

# Aggiorna CHANGELOG.md
# Aggiungi entry sotto [Unreleased]

# Commit finale
git add docs/
git commit -m "docs(fase-XX): complete phase XX - {nome}"

# Push
git push origin feature/fase-{XX}-{nome}
```

### STEP 6: Report

Genera un report finale:

```markdown
## Fase XX Completata

### Task Eseguiti
- [x] TASK-XX-001: [descrizione]
- [x] TASK-XX-002: [descrizione]
...

### Quality Gates
| Gate | Status | Note |
|------|--------|------|
| Unit Tests | OK | 15 tests, 42 assertions |
| Feature Tests | OK | 8 tests passed |
| Code Style | OK | No issues |
| PHPStan | OK | Level 5, 0 errors |
| Security | OK | No vulnerabilities |

### Commits
- `abc1234` feat(fase-XX): TASK-XX-001 - ...
- `def5678` feat(fase-XX): TASK-XX-002 - ...

### Prossimi Passi
1. Creare PR verso develop
2. Code review
3. Merge e passare a Fase XX+1
```

---

## Gestione Errori

### Se un test fallisce:
1. Analizza l'errore
2. Correggi il codice
3. Riesegui il test
4. Se il fix richiede modifiche significative, committa separatamente con `fix:`

### Se PHPStan trova errori:
1. Leggi il messaggio di errore
2. Correggi il tipo/logica
3. Riesegui l'analisi
4. Committa il fix

### Se composer audit trova vulnerabilità:
1. Se è una dipendenza diretta: `composer update [package]`
2. Se è transitiva: verifica se c'è una versione sicura
3. Se non risolvibile: documenta nel report e procedi

### Se il task è ambiguo:
1. **NON PROCEDERE** se non sei sicuro
2. Chiedi chiarimenti all'utente
3. Documenta l'ambiguità nel report

---

## Configurazione

La skill può essere configurata con un file `.claude/phase-executor.yml`:

```yaml
project:
  name: "NomeProgetto"
  type: "laravel"  # laravel | laravel-api | laravel-saas

quality_gates:
  tests:
    enabled: true
    blocking: true
    coverage_min: 80

  pint:
    enabled: true
    blocking: true

  phpstan:
    enabled: true
    blocking: true
    level: 5

  security:
    enabled: true
    blocking: true

git:
  branch_prefix: "feature/fase-"
  commit_prefix: "feat"
  auto_push: true
```

---

## Modalità di Esecuzione

### Esecuzione singola fase
```
Esegui la fase 03 (Multi-Tenancy) del progetto.
```

### Esecuzione con review intermedia
```
Esegui la fase 04, ma fermati dopo ogni task
per mostrarmi cosa hai fatto prima di committare.
```

### Esecuzione batch (più fasi)
```
Esegui le fasi 03, 04 e 05 in sequenza.
Se una fase fallisce, fermati e reporta.
```

### Solo quality gates
```
Esegui solo i quality gates sulla fase corrente
senza sviluppare nuovi task.
```

### Dry run
```
Analizza la fase 05 e dimmi cosa faresti,
senza eseguire nulla.
```

### Ripresa da errore
```
La fase 04 è fallita al task TASK-04-012.
Riprendi da quel punto e completa la fase.
```

---

## Best Practices

1. **Una fase alla volta**: Meglio completare bene una fase che fare male più fasi
2. **Commit atomici**: Ogni task = un commit
3. **Test first**: Se possibile, scrivi il test prima del codice
4. **No skip dei gate**: I gate bloccanti non si saltano mai
5. **Documenta le decisioni**: Se fai una scelta non ovvia, documentala
6. **Chiedi se in dubbio**: Meglio chiedere che sbagliare

---

## Troubleshooting

### "Non trovo il file todo_fase_XX.md"
- Verifica che esista in `docs/roadmap/`
- Controlla il naming: deve essere `todo_fase_XX_nome.md`

### "I test falliscono ma il codice è corretto"
- Verifica che il database di test sia configurato
- Controlla: `php artisan migrate:fresh --env=testing`

### "PHPStan trova troppi errori"
- Verifica il livello in `phpstan.neon`
- Considera di abbassare il livello temporaneamente

### "La fase ha troppe dipendenze"
- Potrebbe essere troppo grande
- Considera di splittarla in sotto-fasi

---

## Metriche di Successo

Una fase è completata con successo quando:

- Tutti i task sono marcati `[x]`
- Tutti i quality gates bloccanti passano
- Il branch è pushato
- Il TODO è aggiornato
- Il CHANGELOG è aggiornato
- Il report finale è generato

---

*Skill per EXTRAWEB - v1.0.0*
