<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query();

        // Search
        if ($request->search) {
            $query->where(function($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                  ->orWhere('email', 'like', "%{$request->search}%")
                  ->orWhere('phone', 'like', "%{$request->search}%");
            });
        }

        // Filter by subscription
        if ($request->subscription) {
            $query->where('subscription_tier', $request->subscription);
        }

        // Filter by status
        if ($request->status === 'active') {
            $query->where('is_active', true)->where('is_suspended', false);
        } elseif ($request->status === 'suspended') {
            $query->where('is_suspended', true);
        }

        $users = $query->withCount('panicAlerts', 'trustedContacts')
            ->latest('created_at')
            ->paginate(20);

        return view('admin.users.index', compact('users'));
    }

    public function show($id)
    {
        $user = User::with([
            'trustedContacts',
            'panicAlerts' => fn($q) => $q->latest('triggered_at')->take(10),
            'paymentTransactions' => fn($q) => $q->latest('created_at')->take(5),
            'medicalId'
        ])->findOrFail($id);

        return view('admin.users.show', compact('user'));
    }

    public function suspend($id)
    {
        $user = User::findOrFail($id);
        $user->update(['is_suspended' => true, 'is_active' => false]);

        return redirect()->back()->with('success', 'User suspended successfully');
    }

    public function activate($id)
    {
        $user = User::findOrFail($id);
        $user->update(['is_suspended' => false, 'is_active' => true]);

        return redirect()->back()->with('success', 'User activated successfully');
    }
}
