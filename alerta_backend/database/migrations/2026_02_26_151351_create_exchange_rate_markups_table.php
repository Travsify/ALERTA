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
        Schema::create('exchange_rate_markups', function (Blueprint $table) {
            $table->id();
            $table->string('provider');
            $table->string('base_currency', 3)->default('USD');
            $table->string('target_currency', 3)->default('NGN');
            $table->decimal('markup_percentage', 5, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exchange_rate_markups');
    }
};
