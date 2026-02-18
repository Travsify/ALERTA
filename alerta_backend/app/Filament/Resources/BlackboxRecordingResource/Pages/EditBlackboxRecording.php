<?php

namespace App\Filament\Resources\BlackboxRecordingResource\Pages;

use App\Filament\Resources\BlackboxRecordingResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditBlackboxRecording extends EditRecord
{
    protected static string $resource = BlackboxRecordingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
