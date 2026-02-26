<?php

namespace App\Filament\Resources\CmsBannerResource\Pages;

use App\Filament\Resources\CmsBannerResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCmsBanner extends EditRecord
{
    protected static string $resource = CmsBannerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
