<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Alerta</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e4e4e7;
            min-height: 100vh;
        }
        
        .container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 260px;
            background: rgba(26, 26, 46, 0.8);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(239, 68, 68, 0.1);
            padding: 2rem 0;
        }
        
        .logo {
            padding: 0 2rem 2rem;
            font-size: 1.5rem;
            font-weight: bold;
            color: #ef4444;
            border-bottom: 1px solid rgba(239, 68, 68, 0.1);
            margin-bottom: 2rem;
        }
        
        .nav-link {
            display: block;
            padding: 1rem 2rem;
            color: #e4e4e7;
            text-decoration: none;
            transition: all 0.3s;
            border-left: 3px solid transparent;
        }
        
        .nav-link:hover, .nav-link.active {
            background: rgba(239, 68, 68, 0.1);
            border-left-color: #ef4444;
            color: #fff;
        }
        
        .main-content {
            flex: 1;
            padding: 2rem;
            overflow-y: auto;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid rgba(239, 68, 68, 0.2);
        }
        
        h1 {
            font-size: 2rem;
            color: #fff;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: rgba(26, 26, 46, 0.6);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(239, 68, 68, 0.2);
            border-radius: 12px;
            padding: 1.5rem;
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            border-color: #ef4444;
        }
        
        .stat-label {
            color: #a1a1aa;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: #fff;
        }
        
        .card {
            background: rgba(26, 26, 46, 0.6);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(239, 68, 68, 0.2);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .card-header {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: #fff;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(239, 68, 68, 0.1);
        }
        
        th {
            color: #ef4444;
            font-weight: 600;
        }
        
        .btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.875rem;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #ef4444;
            color: white;
        }
        
        .btn-primary:hover {
            background: #dc2626;
        }
        
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .badge-success { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
        .badge-danger { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
        .badge-warning { background: rgba(245, 158, 11, 0.2); color: #f59e0b; }
    </style>
</head>
<body>
    <div class="container">
        <aside class="sidebar">
            <div class="logo">🛡️ Alert Admin</div>
            <nav>
                <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                    📊 Dashboard
                </a>
                <a href="{{ route('admin.users.index') }}" class="nav-link {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                    👥 Users
                </a>
                <a href="{{ route('admin.alerts.index') }}" class="nav-link {{ request()->routeIs('admin.alerts.*') ? 'active' : '' }}">
                    🚨 Alerts
                </a>
                <a href="{{ route('admin.alerts.active') }}" class="nav-link">
                    🔴 Active Alerts
                </a>
            </nav>
        </aside>
        
        <main class="main-content">
            @yield('content')
        </main>
    </div>
</body>
</html>
