import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:alerta_mobile/features/subscription/models/subscription_plan.dart';
import 'package:alerta_mobile/features/subscription/services/subscription_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaystackService {
  static String? get _publicKey => dotenv.env['PAYSTACK_PUBLIC_KEY'];

  Future<bool> checkout({
    required BuildContext context,
    required String email,
    required int amount,
    required SubscriptionPlan plan,
  }) async {
    final completer = Completer<bool>();
    
    try {
      final String reference = 'ALERTA_${DateTime.now().millisecondsSinceEpoch}';
      
      await FlutterPaystackPlus.openPaystackPopup(
        context: context,
        customerEmail: email,
        publicKey: _publicKey,
        amount: (amount * 100).toString(), // Amount is in kobo and must be a String
        reference: reference,
        secretKey: '', // Should be handled server-side ideally
        onSuccess: () async {
          // Record payment transaction
          final transaction = PaymentTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            reference: reference,
            amount: amount,
            date: DateTime.now(),
            status: 'success',
            planName: plan.name,
          );
          
          await SubscriptionService().addPaymentTransaction(transaction);
          
          if (!completer.isCompleted) completer.complete(true);
        },
        onClosed: () {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      return completer.future;
    } catch (e) {
      debugPrint('Paystack Checkout Error: $e');
      return false;
    }
  }
}
