<?php

namespace App\Filament\Widgets;

use App\Models\PanicAlert;
use App\Models\GuardianSession;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Carbon\Carbon;

class CrisisMonitor extends BaseWidget
{
    protected static ?string $pollingInterval = '10s';

    protected function getStats(): array
    {
        $activePanics = PanicAlert::where('status', 'active')->count();
        $duressAlerts = PanicAlert::where('is_duress', true)->where('status', 'active')->count();
        $timedOutSessions = GuardianSession::where('status', 'active')
            ->where('expires_at', '<', now())
            ->count();

        return [
            Stat::make('Active SOS Calls', $activePanics)
                ->description('Emergency requests needing immediate attention')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color($activePanics > 0 ? 'danger' : 'success'),
            
            Stat::make('Duress Alarms', $duressAlerts)
                ->description('Silent alarms triggered by Duress PIN')
                ->descriptionIcon('heroicon-m-shield-exclamation')
                ->color($duressAlerts > 0 ? 'danger' : 'gray'),

            Stat::make('Session Timeouts', $timedOutSessions)
                ->description('Proactive alerts - User failed to check in')
                ->descriptionIcon('heroicon-m-clock')
                ->color($timedOutSessions > 0 ? 'warning' : 'success'),
        ];
    }
}
