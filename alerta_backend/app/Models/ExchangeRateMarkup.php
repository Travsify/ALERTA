<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExchangeRateMarkup extends Model
{
    protected $fillable = ['provider', 'base_currency', 'target_currency', 'markup_percentage', 'is_active'];
}
