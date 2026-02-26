<?php

namespace App\Filament\Resources\CmsBannerResource\Pages;

use App\Filament\Resources\CmsBannerResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCmsBanners extends ListRecords
{
    protected static string $resource = CmsBannerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
