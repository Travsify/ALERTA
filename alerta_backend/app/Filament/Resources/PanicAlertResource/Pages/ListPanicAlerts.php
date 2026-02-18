<?php

namespace App\Filament\Resources\PanicAlertResource\Pages;

use App\Filament\Resources\PanicAlertResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPanicAlerts extends ListRecords
{
    protected static string $resource = PanicAlertResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
