<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\PanicAlert;
use App\Models\PaymentTransaction;
use App\Models\ThreatReport;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('is_active', true)->count(),
            'premium_users' => User::where('subscription_tier', 'premium')->count(),
            'active_alerts' =>PanicAlert::active()->count(),
            'total_alerts_today' => PanicAlert::whereDate('triggered_at', today())->count(),
            'total_revenue' => PaymentTransaction::successful()->sum('amount') / 100, // Convert from kobo
            'pending_threats' => ThreatReport::where('status', 'pending')->count(),
        ];

        $recentAlerts = PanicAlert::with('user:id,name,email')
            ->active()
            ->latest('triggered_at')
            ->take(10)
            ->get();

        $recentUsers = User::latest('created_at')
            ->take(10)
            ->get();

        return view('admin.dashboard', compact('stats', 'recentAlerts', 'recentUsers'));
    }
}
