<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PanicAlert;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function index(Request $request)
    {
        $query = PanicAlert::with('user:id,name,email,phone');

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by type
        if ($request->type) {
            $query->where('alert_type', $request->type);
        }

        // Filter by date range
        if ($request->from_date) {
            $query->where('triggered_at', '>=', $request->from_date);
        }
        if ($request->to_date) {
            $query->where('triggered_at', '<=', $request->to_date);
        }

        $alerts = $query->latest('triggered_at')->paginate(50);

        return view('admin.alerts.index', compact('alerts'));
    }

    public function active()
    {
        $alerts = PanicAlert::with('user:id,name,email,phone')
            ->active()
            ->latest('triggered_at')
            ->get();

        return view('admin.alerts.active', compact('alerts'));
    }

    public function markFalse($id)
    {
        $alert = PanicAlert::findOrFail($id);
        $alert->update(['status' => 'false_alarm', 'resolved_at' => now()]);

        return redirect()->back()->with('success', 'Alert marked as false alarm');
    }
}
