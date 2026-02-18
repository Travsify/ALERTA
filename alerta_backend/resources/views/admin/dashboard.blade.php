@extends('admin.layout')

@section('title', 'Dashboard')

@section('content')
<div class="header">
    <h1>Dashboard</h1>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Total Users</div>
        <div class="stat-value">{{ $stats['total_users'] }}</div>
    </div>
    
    <div class="stat-card">
        <div class="stat-label">Premium Users</div>
        <div class="stat-value">{{ $stats['premium_users'] }}</div>
    </div>
    
    <div class="stat-card">
        <div class="stat-label">Active Alerts</div>
        <div class="stat-value">{{ $stats['active_alerts'] }}</div>
    </div>
    
    <div class="stat-card">
        <div class="stat-label">Alerts Today</div>
        <div class="stat-value">{{ $stats['total_alerts_today'] }}</div>
    </div>
    
    <div class="stat-card">
        <div class="stat-label">Total Revenue</div>
        <div class="stat-value">₦{{ number_format($stats['total_revenue'], 2) }}</div>
    </div>
    
    <div class="stat-card">
        <div class="stat-label">Pending Threats</div>
        <div class="stat-value">{{ $stats['pending_threats'] }}</div>
    </div>
</div>

<div class="card">
    <div class="card-header">Active Panic Alerts</div>
    
    @if($recentAlerts->count() > 0)
        <table>
            <thead>
                <tr>
                    <th>User</th>
                    <th>Type</th>
                    <th>Location</th>
                    <th>Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @foreach($recentAlerts as $alert)
                <tr>
                    <td>
                        <strong>{{ $alert->user->name }}</strong><br>
                        <small>{{ $alert->user->email }}</small>
                    </td>
                    <td>
                        @if($alert->is_duress)
                            <span class="badge badge-danger">🔴 DURESS</span>
                        @else
                            <span class="badge badge-warning">{{ strtoupper($alert->alert_type) }}</span>
                        @endif
                    </td>
                    <td>
                        <a href="https://www.google.com/maps/search/?api=1&query={{ $alert->latitude }},{{ $alert->longitude }}" target="_blank">
                            📍 {{ $alert->latitude }}, {{ $alert->longitude }}
                        </a>
                    </td>
                    <td>{{ $alert->triggered_at->diffForHumans() }}</td>
                    <td><span class="badge badge-danger">ACTIVE</span></td>
                </tr>
                @endforeach
            </tbody>
        </table>
    @else
        <p style="color: #a1a1aa; padding: 2rem; text-align: center;">No active alerts</p>
    @endif
</div>

<div class="card">
    <div class="card-header">Recent Users</div>
    
    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Subscription</th>
                <th>Joined</th>
            </tr>
        </thead>
        <tbody>
            @foreach($recentUsers as $user)
            <tr>
                <td>{{ $user->name }}</td>
                <td>{{ $user->email }}</td>
                <td>{{ $user->phone }}</td>
                <td>
                    @if($user->subscription_tier === 'premium')
                        <span class="badge badge-success">PREMIUM</span>
                    @else
                        <span class="badge">FREE</span>
                    @endif
                </td>
                <td>{{ $user->created_at->format('M d, Y') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
