<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PanicAlert;
use Illuminate\Http\Request;

class MeshRelayController extends Controller
{
    /**
     * Store a relayed SOS alert from another user.
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'battery_level' => 'required|integer',
            'alert_type' => 'required|string',
            'is_duress' => 'required|boolean',
            'mesh_id' => 'required|string',
            'relayed_at' => 'required|date',
        ]);

        // Check if this mesh_id alert already exists to prevent duplicates
        $existing = PanicAlert::where('notes', 'LIKE', "%MeshID: {$request->mesh_id}%")->first();
        if ($existing) {
            return response()->json(['message' => 'Alert already relayed'], 200);
        }

        $panicAlert = PanicAlert::create([
            'user_id' => $request->user_id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'battery_level' => $request->battery_level,
            'alert_type' => $request->alert_type,
            'is_duress' => $request->is_duress,
            'is_mesh' => true,
            'relayed_by_id' => $request->user()->id,
            'status' => 'pending',
            'triggered_at' => $request->relayed_at,
            'notes' => "Relayed via Mesh. MeshID: {$request->mesh_id}. Relayed by User: " . $request->user()->name,
        ]);

        return response()->json([
            'message' => 'Mesh SOS Relayed successfully',
            'alert' => $panicAlert,
        ], 201);
    }
}
