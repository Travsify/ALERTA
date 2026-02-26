<?php

namespace App\Filament\Resources\ServiceMarkupResource\Pages;

use App\Filament\Resources\ServiceMarkupResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditServiceMarkup extends EditRecord
{
    protected static string $resource = ServiceMarkupResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
