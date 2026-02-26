<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceMarkup extends Model
{
    protected $fillable = ['service_name', 'markup_type', 'markup_value', 'is_active'];
}
