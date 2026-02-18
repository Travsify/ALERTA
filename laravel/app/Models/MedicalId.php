<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MedicalId extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'blood_type',
        'allergies',
        'medications',
        'conditions',
        'emergency_contact_name',
        'emergency_contact_phone',
    ];

    protected $casts = [
        'allergies' => 'array',
        'medications' => 'array',
        'conditions' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
