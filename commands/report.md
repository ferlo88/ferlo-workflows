---
name: report
description: Genera un report HTML visuale con metriche e stato del progetto
---

# /report - Project Dashboard HTML

Genera un report HTML interattivo con metriche del progetto.

## Uso

```
/report              # Report completo
/report quick        # Report veloce (solo metriche base)
/report coverage     # Focus su test coverage
```

## Metriche Raccolte

### 1. Git Stats
```bash
# Commit totali
git rev-list --count HEAD

# Contributors
git shortlog -sn --no-merges | head -10

# Ultimo commit
git log -1 --format="%H|%an|%ar|%s"

# Branch attivi
git branch -a | wc -l
```

### 2. Code Stats
```bash
# Linee di codice PHP
find app -name "*.php" | xargs wc -l | tail -1

# Numero file
find app -name "*.php" | wc -l

# TODO/FIXME
grep -r "TODO\|FIXME" app --include="*.php" | wc -l
```

### 3. Test Coverage
```bash
php artisan test --coverage --min=0
```

### 4. Dependencies
```bash
# Outdated packages
composer outdated --direct --format=json
npm outdated --json
```

## Template HTML Report

```html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Project Report - [PROJECT_NAME]</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-6xl mx-auto">
        <header class="bg-white rounded-lg shadow p-6 mb-6">
            <h1 class="text-3xl font-bold">[PROJECT_NAME]</h1>
            <p class="text-gray-500">Report generato: [DATE]</p>
        </header>

        <!-- Stats Cards -->
        <div class="grid grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-lg shadow p-4">
                <p class="text-gray-500 text-sm">Linee di Codice</p>
                <p class="text-3xl font-bold">[LOC]</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
                <p class="text-gray-500 text-sm">Test Coverage</p>
                <p class="text-3xl font-bold text-green-600">[COVERAGE]%</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
                <p class="text-gray-500 text-sm">TODO/FIXME</p>
                <p class="text-3xl font-bold text-yellow-600">[TODOS]</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
                <p class="text-gray-500 text-sm">Commits</p>
                <p class="text-3xl font-bold">[COMMITS]</p>
            </div>
        </div>

        <!-- Charts -->
        <div class="grid grid-cols-2 gap-6 mb-6">
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-bold mb-4">Commit Activity</h2>
                <canvas id="commitChart"></canvas>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-bold mb-4">Code Distribution</h2>
                <canvas id="codeChart"></canvas>
            </div>
        </div>

        <!-- Tables -->
        <div class="grid grid-cols-2 gap-6">
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-bold mb-4">Top Contributors</h2>
                <table class="w-full">
                    <thead>
                        <tr class="border-b">
                            <th class="text-left py-2">Nome</th>
                            <th class="text-right py-2">Commits</th>
                        </tr>
                    </thead>
                    <tbody>
                        [CONTRIBUTORS_ROWS]
                    </tbody>
                </table>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-bold mb-4">Outdated Dependencies</h2>
                <table class="w-full">
                    <thead>
                        <tr class="border-b">
                            <th class="text-left py-2">Package</th>
                            <th class="text-right py-2">Current → Latest</th>
                        </tr>
                    </thead>
                    <tbody>
                        [DEPENDENCIES_ROWS]
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Health Check -->
        <div class="bg-white rounded-lg shadow p-6 mt-6">
            <h2 class="text-xl font-bold mb-4">Health Check</h2>
            <div class="space-y-2">
                [HEALTH_ITEMS]
            </div>
        </div>
    </div>

    <script>
        // Commit chart
        new Chart(document.getElementById('commitChart'), {
            type: 'line',
            data: {
                labels: [COMMIT_LABELS],
                datasets: [{
                    label: 'Commits',
                    data: [COMMIT_DATA],
                    borderColor: 'rgb(59, 130, 246)',
                    tension: 0.1
                }]
            }
        });

        // Code distribution chart
        new Chart(document.getElementById('codeChart'), {
            type: 'doughnut',
            data: {
                labels: ['Models', 'Controllers', 'Views', 'Other'],
                datasets: [{
                    data: [CODE_DISTRIBUTION],
                    backgroundColor: ['#3B82F6', '#10B981', '#F59E0B', '#6B7280']
                }]
            }
        });
    </script>
</body>
</html>
```

## Output

Salva report in:
```
docs/reports/report_[DATE].html
```

Apri automaticamente:
```bash
open docs/reports/report_[DATE].html
```

## Health Check Items

- [ ] .env esiste e configurato
- [ ] Database connesso
- [ ] Cache funzionante
- [ ] Storage linkato
- [ ] Queue attiva
- [ ] Nessun TODO critico
- [ ] Test passano
- [ ] No security vulnerabilities
