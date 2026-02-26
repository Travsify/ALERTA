<?php

namespace App\Filament\Resources\MedicalIdResource\Pages;

use App\Filament\Resources\MedicalIdResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListMedicalIds extends ListRecords
{
    protected static string $resource = MedicalIdResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
