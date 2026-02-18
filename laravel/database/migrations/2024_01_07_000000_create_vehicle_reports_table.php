<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicle_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('plate_number');
            $table->string('driver_behavior')->nullable();
            $table->string('vehicle_condition')->nullable();
            $table->string('route')->nullable();
            $table->text('comments')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->enum('rating', ['safe', 'caution', 'unsafe'])->default('safe');
            $table->timestamps();
            
            $table->index('plate_number');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicle_reports');
    }
};
