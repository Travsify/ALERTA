<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PanicAlert;
use Illuminate\Http\Request;

class PanicController extends Controller
{
    public function trigger(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'battery_level' => 'nullable|integer|min:0|max:100',
            'alert_type' => 'required|in:panic,silent,guardian',
            'is_duress' => 'nullable|boolean',
        ]);

        $alert = PanicAlert::create([
            'user_id' => $request->user()->id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'battery_level' => $request->battery_level,
            'alert_type' => $request->alert_type,
            'is_duress' => $request->is_duress ?? false,
            'status' => 'active',
            'triggered_at' => now(),
        ]);

        // TODO: Send real-time notifications to admins
        // TODO: Send SMS to trusted contacts
        // TODO: Trigger emergency response system

        return response()->json([
            'alert' => $alert,
            'message' => 'Emergency alert triggered successfully',
        ], 201);
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
}
