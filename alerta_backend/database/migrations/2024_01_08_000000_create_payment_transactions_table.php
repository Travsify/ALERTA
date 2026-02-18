<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('reference')->unique();
            $table->integer('amount'); // in kobo (NGN minor unit)
            $table->string('plan_name');
            $table->enum('plan_duration', ['one_month', 'six_months', 'one_year']);
            $table->enum('status', ['pending', 'success', 'failed'])->default('pending');
            $table->string('paystack_reference')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->text('metadata')->nullable();
            $table->timestamps();
            
            $table->index(['user_id', 'status']);
            $table->index('reference');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_transactions');
    }
};
