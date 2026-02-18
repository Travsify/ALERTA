<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SafetyTimelineRelationManager extends RelationManager
{
    protected static string $relationship = 'panicAlerts';

    protected static ?string $title = 'User Safety Dossier (Incident History)';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('alert_type')
                    ->required()
                    ->maxLength(255),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('alert_type')
            ->columns([
                Tables\Columns\TextColumn::make('triggered_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Incident Time'),
                Tables\Columns\TextColumn::make('alert_type')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'emergency' => 'danger',
                        'silent' => 'warning',
                        default => 'gray'
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->badge(),
                Tables\Columns\TextColumn::make('latitude')
                    ->label('Location (Google Maps)')
                    ->formatStateUsing(fn ($record) => "View Map")
                    ->url(fn ($record) => "https://www.google.com/maps/search/?api=1&query={$record->latitude},{$record->longitude}", shouldOpenInNewTab: true)
                    ->color('primary'),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }
}
