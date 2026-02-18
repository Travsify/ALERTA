<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ThreatReport;
use Illuminate\Http\Request;

class ThreatRadarController extends Controller
{
    public function nearby(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'nullable|integer|min:100|max:10000',
        ]);

        $radius = $request->radius ?? 5000;

        $threats = ThreatReport::verified()
            ->nearby($request->latitude, $request->longitude, $radius)
            ->get();

        return response()->json($threats);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius_meters' => 'nullable|integer|min:100|max:2000',
            'type' => 'required|in:danger,checkpoint,accident,other',
            'severity' => 'nullable|in:low,medium,high,critical',
        ]);

        $threat = ThreatReport::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'description' => $request->description,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'radius_meters' => $request->radius_meters ?? 500,
            'type' => $request->type,
            'severity' => $request->severity ?? 'medium',
            'status' => 'pending',
            'verification_count' => 0,
        ]);

        return response()->json([
            'threat' => $threat,
            'message' => 'Threat report submitted successfully',
        ], 201);
    }

    public function verify(Request $request, $id)
    {
        $threat = ThreatReport::findOrFail($id);
        
        $threat->incrementVerification();

        return response()->json([
            'threat' => $threat->fresh(),
            'message' => 'Threat verification recorded',
        ]);
    }

    public function index(Request $request)
    {
        $threats = ThreatReport::with('user:id,name')
            ->orderBy('created_at', 'desc')
            ->paginate(50);

        return response()->json($threats);
    }
}
