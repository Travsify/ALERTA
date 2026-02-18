<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BlackboxRecording extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'panic_alert_id',
        'file_type',
        'file_path',
        'duration_seconds',
        'file_size_bytes',
        'recorded_at',
        'uploaded_at',
    ];

    protected $casts = [
        'recorded_at' => 'datetime',
        'uploaded_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function panicAlert()
    {
        return $this->belongsTo(PanicAlert::class);
    }
}
