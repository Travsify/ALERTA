<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PanicAlert extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'latitude',
        'longitude',
        'battery_level',
        'alert_type',
        'is_duress',
        'is_mesh',
        'is_proactive',
        'relayed_by_id',
        'status',
        'triggered_at',
        'resolved_at',
        'heartbeat_expires_at',
        'notes',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'is_duress' => 'boolean',
        'is_mesh' => 'boolean',
        'is_proactive' => 'boolean',
        'triggered_at' => 'datetime',
        'resolved_at' => 'datetime',
        'heartbeat_expires_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function relayUser()
    {
        return $this->belongsTo(User::class, 'relayed_by_id');
    }

    public function blackboxRecordings()
    {
        return $this->hasMany(BlackboxRecording::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('triggered_at', '>=', now()->subDays($days));
    }
}
