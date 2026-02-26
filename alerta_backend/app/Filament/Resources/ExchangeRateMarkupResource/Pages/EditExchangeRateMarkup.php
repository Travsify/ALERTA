<?php

namespace App\Filament\Resources\ExchangeRateMarkupResource\Pages;

use App\Filament\Resources\ExchangeRateMarkupResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditExchangeRateMarkup extends EditRecord
{
    protected static string $resource = ExchangeRateMarkupResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
