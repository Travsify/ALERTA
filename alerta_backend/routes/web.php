<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\AlertController;

/*
|--------------------------------------------------------------------------
| Web Routes - Admin Panel
|--------------------------------------------------------------------------
*/

// Health check - NO middleware, pure PHP response
Route::get('/health', function () {
    // dd(config('app')); // Uncomment if we still get 500
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
        'php' => PHP_VERSION,
        'laravel' => app()->version(),
        'env' => app()->environment(),
        'debug' => config('app.debug'),
        'key_set' => !empty(config('app.key')),
        'key_prefix' => substr(config('app.key') ?? '', 0, 7),
    ]);
})->withoutMiddleware('*');

// DB check - test database connection
Route::get('/debug-db', function () {
    try {
        $pdo = \DB::connection()->getPdo();
        $tables = \DB::select("SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'public'");
        return response()->json([
            'status' => 'connected',
            'driver' => config('database.default'),
            'host' => config('database.connections.pgsql.host'),
            'database' => config('database.connections.pgsql.database'),
            'tables' => count($tables),
            'table_names' => array_map(fn($t) => $t->tablename, $tables),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
        ], 500);
    }
})->withoutMiddleware('*');

Route::get('/', function () {
    return redirect('/admin');
});

