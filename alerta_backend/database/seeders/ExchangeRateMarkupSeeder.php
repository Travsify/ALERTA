<?php

namespace Database\Seeders;

use App\Models\ExchangeRateMarkup;
use Illuminate\Database\Seeder;

class ExchangeRateMarkupSeeder extends Seeder
{
    public function run(): void
    {
        $markups = [
            [
                'provider' => 'Fincra',
                'base_currency' => 'USD',
                'target_currency' => 'NGN',
                'markup_percentage' => 2.0,
            ],
            [
                'provider' => 'Anchor',
                'base_currency' => 'USD',
                'target_currency' => 'NGN',
                'markup_percentage' => 1.8,
            ],
        ];

        foreach ($markups as $markup) {
            ExchangeRateMarkup::updateOrCreate(
                [
                    'provider' => $markup['provider'],
                    'base_currency' => $markup['base_currency'],
                    'target_currency' => $markup['target_currency'],
                ],
                [
                    'markup_percentage' => $markup['markup_percentage'],
                    'is_active' => true,
                ]
            );
        }
    }
}
