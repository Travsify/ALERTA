<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('fcm_token')->nullable();
            $table->string('telegram_chat_id')->nullable();
            $table->boolean('notify_push')->default(true);
            $table->boolean('notify_telegram')->default(false);
            $table->boolean('notify_sms')->default(true);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['fcm_token', 'telegram_chat_id', 'notify_push', 'notify_telegram', 'notify_sms']);
        });
    }
};
