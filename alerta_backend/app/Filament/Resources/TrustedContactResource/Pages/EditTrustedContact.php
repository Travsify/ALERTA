<?php

namespace App\Filament\Resources\TrustedContactResource\Pages;

use App\Filament\Resources\TrustedContactResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditTrustedContact extends EditRecord
{
    protected static string $resource = TrustedContactResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
