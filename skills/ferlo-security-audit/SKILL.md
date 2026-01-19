---
name: ferlo-security-audit
description: Esegue audit sicurezza completo del progetto. Usa quando l'utente chiede "security audit", "vulnerabilità", "sicurezza", "OWASP", "penetration test", "security check", o "controlla sicurezza".
version: 1.0.0
---

# Security Audit - Analisi Sicurezza Completa

Esegue un audit di sicurezza completo seguendo OWASP Top 10 e best practices Laravel.

## Aree di Analisi

| Area | Cosa Controlla |
|------|----------------|
| **Dipendenze** | Vulnerabilità note in composer/npm |
| **Autenticazione** | Password, sessioni, 2FA |
| **Autorizzazione** | Policies, gates, middleware |
| **Input Validation** | SQL injection, XSS, mass assignment |
| **Configurazione** | .env, debug mode, HTTPS |
| **File Upload** | Validazione, storage |
| **API Security** | Rate limiting, CORS, tokens |
| **Logging** | Info sensibili nei log |

## Comandi Audit

### 1. Dipendenze

```bash
# Composer vulnerabilities
composer audit

# NPM vulnerabilities
npm audit

# Dettaglio severity
npm audit --audit-level=high
```

### 2. Configurazione

```bash
# Debug mode (DEVE essere false in prod)
grep "APP_DEBUG" .env

# APP_KEY impostato
grep "APP_KEY" .env | grep -v "^APP_KEY=$"

# HTTPS forzato
grep "FORCE_HTTPS\|APP_URL=https" .env
```

### 3. Codice

```bash
# SQL Injection - query raw senza binding
grep -rn "DB::raw\|->whereRaw\|->selectRaw" app/ --include="*.php" | grep -v "?"

# XSS - output non escaped
grep -rn "{!!\|@php echo" resources/views/ --include="*.blade.php"

# Mass Assignment vulnerabile
grep -rn "protected \$guarded = \[\]" app/Models/ --include="*.php"

# Hardcoded credentials
grep -rn "password.*=.*['\"]" app/ --include="*.php" | grep -v "password.*=.*\$"

# Debug/dump in codice
grep -rn "dd(\|dump(\|var_dump(\|print_r(" app/ --include="*.php"
```

## Checklist OWASP Top 10

### A01: Broken Access Control

```php
// ❌ Nessun check autorizzazione
public function show($id) {
    return User::find($id);
}

// ✅ Con policy
public function show(User $user) {
    $this->authorize('view', $user);
    return $user;
}
```

**Verifica:**
- [ ] Tutte le route protette da middleware auth
- [ ] Policies definite per ogni model sensibile
- [ ] Gates per azioni specifiche
- [ ] Nessun IDOR (Insecure Direct Object Reference)

### A02: Cryptographic Failures

```php
// ❌ Password in chiaro
$user->password = $request->password;

// ✅ Hash
$user->password = Hash::make($request->password);
```

**Verifica:**
- [ ] Password hashate con bcrypt/argon2
- [ ] Dati sensibili criptati (encrypt/decrypt)
- [ ] HTTPS forzato
- [ ] APP_KEY unica e sicura

### A03: Injection

```php
// ❌ SQL Injection
DB::select("SELECT * FROM users WHERE id = " . $id);

// ✅ Prepared statement
DB::select("SELECT * FROM users WHERE id = ?", [$id]);
User::where('id', $id)->first();
```

**Verifica:**
- [ ] Nessuna query raw con concatenazione
- [ ] Eloquent/Query Builder usato correttamente
- [ ] Validazione input su tutti i campi

### A04: Insecure Design

**Verifica:**
- [ ] Rate limiting su login/API
- [ ] CAPTCHA su form pubblici
- [ ] Timeout sessione appropriato
- [ ] Logout invalida sessione

### A05: Security Misconfiguration

```bash
# Verifica configurazione
php artisan config:show app.debug     # false
php artisan config:show app.env       # production
php artisan config:show session.secure # true
```

**Verifica:**
- [ ] APP_DEBUG=false in produzione
- [ ] Error reporting non espone dettagli
- [ ] Directory listing disabilitato
- [ ] File sensibili non accessibili (.env, .git)

### A06: Vulnerable Components

```bash
# Aggiorna dipendenze
composer update --dry-run
npm update --dry-run

# Check specifico
composer outdated --direct
```

**Verifica:**
- [ ] Nessuna vulnerabilità critica
- [ ] Dipendenze aggiornate
- [ ] Versione Laravel supportata

### A07: Authentication Failures

```php
// Rate limiting login
RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});
```

**Verifica:**
- [ ] Rate limiting su login
- [ ] Password policy (minimo 8 char, complessità)
- [ ] 2FA disponibile
- [ ] Session fixation prevention

### A08: Data Integrity Failures

**Verifica:**
- [ ] CSRF token su tutti i form
- [ ] Signed URLs per link sensibili
- [ ] Verifica integrità file upload

### A09: Security Logging Failures

```php
// Log eventi sicurezza
Log::channel('security')->info('Login success', [
    'user_id' => $user->id,
    'ip' => request()->ip(),
]);
```

**Verifica:**
- [ ] Login/logout loggati
- [ ] Tentativi falliti loggati
- [ ] Azioni admin loggati
- [ ] Nessun dato sensibile nei log

### A10: Server-Side Request Forgery (SSRF)

```php
// ❌ URL non validato
$content = file_get_contents($request->url);

// ✅ Whitelist
$allowedHosts = ['api.example.com'];
$parsed = parse_url($request->url);
if (!in_array($parsed['host'], $allowedHosts)) {
    abort(403);
}
```

**Verifica:**
- [ ] URL esterni validati/whitelistati
- [ ] Redirect validati
- [ ] Webhook URL verificati

## Report Output

### Template Report Sicurezza

```markdown
# Security Audit Report

**Project**: {PROJECT_NAME}
**Date**: {DATE}
**Auditor**: Claude Code

## Executive Summary

| Severity | Count |
|----------|-------|
| Critical | {N} |
| High | {N} |
| Medium | {N} |
| Low | {N} |
| Info | {N} |

## Findings

### CRITICAL

#### [SEC-001] SQL Injection in UserController
- **File**: app/Http/Controllers/UserController.php:45
- **Description**: Raw query with user input concatenation
- **Impact**: Full database compromise
- **Remediation**: Use parameterized queries

### HIGH

#### [SEC-002] Missing CSRF Protection
...

## Recommendations

1. **Immediate**: Fix all Critical and High issues
2. **Short-term**: Implement rate limiting
3. **Long-term**: Add 2FA, security headers

## Compliance

- [ ] OWASP Top 10 2021
- [ ] Laravel Security Best Practices
- [ ] GDPR (if applicable)
```

## Comandi Rapidi

```bash
# Quick security check
php artisan security:check  # Se hai il package

# Headers security
curl -I https://yoursite.com | grep -i "security\|x-frame\|x-content\|x-xss"

# SSL check
openssl s_client -connect yoursite.com:443 -servername yoursite.com
```

## Tools Consigliati

```bash
# Laravel Security Checker
composer require --dev enlightn/security-checker
php artisan security:check

# Static Analysis
composer require --dev phpstan/phpstan
./vendor/bin/phpstan analyse

# Laravel Specific
composer require --dev enlightn/enlightn
php artisan enlightn
```
