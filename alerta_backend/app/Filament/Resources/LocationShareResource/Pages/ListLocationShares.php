<?php

namespace App\Filament\Resources\LocationShareResource\Pages;

use App\Filament\Resources\LocationShareResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListLocationShares extends ListRecords
{
    protected static string $resource = LocationShareResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
