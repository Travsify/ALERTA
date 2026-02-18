<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BlackboxRecordingResource\Pages;
use App\Models\BlackboxRecording;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Illuminate\Database\Eloquent\Builder;

class BlackboxRecordingResource extends Resource
{
    protected static ?string $model = BlackboxRecording::class;

    protected static ?string $navigationGroup = 'Crisis Management';

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Recording Metadata')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required(),
                        Forms\Components\Select::make('panic_alert_id')
                            ->relationship('panicAlert', 'id')
                            ->label('Associated Alert'),
                        Forms\Components\TextInput::make('file_type')
                            ->required(),
                        Forms\Components\TextInput::make('file_path')
                            ->required(),
                        Forms\Components\TextInput::make('duration_seconds')
                            ->numeric(),
                        Forms\Components\TextInput::make('file_size_bytes')
                            ->numeric(),
                        Forms\Components\DateTimePicker::make('recorded_at'),
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
                Tables\Columns\TextColumn::make('file_type')
                    ->badge(),
                Tables\Columns\TextColumn::make('duration_seconds')
                    ->label('Duration (s)')
                    ->sortable(),
                Tables\Columns\TextColumn::make('file_size_bytes')
                    ->label('Size (KB)')
                    ->formatStateUsing(fn ($state) => round($state / 1024, 2))
                    ->sortable(),
                Tables\Columns\TextColumn::make('recorded_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('file_type')
                    ->options([
                        'audio' => 'Audio',
                        'video' => 'Video',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->modalContent(fn ($record) => new \Illuminate\Support\HtmlString("
                        <div class='p-4'>
                            <h3 class='text-lg font-bold mb-4'>Evidence Playback</h3>
                            <audio controls class='w-full'>
                                <source src='/storage/{$record->file_path}' type='audio/mpeg'>
                                Your browser does not support the audio element.
                            </audio>
                            <div class='mt-4 text-sm text-gray-500'>
                                <strong>File Path:</strong> {$record->file_path}<br>
                                <strong>Recorded At:</strong> {$record->recorded_at}
                            </div>
                        </div>
                    ")),
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
            'index' => Pages\ListBlackboxRecordings::route('/'),
            'create' => Pages\CreateBlackboxRecording::route('/create'),
            'edit' => Pages\EditBlackboxRecording::route('/{record}/edit'),
        ];
    }
}
