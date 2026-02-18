import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription_plan.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final _storage = const FlutterSecureStorage();
  static const String _subKey = 'user_subscription_status';
  static const String _paymentHistoryKey = 'payment_history';

  UserSubscription _subscription = UserSubscription();
  UserSubscription get subscription => _subscription;

  List<PaymentTransaction> _paymentHistory = [];
  List<PaymentTransaction> get paymentHistory => _paymentHistory;

  Future<void> initialize() async {
    final data = await _storage.read(key: _subKey);
    if (data == null) {
      // Start 7-day trial for new user
      await startTrial();
    } else {
      _subscription = UserSubscription.fromJson(jsonDecode(data));
      notifyListeners();
    }

    // Load payment history
    final historyData = await _storage.read(key: _paymentHistoryKey);
    if (historyData != null) {
      final List<dynamic> historyJson = jsonDecode(historyData);
      _paymentHistory = historyJson.map((json) => PaymentTransaction.fromJson(json)).toList();
    }
  }

  Future<void> startTrial() async {
    _subscription = UserSubscription(trialStartDate: DateTime.now());
    await _save();
  }

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    // Mock Payment Logic
    DateTime currentExpiry = _subscription.expiryDate ?? DateTime.now();
    if (currentExpiry.isBefore(DateTime.now())) {
      currentExpiry = DateTime.now();
    }

    DateTime newExpiry;
    switch (plan.duration) {
      case PlanDuration.oneMonth:
        newExpiry = currentExpiry.add(const Duration(days: 30));
        break;
      case PlanDuration.sixMonths:
        newExpiry = currentExpiry.add(const Duration(days: 180));
        break;
      case PlanDuration.oneYear:
        newExpiry = currentExpiry.add(const Duration(days: 365));
        break;
    }

    _subscription = UserSubscription(
      trialStartDate: _subscription.trialStartDate,
      expiryDate: newExpiry,
      activePlanName: plan.name,
    );
    
    await _save();
  }

  Future<void> addPaymentTransaction(PaymentTransaction transaction) async {
    _paymentHistory.insert(0, transaction);
    await _savePaymentHistory();
  }

  Future<void> cancelSubscription() async {
    // Set expiry to now (immediate cancellation)
    _subscription = UserSubscription(
      trialStartDate: _subscription.trialStartDate,
      expiryDate: DateTime.now(),
      activePlanName: null,
    );
    await _save();
  }

  Future<void> upgradePlan(SubscriptionPlan newPlan) async {
    // Upgrade immediately
    await purchasePlan(newPlan);
  }

  Future<void> downgradePlan(SubscriptionPlan newPlan) async {
    // Downgrade at end of current period
    // For now, just update the plan name
    _subscription = UserSubscription(
      trialStartDate: _subscription.trialStartDate,
      expiryDate: _subscription.expiryDate,
      activePlanName: newPlan.name,
    );
    await _save();
  }

  FeatureAccess getFeatureAccess() {
    return _subscription.features;
  }

  Future<void> _save() async {
    await _storage.write(key: _subKey, value: jsonEncode(_subscription.toJson()));
    notifyListeners();
  }

  Future<void> _savePaymentHistory() async {
    final historyJson = _paymentHistory.map((t) => t.toJson()).toList();
    await _storage.write(key: _paymentHistoryKey, value: jsonEncode(historyJson));
    notifyListeners();
  }
}
