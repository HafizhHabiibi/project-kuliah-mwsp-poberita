<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthenticationController;
use App\Http\Controllers\API\BeritaController;
use App\Http\Controllers\API\KomentarController;

// ----------- Public Routes (tanpa login) -------------- //
Route::post('/register', [AuthenticationController::class, 'register']);
Route::post('/login', [AuthenticationController::class, 'login']);

// ------------- Protected Routes (butuh token) --------- //
Route::middleware('auth:api')->group(function () {

    // Auth
    Route::get('/get-user', [AuthenticationController::class, 'userInfo']);
    Route::post('/logout', [AuthenticationController::class, 'logOut']);

    // ---------------- CRUD BERITA ---------------- //
    Route::get('/berita', [BeritaController::class, 'index']);
    Route::post('/berita', [BeritaController::class, 'store']);
    Route::get('/berita/{id}', [BeritaController::class, 'show']);
    Route::put('/berita/{id}', [BeritaController::class, 'update']);
    Route::delete('/berita/{id}', [BeritaController::class, 'destroy']);

    // ---------------- KOMENTAR ---------------- //
    Route::post('/komentar', [KomentarController::class, 'store']);
    Route::delete('/komentar/{id}', [KomentarController::class, 'destroy']);
});