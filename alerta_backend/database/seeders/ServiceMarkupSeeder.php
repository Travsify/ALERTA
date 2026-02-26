<?php

namespace Database\Seeders;

use App\Models\ServiceMarkup;
use Illuminate\Database\Seeder;

class ServiceMarkupSeeder extends Seeder
{
    public function run(): void
    {
        $markups = [
            ['service_name' => 'Virtual Card Issuance', 'markup_type' => 'fixed', 'markup_value' => 500.00],
            ['service_name' => 'Card Funding', 'markup_type' => 'percentage', 'markup_value' => 1.5],
            ['service_name' => 'Bank Transfer', 'markup_type' => 'fixed', 'markup_value' => 50.00],
        ];

        foreach ($markups as $markup) {
            ServiceMarkup::updateOrCreate(
                ['service_name' => $markup['service_name']],
                [
                    'markup_type' => $markup['markup_type'],
                    'markup_value' => $markup['markup_value'],
                    'is_active' => true,
                ]
            );
        }
    }
}
