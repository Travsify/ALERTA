<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GuardianSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'duration_minutes',
        'started_at',
        'expected_confirmation_at',
        'confirmed_at',
        'timed_out',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'expected_confirmation_at' => 'datetime',
        'confirmed_at' => 'datetime',
        'timed_out' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeTimedOut($query)
    {
        return $query->where('timed_out', true);
    }

    public function scopePending($query)
    {
        return $query->whereNull('confirmed_at')
                    ->where('timed_out', false);
    }
}
