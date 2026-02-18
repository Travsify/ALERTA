<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('trusted_contacts', function (Blueprint $table) {
            $table->foreignId('contact_user_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->string('telegram_chat_id')->nullable();
            $table->boolean('notify_push')->default(true);
            $table->boolean('notify_telegram')->default(false);
        });
    }

    public function down(): void
    {
        Schema::table('trusted_contacts', function (Blueprint $table) {
            $table->dropConstrainedForeignId('contact_user_id');
            $table->dropColumn(['telegram_chat_id', 'notify_push', 'notify_telegram']);
        });
    }
};
