<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use App\Http\Controllers\Api\Admin;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/
Route::post('get-customer',[Admin::class,'getCustomer']);

Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});

/*
|--------------------------------------------------------------------------
| Health Check Endpoint
|--------------------------------------------------------------------------
| Used by CI/CD pipeline to verify deployment success
*/
Route::get('/health', function () {
    $health = [
        'status' => 'healthy',
        'timestamp' => now()->toIso8601String(),
        'app_name' => config('app.name'),
        'environment' => config('app.env'),
        'checks' => []
    ];

    $allHealthy = true;

    // Check Database Connection
    try {
        DB::connection()->getPdo();
        $health['checks']['database'] = [
            'status' => 'ok',
            'connection' => config('database.default')
        ];
    } catch (\Exception $e) {
        $health['checks']['database'] = [
            'status' => 'error',
            'message' => 'Database connection failed'
        ];
        $allHealthy = false;
    }

    // Check Cache
    try {
        Cache::put('health_check', true, 10);
        $cacheWorking = Cache::get('health_check');
        $health['checks']['cache'] = [
            'status' => $cacheWorking ? 'ok' : 'error',
            'driver' => config('cache.default')
        ];
        if (!$cacheWorking) $allHealthy = false;
    } catch (\Exception $e) {
        $health['checks']['cache'] = [
            'status' => 'error',
            'message' => 'Cache not working'
        ];
        $allHealthy = false;
    }

    // Check Storage
    try {
        $storagePath = storage_path('app');
        $health['checks']['storage'] = [
            'status' => is_writable($storagePath) ? 'ok' : 'error',
            'writable' => is_writable($storagePath)
        ];
        if (!is_writable($storagePath)) $allHealthy = false;
    } catch (\Exception $e) {
        $health['checks']['storage'] = [
            'status' => 'error',
            'message' => 'Storage check failed'
        ];
        $allHealthy = false;
    }

    // Overall status
    $health['status'] = $allHealthy ? 'healthy' : 'unhealthy';

    return response()->json($health, $allHealthy ? 200 : 503);
});

/*
|--------------------------------------------------------------------------
| Simple ping endpoint for basic connectivity check
|--------------------------------------------------------------------------
*/
Route::get('/ping', function () {
    return response()->json([
        'pong' => true,
        'timestamp' => now()->toIso8601String()
    ]);
});
