<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\PanicAlertResource;
use App\Models\PanicAlert;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestPanicAlerts extends BaseWidget
{
    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                PanicAlertResource::getEloquentQuery()
                    ->where('status', 'active')
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color('danger'),
                Tables\Columns\TextColumn::make('latitude')
                    ->label('Location')
                    ->formatStateUsing(fn ($record) => "Lat: {$record->latitude}, Lon: {$record->longitude}"),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->label('Triggered'),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->url(fn (PanicAlert $record): string => PanicAlertResource::getUrl('edit', ['record' => $record])),
            ]);
    }
}
