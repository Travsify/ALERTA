<?php

namespace App\Filament\Resources\BlackboxRecordingResource\Pages;

use App\Filament\Resources\BlackboxRecordingResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListBlackboxRecordings extends ListRecords
{
    protected static string $resource = BlackboxRecordingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
