<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PanicAlert;
use App\Services\NotificationService;
use Illuminate\Http\Request;

class PanicController extends Controller
{
    public function trigger(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'battery_level' => 'nullable|integer|min:0|max:100',
            'alert_type' => 'required|in:panic,silent,guardian,proactive',
            'is_duress' => 'nullable|boolean',
            'is_proactive' => 'nullable|boolean',
        ]);

        $alert = PanicAlert::create([
            'user_id' => $request->user()->id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'battery_level' => $request->battery_level,
            'alert_type' => $request->alert_type,
            'is_duress' => $request->is_duress ?? false,
            'is_proactive' => $request->is_proactive ?? false,
            'status' => 'active',
            'triggered_at' => now(),
        ]);

        // Smart Multi-Layer Notifications (Zero-Cost Focus)
        (new NotificationService())->sendEmergencyAlert($request->user(), $alert);

        return response()->json([
            'alert' => $alert,
            'message' => 'Emergency alert triggered successfully',
        ], 201);
    }

    public function heartbeat(Request $request)
    {
        $request->validate([
            'expires_at' => 'required|date|after:now',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        // Create or update a 'proactive' pending alert that will fire if not resolved
        $alert = PanicAlert::updateOrCreate(
            ['user_id' => $request->user()->id, 'status' => 'pending_proactive'],
            [
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'heartbeat_expires_at' => $request->expires_at,
                'is_proactive' => true,
                'alert_type' => 'proactive',
                'triggered_at' => now(),
            ]
        );

        return response()->json(['message' => 'Heartbeat received. Your safety is being monitored by the server.']);
    }

    public function resolve(Request $request, $id)
    {
        $alert = PanicAlert::findOrFail($id);

        // Ensure user owns this alert
        if ($alert->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $alert->update([
            'status' => 'resolved',
            'resolved_at' => now(),
            'notes' => $request->notes,
        ]);

        return response()->json([
            'alert' => $alert,
            'message' => 'Alert resolved successfully',
        ]);
    }

    public function history(Request $request)
    {
        $alerts = $request->user()
            ->panicAlerts()
            ->orderBy('triggered_at', 'desc')
            ->paginate(20);

        return response()->json($alerts);
    }

    public function active(Request $request)
    {
        $alert = $request->user()
            ->panicAlerts()
            ->active()
            ->latest('triggered_at')
            ->first();

        return response()->json([
            'alert' => $alert,
        ]);
    }
    protected function notifyAdmins(PanicAlert $alert)
    {
        // Broadcast event or send push notification to admin dashboard
    }

    protected function notifyTrustedContacts(PanicAlert $alert)
    {
        // Logic to send SMS via Prembly or other service
    }
}

