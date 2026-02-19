<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LocationShare;
use Illuminate\Http\Request;

/**
 * @group Location Sharing
 *
 * APIs for real-time location sharing and tracking during active alerts.
 */
class LocationController extends Controller
{
    public function start(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'duration_minutes' => 'nullable|integer|min:5|max:480',
            'update_interval_minutes' => 'nullable|integer|min:1|max:60',
        ]);

        $durationMinutes = $request->duration_minutes ?? 30;

        $locationShare = LocationShare::create([
            'user_id' => $request->user()->id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'status' => 'active',
            'started_at' => now(),
            'expires_at' => now()->addMinutes($durationMinutes),
            'update_interval_minutes' => $request->update_interval_minutes ?? 5,
        ]);

        return response()->json([
            'location_share' => $locationShare,
            'message' => 'Location sharing started',
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $locationShare = LocationShare::findOrFail($id);

        // Ensure user owns this location share
        if ($locationShare->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $locationShare->update([
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return response()->json([
            'location_share' => $locationShare,
            'message' => 'Location updated',
        ]);
    }

    public function stop(Request $request, $id)
    {
        $locationShare = LocationShare::findOrFail($id);

        // Ensure user owns this location share
        if ($locationShare->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $locationShare->update([
            'status' => 'stopped',
        ]);

        return response()->json([
            'message' => 'Location sharing stopped',
        ]);
    }

    public function active(Request $request)
    {
        $locationShare = $request->user()
            ->locationShares()
            ->active()
            ->latest('started_at')
            ->first();

        return response()->json([
            'location_share' => $locationShare,
        ]);
    }
}
