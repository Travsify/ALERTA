<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MedicalIdResource\Pages;
use App\Filament\Resources\MedicalIdResource\RelationManagers;
use App\Models\MedicalId;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MedicalIdResource extends Resource
{
    protected static ?string $model = MedicalId::class;

    protected static ?string $navigationGroup = 'User Directory';

    protected static ?string $navigationIcon = 'heroicon-o-heart';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Medical ID Information')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\TextInput::make('blood_type'),
                        Forms\Components\TagsInput::make('allergies'),
                        Forms\Components\TagsInput::make('medications'),
                        Forms\Components\TagsInput::make('conditions'),
                        Forms\Components\TextInput::make('emergency_contact_name'),
                        Forms\Components\TextInput::make('emergency_contact_phone'),
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
                Tables\Columns\TextColumn::make('blood_type')
                    ->sortable(),
                Tables\Columns\TextColumn::make('emergency_contact_name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
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
            'index' => Pages\ListMedicalIds::route('/'),
            'create' => Pages\CreateMedicalId::route('/create'),
            'edit' => Pages\EditMedicalId::route('/{record}/edit'),
        ];
    }
}
