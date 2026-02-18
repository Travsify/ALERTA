<?php

namespace App\Filament\Resources\ThreatReportResource\Pages;

use App\Filament\Resources\ThreatReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditThreatReport extends EditRecord
{
    protected static string $resource = ThreatReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
