---
name: mockup
description: Genera mockup HTML per una vista o feature del progetto
---

# /mockup - Genera Mockup HTML

Crea mockup HTML interattivi per visualizzare UI prima dell'implementazione.

## Uso

```
/mockup dashboard           # Mockup per dashboard
/mockup user-profile        # Mockup profilo utente
/mockup lista prodotti      # Mockup lista prodotti
```

## Comportamento

1. **Analizza il contesto**:
   - Leggi CLAUDE.md o specifiche del progetto
   - Identifica il design system esistente (se presente)
   - Comprendi i requisiti della vista

2. **Genera HTML completo**:

```html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Nome Vista] - Mockup</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Header/Navigation -->
    <!-- Main Content -->
    <!-- Footer -->
</body>
</html>
```

3. **Includi sempre**:
   - Tailwind CSS per styling rapido
   - Responsive design (mobile-first)
   - Stati interattivi (hover, focus)
   - Dati placeholder realistici
   - Commenti per ogni sezione

4. **Salva in**:
   ```
   docs/mockups/[nome-vista].html
   ```

5. **Apri nel browser**:
   ```bash
   open docs/mockups/[nome-vista].html
   ```

## Output

Fornisci:
- File HTML completo
- Note su decisioni UI/UX
- Suggerimenti per l'implementazione Laravel/Blade
