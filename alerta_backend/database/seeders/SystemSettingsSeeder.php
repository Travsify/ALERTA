<?php

namespace Database\Seeders;

use App\Models\SystemSetting;
use Illuminate\Database\Seeder;

class SystemSettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['setting_key' => 'anchor_base_url', 'setting_value' => 'https://api.getanchor.co/api/v1'],
            ['setting_key' => 'anchor_api_key', 'setting_value' => 'YOUR_ANCHOR_API_KEY'],
            ['setting_key' => 'fincra_base_url', 'setting_value' => 'https://api.fincra.com'],
            ['setting_key' => 'fincra_api_key', 'setting_value' => 'YOUR_FINCRA_API_KEY'],
            ['setting_key' => 'fincra_merchant_id', 'setting_value' => 'YOUR_FINCRA_MERCHANT_ID'],
            ['setting_key' => 'active_card_provider', 'setting_value' => 'anchor'],
            ['setting_key' => 'active_va_provider', 'setting_value' => 'fincra'],
        ];

        foreach ($settings as $setting) {
            SystemSetting::updateOrCreate(
                ['setting_key' => $setting['setting_key']],
                ['setting_value' => $setting['setting_value']]
            );
        }
    }
}
