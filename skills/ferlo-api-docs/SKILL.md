---
name: ferlo-api-docs
description: Genera documentazione API OpenAPI/Swagger automatica. Usa quando l'utente chiede "documentazione API", "swagger", "OpenAPI", "API docs", "documenta endpoint", o "genera spec API".
version: 1.0.0
---

# API Docs Generator - Documentazione OpenAPI/Swagger

Genera automaticamente documentazione API in formato OpenAPI 3.0 analizzando routes e controllers.

## Output Generati

| File | Formato | Uso |
|------|---------|-----|
| `docs/api/openapi.yaml` | OpenAPI 3.0 | Spec completa |
| `docs/api/openapi.json` | JSON | Per Swagger UI |
| `docs/api/README.md` | Markdown | Documentazione leggibile |

## Workflow

### Step 1: Analizza Routes API

```bash
# Lista routes API
php artisan route:list --path=api --json

# Output esempio:
# [
#   {"method": "GET", "uri": "api/quotes", "action": "QuoteController@index"},
#   {"method": "POST", "uri": "api/quotes", "action": "QuoteController@store"},
#   ...
# ]
```

### Step 2: Analizza Controllers

Per ogni controller, estrai:
- Metodi e loro signature
- Type hints (Request, Model)
- Return types
- Docblocks esistenti
- Validazioni da FormRequest

### Step 3: Analizza Models (per response schema)

```php
// Estrai da Model
$fillable = [...];
$casts = [...];
$hidden = [...];
```

### Step 4: Genera OpenAPI Spec

## Template OpenAPI 3.0

```yaml
openapi: 3.0.3
info:
  title: {PROJECT_NAME} API
  description: |
    API documentation for {PROJECT_NAME}.

    ## Authentication
    This API uses Bearer token authentication (Laravel Sanctum).

    Include the token in the Authorization header:
    ```
    Authorization: Bearer {your-token}
    ```
  version: {VERSION}
  contact:
    name: {AUTHOR}
    email: {EMAIL}

servers:
  - url: http://localhost/api
    description: Local development
  - url: https://staging.example.com/api
    description: Staging
  - url: https://api.example.com
    description: Production

tags:
  - name: Authentication
    description: Login, logout, token management
  - name: {Resource}
    description: {Resource} management endpoints

paths:
  /auth/login:
    post:
      tags: [Authentication]
      summary: Authenticate user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  format: password
      responses:
        '200':
          description: Successful authentication
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string
                  user:
                    $ref: '#/components/schemas/User'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /{resources}:
    get:
      tags: [{Resource}]
      summary: List all {resources}
      security:
        - bearerAuth: []
      parameters:
        - $ref: '#/components/parameters/page'
        - $ref: '#/components/parameters/per_page'
        - $ref: '#/components/parameters/sort'
        - $ref: '#/components/parameters/filter'
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/{Resource}'
                  meta:
                    $ref: '#/components/schemas/PaginationMeta'
                  links:
                    $ref: '#/components/schemas/PaginationLinks'
        '401':
          $ref: '#/components/responses/Unauthorized'

    post:
      tags: [{Resource}]
      summary: Create a new {resource}
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/{Resource}Input'
      responses:
        '201':
          description: Created successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: '#/components/schemas/{Resource}'
        '422':
          $ref: '#/components/responses/ValidationError'

  /{resources}/{id}:
    get:
      tags: [{Resource}]
      summary: Get {resource} by ID
      security:
        - bearerAuth: []
      parameters:
        - $ref: '#/components/parameters/id'
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: '#/components/schemas/{Resource}'
        '404':
          $ref: '#/components/responses/NotFound'

    put:
      tags: [{Resource}]
      summary: Update {resource}
      security:
        - bearerAuth: []
      parameters:
        - $ref: '#/components/parameters/id'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/{Resource}Input'
      responses:
        '200':
          description: Updated successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: '#/components/schemas/{Resource}'
        '422':
          $ref: '#/components/responses/ValidationError'

    delete:
      tags: [{Resource}]
      summary: Delete {resource}
      security:
        - bearerAuth: []
      parameters:
        - $ref: '#/components/parameters/id'
      responses:
        '204':
          description: Deleted successfully
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  parameters:
    id:
      name: id
      in: path
      required: true
      schema:
        type: integer
    page:
      name: page
      in: query
      schema:
        type: integer
        default: 1
    per_page:
      name: per_page
      in: query
      schema:
        type: integer
        default: 15
        maximum: 100
    sort:
      name: sort
      in: query
      schema:
        type: string
      description: Sort field (prefix with - for descending)
    filter:
      name: filter
      in: query
      schema:
        type: object
      style: deepObject

  schemas:
    {Resource}:
      type: object
      properties:
        id:
          type: integer
          readOnly: true
        # ... altri campi da $fillable
        created_at:
          type: string
          format: date-time
          readOnly: true
        updated_at:
          type: string
          format: date-time
          readOnly: true

    {Resource}Input:
      type: object
      required:
        # ... campi required da validation rules
      properties:
        # ... campi da $fillable (esclusi id, timestamps)

    PaginationMeta:
      type: object
      properties:
        current_page:
          type: integer
        last_page:
          type: integer
        per_page:
          type: integer
        total:
          type: integer

    PaginationLinks:
      type: object
      properties:
        first:
          type: string
        last:
          type: string
        prev:
          type: string
          nullable: true
        next:
          type: string
          nullable: true

    Error:
      type: object
      properties:
        message:
          type: string
        errors:
          type: object

  responses:
    Unauthorized:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            message: Unauthenticated.

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            message: Resource not found.

    ValidationError:
      description: Validation error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            message: The given data was invalid.
            errors:
              field_name:
                - The field is required.
```

## Template README API

```markdown
# {PROJECT_NAME} API Documentation

## Base URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost/api` |
| Staging | `https://staging.example.com/api` |
| Production | `https://api.example.com` |

## Authentication

This API uses **Bearer Token** authentication via Laravel Sanctum.

### Get Token

```bash
curl -X POST {BASE_URL}/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'
```

### Use Token

```bash
curl -X GET {BASE_URL}/resource \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

## Endpoints

### {Resource}

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{resources}` | List all |
| POST | `/{resources}` | Create new |
| GET | `/{resources}/{id}` | Get by ID |
| PUT | `/{resources}/{id}` | Update |
| DELETE | `/{resources}/{id}` | Delete |

## Response Format

### Success

```json
{
  "data": { ... },
  "meta": { ... },
  "links": { ... }
}
```

### Error

```json
{
  "message": "Error description",
  "errors": {
    "field": ["Error message"]
  }
}
```

## Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (deleted) |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Validation Error |
| 500 | Server Error |
```

## Setup Swagger UI

```bash
# Installa swagger-ui
npm install swagger-ui-dist

# Oppure usa Docker
docker run -p 8080:8080 -e SWAGGER_JSON=/api/openapi.json \
  -v $(pwd)/docs/api:/api swaggerapi/swagger-ui
```

## Integrazione Laravel

```bash
# Package consigliato
composer require darkaonline/l5-swagger

# Pubblica config
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"

# Genera docs
php artisan l5-swagger:generate
```

## Comandi Utili

```bash
# Valida OpenAPI spec
npx @apidevtools/swagger-cli validate docs/api/openapi.yaml

# Genera client SDK
npx @openapitools/openapi-generator-cli generate \
  -i docs/api/openapi.yaml \
  -g typescript-fetch \
  -o sdk/
```
