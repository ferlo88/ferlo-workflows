---
name: ferlo-api
description: This skill generates REST API endpoints, controllers, resources and documentation for Laravel. Use when user asks for "create api", "api endpoint", "rest api", "api resource", "api controller", "json response", or "api documentation".
version: 1.0.0
---

# API Development Workflow

Genera API REST seguendo le best practices Laravel.

## API Controller

### Creazione
```bash
php artisan make:controller Api/ProductController --api --model=Product
```

### Struttura Standard
```php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $products = Product::query()
            ->with(['category', 'user'])
            ->when(request('search'), fn ($q, $search) =>
                $q->where('name', 'like', "%{$search}%")
            )
            ->when(request('category_id'), fn ($q, $categoryId) =>
                $q->where('category_id', $categoryId)
            )
            ->when(request('status'), fn ($q, $status) =>
                $q->where('status', $status)
            )
            ->latest()
            ->paginate(request('per_page', 15));

        return ProductResource::collection($products);
    }

    public function store(StoreProductRequest $request): ProductResource
    {
        $product = Product::create($request->validated());

        return new ProductResource($product->load(['category', 'user']));
    }

    public function show(Product $product): ProductResource
    {
        return new ProductResource($product->load(['category', 'user', 'reviews']));
    }

    public function update(UpdateProductRequest $request, Product $product): ProductResource
    {
        $product->update($request->validated());

        return new ProductResource($product->fresh(['category', 'user']));
    }

    public function destroy(Product $product): JsonResponse
    {
        $product->delete();

        return response()->json(['message' => 'Product deleted successfully']);
    }
}
```

## API Resources

### Creazione
```bash
php artisan make:resource ProductResource
php artisan make:resource ProductCollection
```

### Resource Standard
```php
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => [
                'amount' => $this->price,
                'formatted' => number_format($this->price, 2, ',', '.') . ' €',
            ],
            'status' => $this->status,
            'is_featured' => $this->is_featured,

            // Relazioni condizionali
            'category' => new CategoryResource($this->whenLoaded('category')),
            'user' => new UserResource($this->whenLoaded('user')),
            'reviews' => ReviewResource::collection($this->whenLoaded('reviews')),
            'reviews_count' => $this->whenCounted('reviews'),

            // Date
            'published_at' => $this->published_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Links
            'links' => [
                'self' => route('api.products.show', $this),
                'edit' => route('api.products.update', $this),
            ],
        ];
    }
}
```

## Form Requests

### Creazione
```bash
php artisan make:request StoreProductRequest
php artisan make:request UpdateProductRequest
```

### Validazione API
```php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // O logica authorization
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', 'unique:products'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'category_id' => ['required', 'exists:categories,id'],
            'status' => ['required', 'in:draft,published,archived'],
            'is_featured' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Il nome è obbligatorio',
            'price.min' => 'Il prezzo non può essere negativo',
        ];
    }

    // Override per response JSON
    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(response()->json([
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

## Routes API

### routes/api.php
```php
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\AuthController;

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    Route::apiResource('products', ProductController::class);
    Route::apiResource('categories', CategoryController::class);
});
```

## Error Handling

### Risposte Consistenti
```php
// app/Exceptions/Handler.php
public function render($request, Throwable $e)
{
    if ($request->expectsJson()) {
        if ($e instanceof ModelNotFoundException) {
            return response()->json([
                'message' => 'Resource not found',
            ], 404);
        }

        if ($e instanceof AuthenticationException) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }
    }

    return parent::render($request, $e);
}
```

## API Documentation

Genera documentazione con commenti:
```php
/**
 * @group Products
 *
 * APIs for managing products
 */
class ProductController extends Controller
{
    /**
     * List all products
     *
     * @queryParam search string Filter by name. Example: laptop
     * @queryParam category_id int Filter by category. Example: 1
     * @queryParam per_page int Items per page. Example: 15
     *
     * @response 200 {
     *   "data": [...],
     *   "links": {...},
     *   "meta": {...}
     * }
     */
    public function index() { }
}
```
