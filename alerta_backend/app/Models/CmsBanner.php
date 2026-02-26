<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmsBanner extends Model
{
    protected $fillable = [
        'title',
        'image_path',
        'link_url',
        'order',
        'is_active',
    ];
}
