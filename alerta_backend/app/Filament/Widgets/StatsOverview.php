<?php

namespace App\Filament\Widgets;

use App\Models\PanicAlert;
use App\Models\PaymentTransaction;
use App\Models\User;
use Filament\Support\Enums\IconPosition;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('Active Panic Alerts', PanicAlert::where('status', 'active')->count())
                ->description('Current unresolved alerts')
                ->descriptionIcon('heroicon-m-fire', IconPosition::Before)
                ->color('danger')
                ->chart([7, 2, 10, 3, 15, 4, 17]),

            Stat::make('Total Verified Users', User::count())
                ->description('Total platform reach')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),

            Stat::make('Total Revenue', '₦' . number_format(PaymentTransaction::where('status', 'success')->sum('amount') / 100, 2))
                ->description('Total successful payments')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('primary'),
        ];
    }
}
