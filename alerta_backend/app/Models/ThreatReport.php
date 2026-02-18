<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ThreatReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'latitude',
        'longitude',
        'radius_meters',
        'type',
        'severity',
        'status',
        'verification_count',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'radius_meters' => 'integer',
        'verification_count' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeVerified($query)
    {
        return $query->where('status', 'verified');
    }

    public function scopeNearby($query, $lat, $lon, $radius = 5000)
    {
        // Simplified distance calculation - in production use spatial queries
        return $query->whereBetween('latitude', [$lat - 0.05, $lat + 0.05])
                    ->whereBetween('longitude', [$lon - 0.05, $lon + 0.05]);
    }

    public function incrementVerification()
    {
        $this->increment('verification_count');
        
        // Auto-verify after 3 confirmations
        if ($this->verification_count >= 3 && $this->status === 'pending') {
            $this->update(['status' => 'verified']);
        }
    }
}
