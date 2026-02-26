<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmsFaq extends Model
{
    protected $fillable = [
        'question',
        'answer',
        'category',
        'order',
        'is_active',
    ];
}
