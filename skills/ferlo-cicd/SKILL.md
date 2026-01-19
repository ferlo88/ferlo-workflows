---
name: ferlo-cicd
description: This skill generates CI/CD pipeline configurations for Laravel projects. Use when user asks for "CI/CD", "GitHub Actions", "pipeline", "automated tests", "continuous integration", "deploy automation", or "workflow yaml".
version: 1.0.0
---

# CI/CD Templates - GitHub Actions per Laravel

Genera configurazioni CI/CD per progetti Laravel.

## GitHub Actions Base

### Test Pipeline

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  tests:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, dom, fileinfo, mysql
          coverage: xdebug

      - name: Cache Composer
        uses: actions/cache@v3
        with:
          path: vendor
          key: composer-${{ hashFiles('composer.lock') }}

      - name: Install Dependencies
        run: composer install --no-progress --prefer-dist

      - name: Copy .env
        run: cp .env.example .env.testing

      - name: Generate Key
        run: php artisan key:generate --env=testing

      - name: Run Tests
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: testing
          DB_USERNAME: root
          DB_PASSWORD: password
        run: php artisan test --coverage --min=80

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        if: success()
```

### Code Quality Pipeline

```yaml
# .github/workflows/quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'

      - name: Install Dependencies
        run: composer install --no-progress --prefer-dist

      - name: Laravel Pint
        run: ./vendor/bin/pint --test

      - name: PHPStan
        run: ./vendor/bin/phpstan analyse --memory-limit=2G

      - name: Security Check
        run: composer audit
```

### Deploy Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'

      - name: Install Dependencies
        run: composer install --no-dev --optimize-autoloader

      - name: Build Assets
        run: |
          npm ci
          npm run build

      - name: Deploy to Server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /var/www/html
            git pull origin main
            composer install --no-dev --optimize-autoloader
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
            php artisan queue:restart

      - name: Notify Slack
        if: success()
        run: |
          curl -X POST -H 'Content-type: application/json' \
            --data '{"text":"✅ Deploy completato su produzione!"}' \
            ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Pipeline Completa

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PHP_VERSION: '8.2'

jobs:
  # Job 1: Tests
  tests:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306

    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ env.PHP_VERSION }}

      - run: composer install
      - run: cp .env.example .env.testing
      - run: php artisan key:generate --env=testing
      - run: php artisan test
        env:
          DB_HOST: 127.0.0.1
          DB_DATABASE: testing
          DB_USERNAME: root
          DB_PASSWORD: password

  # Job 2: Code Quality
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ env.PHP_VERSION }}

      - run: composer install
      - run: ./vendor/bin/pint --test
      - run: ./vendor/bin/phpstan analyse

  # Job 3: Build
  build:
    runs-on: ubuntu-latest
    needs: [tests, quality]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: build
          path: public/build

  # Job 4: Deploy (solo main)
  deploy:
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v3
        with:
          name: build
          path: public/build
      # Deploy steps...
```

## Secrets Necessari

Configura in GitHub Repository Settings → Secrets:

| Secret | Descrizione |
|--------|-------------|
| `SERVER_HOST` | IP o hostname server |
| `SERVER_USER` | Username SSH |
| `SERVER_SSH_KEY` | Chiave privata SSH |
| `SLACK_WEBHOOK_URL` | Webhook per notifiche |

## .env.testing

```env
APP_ENV=testing
APP_KEY=
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=root
DB_PASSWORD=password
CACHE_DRIVER=array
QUEUE_CONNECTION=sync
SESSION_DRIVER=array
```
