<?php

namespace App\Filament\Resources\GuardianSessionResource\Pages;

use App\Filament\Resources\GuardianSessionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListGuardianSessions extends ListRecords
{
    protected static string $resource = GuardianSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
