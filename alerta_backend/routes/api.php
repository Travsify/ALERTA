<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PanicController;
use App\Http\Controllers\Api\MeshRelayController;
use App\Http\Controllers\Api\ThreatRadarController;
use App\Http\Controllers\Api\ContactController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Authentication
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Panic Alerts
    Route::prefix('panic')->group(function () {
        Route::post('/trigger', [PanicController::class, 'trigger']);
        Route::post('/heartbeat', [PanicController::class, 'heartbeat']);
        Route::post('/{id}/resolve', [PanicController::class, 'resolve']);
        Route::get('/history', [PanicController::class, 'history']);
        Route::get('/active', [PanicController::class, 'active']);
    });
    
    // Trusted Contacts
    Route::apiResource('contacts', ContactController::class);
    
    // Threat Radar
    Route::prefix('threats')->group(function () {
        Route::get('/nearby', [ThreatRadarController::class, 'nearby']);
        Route::get('/', [ThreatRadarController::class, 'index']);
        Route::post('/', [ThreatRadarController::class, 'store']);
        Route::post('/{id}/verify', [ThreatRadarController::class, 'verify']);
    });
    
    // Mesh SOS Relay (Cross-User)
    Route::post('/mesh-relay', [MeshRelayController::class, 'store']);
    
    // Location Sharing
    Route::prefix('location')->group(function () {
        Route::post('/start', [LocationController::class, 'start']);
        Route::put('/{id}/update', [LocationController::class, 'update']);
        Route::post('/{id}/stop', [LocationController::class, 'stop']);
        Route::get('/active', [LocationController::class, 'active']);
    });
    
    // Subscription
    Route::prefix('subscription')->group(function () {
        Route::get('/status', [SubscriptionController::class, 'status']);
        Route::post('/verify-payment', [SubscriptionController::class, 'verifyPayment']);
        Route::get('/transactions', [SubscriptionController::class, 'transactions']);
    });
    
    // Profile
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
        Route::put('/password', [ProfileController::class, 'updatePassword']);
        Route::put('/duress-pin', [ProfileController::class, 'updateDuressPin']);
        Route::put('/medical-id', [ProfileController::class, 'updateMedicalId']);
        Route::post('/fcm-token', [ProfileController::class, 'updateFcmToken']);
    });
});
