<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable implements FilamentUser
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'duress_pin_hash',
        'subscription_tier',
        'subscription_expires_at',
        'trial_started_at',
        'is_active',
        'is_suspended',
        'is_admin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'duress_pin_hash',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'subscription_expires_at' => 'datetime',
        'trial_started_at' => 'datetime',
        'is_active' => 'boolean',
        'is_suspended' => 'boolean',
        'is_admin' => 'boolean',
    ];

    // Relationships
    public function trustedContacts()
    {
        return $this->hasMany(TrustedContact::class);
    }

    public function panicAlerts()
    {
        return $this->hasMany(PanicAlert::class);
    }

    public function threatReports()
    {
        return $this->hasMany(ThreatReport::class);
    }

    public function locationShares()
    {
        return $this->hasMany(LocationShare::class);
    }

    public function guardianSessions()
    {
        return $this->hasMany(GuardianSession::class);
    }

    public function vehicleReports()
    {
        return $this->hasMany(VehicleReport::class);
    }

    public function paymentTransactions()
    {
        return $this->hasMany(PaymentTransaction::class);
    }

    public function medicalId()
    {
        return $this->hasOne(MedicalId::class);
    }

    public function blackboxRecordings()
    {
        return $this->hasMany(BlackboxRecording::class);
    }

    // Subscription helpers
    public function isPremium()
    {
        return $this->subscription_tier === 'premium' && 
               $this->subscription_expires_at && 
               $this->subscription_expires_at->isFuture();
    }

    public function isTrialActive()
    {
        if (!$this->trial_started_at || $this->subscription_expires_at) {
            return false;
        }
        
        return $this->trial_started_at->diffInDays(now()) < 7;
    }

    public function hasAccess()
    {
        return $this->isPremium() || $this->isTrialActive();
    }

    public function daysRemaining()
    {
        if ($this->isPremium()) {
            return $this->subscription_expires_at->diffInDays(now());
        }
        
        if ($this->isTrialActive()) {
            return 7 - $this->trial_started_at->diffInDays(now());
        }
        
        return 0;
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->is_admin;
    }
}
