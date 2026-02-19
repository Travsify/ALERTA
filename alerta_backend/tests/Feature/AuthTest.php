<?php

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

/**
 * Golden Path: User Registration → Login → Token Handling
 * These tests prove the core authentication flow is stable.
 */

it('registers a new user successfully', function () {
    $response = $this->postJson('/api/register', [
        'name' => 'Test User',
        'email' => 'test@alerta.ng',
        'phone' => '+2348000000001',
        'password' => 'Secure@2026!',
    ]);

    $response->assertStatus(201)
             ->assertJsonStructure([
                 'user' => ['id', 'name', 'email', 'phone'],
                 'token',
             ]);
});

it('rejects registration with weak password', function () {
    $response = $this->postJson('/api/register', [
        'name' => 'Test User',
        'email' => 'weak@alerta.ng',
        'phone' => '+2348000000002',
        'password' => '1234', // Too short — min:8
    ]);

    $response->assertStatus(422)
             ->assertJsonValidationErrors('password');
});

it('logs in an existing user and returns a token', function () {
    // Create a user first
    \App\Models\User::factory()->create([
        'email' => 'login@alerta.ng',
        'password' => bcrypt('Secure@2026!'),
    ]);

    $response = $this->postJson('/api/login', [
        'email' => 'login@alerta.ng',
        'password' => 'Secure@2026!',
    ]);

    $response->assertStatus(200)
             ->assertJsonStructure(['user', 'token']);
});

it('rejects login with invalid credentials', function () {
    $response = $this->postJson('/api/login', [
        'email' => 'nobody@alerta.ng',
        'password' => 'WrongPassword!',
    ]);

    $response->assertStatus(401);
});
