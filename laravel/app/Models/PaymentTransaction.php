<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'reference',
        'amount',
        'plan_name',
        'plan_duration',
        'status',
        'paystack_reference',
        'verified_at',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'integer',
        'verified_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeSuccessful($query)
    {
        return $query->where('status', 'success');
    }

    public function markAsVerified()
    {
        $this->update([
            'status' => 'success',
            'verified_at' => now(),
        ]);

        // Update user subscription
        $durationMonths = match($this->plan_duration) {
            'one_month' => 1,
            'six_months' => 6,
            'one_year' => 12,
            default => 1,
        };

        $this->user->update([
            'subscription_tier' => 'premium',
            'subscription_expires_at' => now()->addMonths($durationMonths),
        ]);
    }
}
