<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VehicleReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plate_number',
        'driver_behavior',
        'vehicle_condition',
        'route',
        'comments',
        'is_verified',
        'rating',
    ];

    protected $casts = [
        'is_verified' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeForPlate($query, $plateNumber)
    {
        return $query->where('plate_number', strtoupper($plateNumber));
    }
}
