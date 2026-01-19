---
name: ferlo-filament
description: This skill generates Filament resources, pages, widgets and components following EXTRAWEB conventions. Use when user asks for "create filament resource", "filament page", "filament widget", "admin panel", "CRUD filament", "filament form", or "filament table".
version: 1.0.0
---

# Filament Development Workflow

Genera componenti Filament seguendo le convenzioni EXTRAWEB.

## Resource Generation

### 1. Analisi Model
Prima di generare una resource, analizza il model:
- Campi fillable
- Relazioni (belongsTo, hasMany, etc.)
- Casts e accessors
- Soft deletes

### 2. Genera Resource
```bash
php artisan make:filament-resource NomeModel --generate
```

### 3. Personalizza Form Schema
```php
public static function form(Form $form): Form
{
    return $form->schema([
        Forms\Components\Section::make('Informazioni Principali')
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Nome'),

                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->required()
                    ->label('Utente'),

                Forms\Components\RichEditor::make('description')
                    ->columnSpanFull()
                    ->label('Descrizione'),
            ])->columns(2),

        Forms\Components\Section::make('Dettagli')
            ->schema([
                Forms\Components\Toggle::make('is_active')
                    ->default(true)
                    ->label('Attivo'),

                Forms\Components\DatePicker::make('published_at')
                    ->label('Data Pubblicazione'),
            ])->columns(2),
    ]);
}
```

### 4. Personalizza Table
```php
public static function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name')
                ->searchable()
                ->sortable()
                ->label('Nome'),

            Tables\Columns\TextColumn::make('user.name')
                ->searchable()
                ->sortable()
                ->label('Utente'),

            Tables\Columns\IconColumn::make('is_active')
                ->boolean()
                ->label('Attivo'),

            Tables\Columns\TextColumn::make('created_at')
                ->dateTime('d/m/Y H:i')
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true)
                ->label('Creato il'),
        ])
        ->filters([
            Tables\Filters\TernaryFilter::make('is_active')
                ->label('Stato'),

            Tables\Filters\SelectFilter::make('user_id')
                ->relationship('user', 'name')
                ->label('Utente'),
        ])
        ->actions([
            Tables\Actions\ViewAction::make(),
            Tables\Actions\EditAction::make(),
            Tables\Actions\DeleteAction::make(),
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
            ]),
        ]);
}
```

## Convenzioni EXTRAWEB

### Navigation
```php
protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
protected static ?string $navigationGroup = 'Gestione';
protected static ?int $navigationSort = 1;

public static function getNavigationBadge(): ?string
{
    return static::getModel()::count();
}
```

### Labels Italiani
```php
public static function getModelLabel(): string
{
    return 'Risorsa';
}

public static function getPluralModelLabel(): string
{
    return 'Risorse';
}
```

### Soft Deletes
Se il model usa SoftDeletes:
```php
public static function table(Table $table): Table
{
    return $table
        // ...
        ->filters([
            Tables\Filters\TrashedFilter::make(),
        ])
        ->actions([
            Tables\Actions\RestoreAction::make(),
            Tables\Actions\ForceDeleteAction::make(),
        ]);
}
```

## Widget Generation

```php
php artisan make:filament-widget StatsOverview --stats-overview
```

```php
protected function getStats(): array
{
    return [
        Stat::make('Totale', Model::count())
            ->description('Tutti i record')
            ->descriptionIcon('heroicon-m-arrow-trending-up')
            ->color('success'),

        Stat::make('Attivi', Model::where('is_active', true)->count())
            ->description('Record attivi')
            ->color('info'),

        Stat::make('Questo mese', Model::whereMonth('created_at', now()->month)->count())
            ->description('Nuovi questo mese')
            ->color('warning'),
    ];
}
```

## Page Personalizzate

```bash
php artisan make:filament-page Dashboard
```

Per pagine con form custom, charts, o logica speciale.
