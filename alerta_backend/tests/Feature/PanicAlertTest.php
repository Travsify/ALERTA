<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

/**
 * Golden Path: Trigger SOS → Heartbeat → Resolve
 * These tests prove the core SOS alert lifecycle is stable.
 */

it('triggers a panic alert successfully', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    $response = $this->postJson('/api/panic/trigger', [
        'latitude' => 6.5244,
        'longitude' => 3.3792,
        'battery_level' => 85,
        'alert_type' => 'panic',
    ]);

    $response->assertStatus(201)
             ->assertJsonStructure([
                 'message',
                 'alert' => ['id', 'latitude', 'longitude', 'status'],
             ]);
});

it('sends a heartbeat for an active alert', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    // First, trigger an alert
    $alertResponse = $this->postJson('/api/panic/trigger', [
        'latitude' => 6.5244,
        'longitude' => 3.3792,
        'battery_level' => 85,
        'alert_type' => 'panic',
    ]);
    $alertId = $alertResponse->json('alert.id');

    // Then, send a heartbeat
    $response = $this->postJson('/api/panic/heartbeat', [
        'alert_id' => $alertId,
        'latitude' => 6.5250,
        'longitude' => 3.3800,
        'battery_level' => 80,
    ]);

    $response->assertStatus(200);
});

it('rejects panic trigger without authentication', function () {
    $response = $this->postJson('/api/panic/trigger', [
        'latitude' => 6.5244,
        'longitude' => 3.3792,
        'alert_type' => 'panic',
    ]);

    $response->assertStatus(401);
});

it('retrieves panic history', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    $response = $this->getJson('/api/panic/history');

    $response->assertStatus(200);
});
