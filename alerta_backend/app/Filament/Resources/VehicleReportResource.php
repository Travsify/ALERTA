<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VehicleReportResource\Pages;
use App\Filament\Resources\VehicleReportResource\RelationManagers;
use App\Models\VehicleReport;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class VehicleReportResource extends Resource
{
    protected static ?string $model = VehicleReport::class;

    protected static ?string $navigationGroup = 'Intelligence Center';

    protected static ?string $navigationIcon = 'heroicon-o-truck';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Vehicle Report')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\TextInput::make('plate_number')
                            ->required()
                            ->upper(),
                        Forms\Components\TextInput::make('driver_behavior'),
                        Forms\Components\TextInput::make('vehicle_condition'),
                        Forms\Components\TextInput::make('route'),
                        Forms\Components\TextInput::make('rating')
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(5),
                        Forms\Components\Textarea::make('comments')
                            ->columnSpanFull(),
                        Forms\Components\Toggle::make('is_verified')
                            ->label('Verified by Admin'),
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
                Tables\Columns\TextColumn::make('plate_number')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_verified')
                    ->boolean()
                    ->label('Verified'),
                Tables\Columns\TextColumn::make('rating')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_verified'),
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
            'index' => Pages\ListVehicleReports::route('/'),
            'create' => Pages\CreateVehicleReport::route('/create'),
            'edit' => Pages\EditVehicleReport::route('/{record}/edit'),
        ];
    }
}
