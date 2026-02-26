<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LocationShareResource\Pages;
use App\Filament\Resources\LocationShareResource\RelationManagers;
use App\Models\LocationShare;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class LocationShareResource extends Resource
{
    protected static ?string $model = LocationShare::class;

    protected static ?string $navigationGroup = 'Safety Tracking';

    protected static ?string $navigationIcon = 'heroicon-o-map-pin';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Location Sharing Details')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\TextInput::make('status')
                            ->required(),
                        Forms\Components\TextInput::make('latitude')
                            ->numeric(),
                        Forms\Components\TextInput::make('longitude')
                            ->numeric(),
                        Forms\Components\DateTimePicker::make('started_at'),
                        Forms\Components\DateTimePicker::make('expires_at'),
                        Forms\Components\TextInput::make('update_interval_minutes')
                            ->numeric(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'expired' => 'gray',
                        default => 'warning',
                    }),
                Tables\Columns\TextColumn::make('latitude')
                    ->label('Location')
                    ->formatStateUsing(fn ($record) => "Lat: {$record->latitude}, Lon: {$record->longitude}")
                    ->description(fn ($record) => "https://www.google.com/maps/search/?api=1&query={$record->latitude},{$record->longitude}"),
                Tables\Columns\TextColumn::make('expires_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'active' => 'Active',
                        'expired' => 'Expired',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\ViewAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListLocationShares::route('/'),
            'create' => Pages\CreateLocationShare::route('/create'),
            'edit' => Pages\EditLocationShare::route('/{record}/edit'),
        ];
    }
}
