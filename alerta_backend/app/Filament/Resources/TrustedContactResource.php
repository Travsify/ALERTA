<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TrustedContactResource\Pages;
use App\Filament\Resources\TrustedContactResource\RelationManagers;
use App\Models\TrustedContact;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TrustedContactResource extends Resource
{
    protected static ?string $model = TrustedContact::class;

    protected static ?string $navigationGroup = 'User Directory';

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Trusted Contact Details')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\TextInput::make('name')
                            ->required(),
                        Forms\Components\TextInput::make('phone')
                            ->required(),
                        Forms\Components\TextInput::make('relationship'),
                        Forms\Components\Toggle::make('receives_sos'),
                        Forms\Components\Toggle::make('receives_location'),
                        Forms\Components\TextInput::make('telegram_chat_id'),
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
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable(),
                Tables\Columns\IconColumn::make('receives_sos')
                    ->boolean()
                    ->label('SOS'),
                Tables\Columns\TextColumn::make('relationship'),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListTrustedContacts::route('/'),
            'create' => Pages\CreateTrustedContact::route('/create'),
            'edit' => Pages\EditTrustedContact::route('/{record}/edit'),
        ];
    }
}
