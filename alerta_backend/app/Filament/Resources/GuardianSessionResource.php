<?php

namespace App\Filament\Resources;

use App\Filament\Resources\GuardianSessionResource\Pages;
use App\Models\GuardianSession;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Illuminate\Database\Eloquent\Builder;

class GuardianSessionResource extends Resource
{
    protected static ?string $model = GuardianSession::class;

    protected static ?string $navigationGroup = 'Safety Oversight';

    protected static ?string $navigationIcon = 'heroicon-o-eye';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Session Parameters')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\TextInput::make('duration_minutes')
                            ->numeric()
                            ->required(),
                        Forms\Components\DateTimePicker::make('started_at'),
                        Forms\Components\DateTimePicker::make('expires_at'),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Is Session Active'),
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
                Tables\Columns\TextColumn::make('duration_minutes')
                    ->label('Planned (min)')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->state(function ($record): string {
                        if (!$record->is_active) return 'Completed';
                        if ($record->expires_at && $record->expires_at->isPast()) return 'TIMED OUT';
                        return 'InProgress';
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'InProgress' => 'info',
                        'TIMED OUT' => 'danger',
                        'Completed' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('started_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('expires_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active'),
            ])
            ->actions([
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
            'index' => Pages\ListGuardianSessions::route('/'),
            'create' => Pages\CreateGuardianSession::route('/create'),
            'edit' => Pages\EditGuardianSession::route('/{record}/edit'),
        ];
    }
}
