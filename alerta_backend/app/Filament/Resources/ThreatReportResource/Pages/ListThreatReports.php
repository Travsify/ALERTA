<?php

namespace App\Filament\Resources\ThreatReportResource\Pages;

use App\Filament\Resources\ThreatReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListThreatReports extends ListRecords
{
    protected static string $resource = ThreatReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
