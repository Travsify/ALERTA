<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PanicAlertResource\Pages;
use App\Models\PanicAlert;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Illuminate\Database\Eloquent\Builder;

class PanicAlertResource extends Resource
{
    protected static ?string $model = PanicAlert::class;

    protected static ?string $navigationGroup = 'Crisis Management';

    protected static ?string $navigationIcon = 'heroicon-o-fire';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Alert Details')
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
                        Forms\Components\TextInput::make('battery_level')
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
                        'pending' => 'warning',
                        'investigating' => 'info',
                        'resolved' => 'success',
                        'spurious' => 'gray',
                        default => 'danger',
                    }),
                Tables\Columns\TextColumn::make('latitude')
                    ->label('Location')
                    ->formatStateUsing(fn ($record) => "Lat: {$record->latitude}, Lon: {$record->longitude}")
                    ->copyable()
                    ->copyMessage('Coordinates copied')
                    ->description(fn ($record) => "https://www.google.com/maps/search/?api=1&query={$record->latitude},{$record->longitude}"),
                Tables\Columns\TextColumn::make('battery_level')
                    ->label('Battery %')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->label('Triggered At')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'investigating' => 'Investigating',
                        'resolved' => 'Resolved',
                        'spurious' => 'Spurious',
                    ]),
            ])
            ->actions([
                Tables\Actions\Action::make('export_report')
                    ->label('Export Report')
                    ->icon('heroicon-o-document-arrow-down')
                    ->color('info')
                    ->action(fn ($record) => response()->streamDownload(function () use ($record) {
                        echo "ALERTA INCIDENT REPORT\n";
                        echo "======================\n";
                        echo "User: " . $record->user->name . "\n";
                        echo "Status: " . $record->status . "\n";
                        echo "Location: https://www.google.com/maps/search/?api=1&query=" . $record->latitude . "," . $record->longitude . "\n";
                        echo "Battery: " . $record->battery_level . "%\n";
                        echo "Triggered At: " . $record->created_at . "\n";
                        echo "Notes: " . ($record->notes ?? 'None') . "\n";
                    }, "incident-report-{$record->id}.txt")),
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
            'index' => Pages\ListPanicAlerts::route('/'),
            'create' => Pages\CreatePanicAlert::route('/create'),
            'edit' => Pages\EditPanicAlert::route('/{record}/edit'),
        ];
    }
}
