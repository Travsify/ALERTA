<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrustedContact extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'phone',
        'relationship',
        'receives_sos',
        'receives_location',
    ];

    protected $casts = [
        'receives_sos' => 'boolean',
        'receives_location' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
