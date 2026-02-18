<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('panic_alerts', function (Blueprint $blueprint) {
            $blueprint->boolean('is_mesh')->default(false);
            $blueprint->unsignedBigInteger('relayed_by_id')->nullable();
            
            $blueprint->foreign('relayed_by_id')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('panic_alerts', function (Blueprint $blueprint) {
            $blueprint->dropForeign(['relayed_by_id']);
            $blueprint->dropColumn(['is_mesh', 'relayed_by_id']);
        });
    }
};
