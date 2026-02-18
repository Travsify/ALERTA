<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Select;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Illuminate\Database\Eloquent\Builder;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('User Details')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required(),
                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->required(),
                        Forms\Components\TextInput::make('phone'),
                        Forms\Components\Toggle::make('is_admin')
                            ->label('Has Admin Access'),
                        Forms\Components\Select::make('subscription_tier')
                            ->options([
                                'free' => 'Free',
                                'premium' => 'Premium',
                                'enterprise' => 'Enterprise',
                            ])->default('free'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('email')
                    ->searchable(),
                Tables\Columns\IconColumn::make('is_admin')
                    ->boolean()
                    ->label('Admin'),
                Tables\Columns\TextColumn::make('subscription_tier')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'free' => 'gray',
                        'premium' => 'warning',
                        'enterprise' => 'success',
                        default => 'danger',
                    }),
                Tables\Columns\TextColumn::make('panic_alerts_count')
                    ->counts('panicAlerts')
                    ->label('Alerts')
                    ->badge()
                    ->color('danger'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Security Status')
                    ->badge()
                    ->state(function ($record): string {
                        return $record->panicAlerts()->where('is_duress', true)->where('status', 'pending')->exists() 
                            ? 'UNDER DURESS' 
                            : ($record->panicAlerts()->where('status', 'pending')->exists() ? 'ACTIVE ALERT' : 'SECURE');
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'SECURE' => 'success',
                        'ACTIVE ALERT' => 'warning',
                        'UNDER DURESS' => 'danger',
                        default => 'gray',
                    }),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_admin'),
                Tables\Filters\SelectFilter::make('subscription_tier')
                    ->options([
                        'free' => 'Free',
                        'premium' => 'Premium',
                        'enterprise' => 'Enterprise',
                    ]),
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
            UserResource\RelationManagers\SafetyTimelineRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
