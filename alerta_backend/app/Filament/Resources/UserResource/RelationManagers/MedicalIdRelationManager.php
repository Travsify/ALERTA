<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MedicalIdRelationManager extends RelationManager
{
    protected static string $relationship = 'medicalId';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('blood_type')
                    ->maxLength(255),
                Forms\Components\TagsInput::make('allergies'),
                Forms\Components\TagsInput::make('medications'),
                Forms\Components\TagsInput::make('conditions'),
                Forms\Components\TextInput::make('emergency_contact_name'),
                Forms\Components\TextInput::make('emergency_contact_phone'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('blood_type')
            ->columns([
                Tables\Columns\TextColumn::make('blood_type'),
                Tables\Columns\TextColumn::make('emergency_contact_name'),
                Tables\Columns\TextColumn::make('emergency_contact_phone'),
                Tables\Columns\TextColumn::make('created_at')->dateTime(),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
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
}
