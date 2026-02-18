<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load('medicalId'),
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $request->user()->id,
            'phone' => 'sometimes|string|unique:users,phone,' . $request->user()->id,
        ]);

        $request->user()->update($request->only(['name', 'email', 'phone']));

        return response()->json([
            'user' => $request->user()->fresh(),
            'message' => 'Profile updated successfully',
        ]);
    }

    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'password' => 'required|string|min:4|confirmed',
        ]);

        if (!Hash::check($request->current_password, $request->user()->password)) {
            return response()->json([
                'message' => 'Current password is incorrect',
            ], 422);
        }

        $request->user()->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Password updated successfully',
        ]);
    }

    public function updateDuressPin(Request $request)
    {
        $request->validate([
            'duress_pin' => 'required|string|min:4',
        ]);

        $request->user()->update([
            'duress_pin_hash' => Hash::make($request->duress_pin),
        ]);

        return response()->json([
            'message' => 'Duress PIN updated successfully',
        ]);
    }

    public function updateMedicalId(Request $request)
    {
        $request->validate([
            'blood_type' => 'nullable|string',
            'allergies' => 'nullable|array',
            'medications' => 'nullable|array',
            'conditions' => 'nullable|array',
            'emergency_contact_name' => 'nullable|string',
            'emergency_contact_phone' => 'nullable|string',
        ]);

        $medicalId = $request->user()->medicalId()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $request->all()
        );

        return response()->json([
            'medical_id' => $medicalId,
            'message' => 'Medical ID updated successfully',
        ]);
    }
}
