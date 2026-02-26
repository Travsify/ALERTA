<?php

namespace App\Filament\Resources\TrustedContactResource\Pages;

use App\Filament\Resources\TrustedContactResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTrustedContacts extends ListRecords
{
    protected static string $resource = TrustedContactResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
