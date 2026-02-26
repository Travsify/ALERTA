<?php

namespace App\Filament\Resources\ExchangeRateMarkupResource\Pages;

use App\Filament\Resources\ExchangeRateMarkupResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListExchangeRateMarkups extends ListRecords
{
    protected static string $resource = ExchangeRateMarkupResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
