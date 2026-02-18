<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('blackbox_recordings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('panic_alert_id')->nullable()->constrained()->onDelete('cascade');
            $table->enum('file_type', ['audio', 'video', 'image']);
            $table->string('file_path');
            $table->integer('duration_seconds')->nullable();
            $table->bigInteger('file_size_bytes')->nullable();
            $table->timestamp('recorded_at');
            $table->timestamp('uploaded_at')->nullable();
            $table->timestamps();
            
            $table->index(['user_id', 'panic_alert_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('blackbox_recordings');
    }
};
