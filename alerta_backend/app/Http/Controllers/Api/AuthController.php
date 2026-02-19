<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:8',
            'duress_pin' => 'nullable|string|min:4', // PINs are usually 4 digits, keeping it for now
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'duress_pin_hash' => $request->duress_pin ? Hash::make($request->duress_pin) : null,
            'trial_started_at' => now(), // Start trial immediately
        ]);

        $token = $user->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Check if account is suspended
        if ($user->is_suspended) {
            return response()->json([
                'message' => 'Your account has been suspended. Please contact support.',
            ], 403);
        }

        // Check if it's a duress PIN
        $isDuress = false;
        if ($user->duress_pin_hash && Hash::check($request->password, $user->duress_pin_hash)) {
            $isDuress = true;
        } elseif (!Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'is_duress' => $isDuress,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    public function user(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load('medicalId'),
            'subscription' => [
                'tier' => $request->user()->subscription_tier,
                'is_premium' => $request->user()->isPremium(),
                'is_trial_active' => $request->user()->isTrialActive(),
                'days_remaining' => $request->user()->daysRemaining(),
                'expires_at' => $request->user()->subscription_expires_at,
            ],
        ]);
    }
}
