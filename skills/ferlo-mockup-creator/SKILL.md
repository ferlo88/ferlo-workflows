---
name: ferlo-mockup-creator
description: This skill creates HTML mockups for Laravel projects based on documentation. Use when user asks to "create mockup", "generate HTML mockup", "create UI prototype", "design interface", or "mockup the views".
version: 1.0.0
---

# Mockup Creator Workflow

Genera mockup HTML completi basati sulla documentazione del progetto.

## Processo

### 1. Analisi Requisiti
Leggi la documentazione per identificare:
- Viste necessarie (lista, dettaglio, form)
- Componenti UI ricorrenti
- Flussi utente principali

### 2. Design System

**Colori EXTRAWEB:**
```css
:root {
    --ew-primary: #FF0080;
    --ew-secondary: #230159;
    --ew-dark: #0a0a0a;
    --ew-success: #00b894;
    --ew-warning: #fdcb6e;
    --ew-danger: #e17055;
}
```

**Font:** Poppins (Google Fonts)

### 3. Struttura Mockup

```
mockups/
├── index.html           # Navigator/indice
├── dashboard.html       # Dashboard principale
├── [entity]-list.html   # Liste entità
├── [entity]-detail.html # Dettaglio entità
├── [entity]-form.html   # Form creazione/modifica
└── assets/
    ├── style.css        # Stili condivisi
    └── script.js        # JS condiviso
```

### 4. Template Base

```html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Page Title] | [Project Name]</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body class="bg-gray-100">
    <!-- Sidebar -->
    <aside class="fixed left-0 top-0 h-full w-64 bg-gray-900 text-white">
        <!-- Navigation -->
    </aside>

    <!-- Main Content -->
    <main class="ml-64 p-8">
        <!-- Page content -->
    </main>

    <script src="assets/script.js"></script>
</body>
</html>
```

### 5. Componenti Standard

**Card:**
```html
<div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-lg font-semibold mb-4">Titolo</h3>
    <!-- Content -->
</div>
```

**Table:**
```html
<table class="w-full">
    <thead class="bg-gray-50">
        <tr>
            <th class="px-4 py-3 text-left">Colonna</th>
        </tr>
    </thead>
    <tbody class="divide-y">
        <tr class="hover:bg-gray-50">
            <td class="px-4 py-3">Valore</td>
        </tr>
    </tbody>
</table>
```

**Form:**
```html
<form class="space-y-4">
    <div>
        <label class="block text-sm font-medium mb-1">Campo</label>
        <input type="text" class="w-full border rounded-lg px-3 py-2">
    </div>
    <button type="submit" class="bg-pink-500 text-white px-4 py-2 rounded-lg">
        Salva
    </button>
</form>
```

## Output

Genera tutti i file HTML necessari con:
- Design coerente
- Navigazione funzionante
- Dati di esempio realistici
- Responsive design (Tailwind)
