<?php

namespace App\Filament\Resources\VehicleReportResource\Pages;

use App\Filament\Resources\VehicleReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditVehicleReport extends EditRecord
{
    protected static string $resource = VehicleReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
