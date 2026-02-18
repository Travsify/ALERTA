<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentTransaction;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function status(Request $request)
    {
        return response()->json([
            'subscription' => [
                'tier' => $request->user()->subscription_tier,
                'is_premium' => $request->user()->isPremium(),
                'is_trial_active' => $request->user()->isTrialActive(),
                'has_access' => $request->user()->hasAccess(),
                'days_remaining' => $request->user()->daysRemaining(),
                'expires_at' => $request->user()->subscription_expires_at,
                'trial_started_at' => $request->user()->trial_started_at,
            ],
        ]);
    }

    public function verifyPayment(Request $request)
    {
        $request->validate([
            'reference' => 'required|string',
            'amount' => 'required|integer',
            'plan_name' => 'required|string',
            'plan_duration' => 'required|in:one_month,six_months,one_year',
        ]);

        // Create payment record
        $transaction = PaymentTransaction::create([
            'user_id' => $request->user()->id,
            'reference' => $request->reference,
            'amount' => $request->amount,
            'plan_name' => $request->plan_name,
            'plan_duration' => $request->plan_duration,
            'status' => 'pending',
            'paystack_reference' => $request->paystack_reference,
        ]);

        // Logic to verify with Paystack API
        if ($this->verifyWithPaystack($request->reference)) {
            $transaction->markAsVerified();
        }


        return response()->json([
            'transaction' => $transaction->fresh(),
            'user' => $request->user()->fresh(),
            'message' => 'Payment verified successfully',
        ]);
    }

    public function transactions(Request $request)
    {
        $transactions = $request->user()
            ->paymentTransactions()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($transactions);
    }
    protected function verifyWithPaystack($reference)
    {
        // Call Paystack API to verify transaction
        return true; // Stubbed for now
    }
}

