<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrustedContact extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'contact_user_id',
        'name',
        'phone',
        'relationship',
        'receives_sos',
        'receives_location',
        'telegram_chat_id',
        'notify_push',
        'notify_telegram',
    ];

    protected $casts = [
        'receives_sos' => 'boolean',
        'receives_location' => 'boolean',
        'notify_push' => 'boolean',
        'notify_telegram' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function contactUser()
    {
        return $this->belongsTo(User::class, 'contact_user_id');
    }
}
