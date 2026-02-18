enum PlanDuration { oneMonth, sixMonths, oneYear }

enum SubscriptionTier { free, premium }

class SubscriptionPlan {
  final String name;
  final int price;
  final PlanDuration duration;
  final List<String> features;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
  });
}

class FeatureAccess {
  final bool cloudBackup;
  final bool prioritySupport;
  final bool advancedAnalytics;
  final bool extendedStorage;
  final bool customAlerts;
  final int maxGuardianContacts;
  final int maxTrustedContacts;
  final int blackboxStorageDays;

  const FeatureAccess({
    required this.cloudBackup,
    required this.prioritySupport,
    required this.advancedAnalytics,
    required this.extendedStorage,
    required this.customAlerts,
    required this.maxGuardianContacts,
    required this.maxTrustedContacts,
    required this.blackboxStorageDays,
  });

  // Free tier access
  static const FeatureAccess free = FeatureAccess(
    cloudBackup: false,
    prioritySupport: false,
    advancedAnalytics: false,
    extendedStorage: false,
    customAlerts: false,
    maxGuardianContacts: 3,
    maxTrustedContacts: 3,
    blackboxStorageDays: 7,
  );

  // Premium tier access
  static const FeatureAccess premium = FeatureAccess(
    cloudBackup: true,
    prioritySupport: true,
    advancedAnalytics: true,
    extendedStorage: true,
    customAlerts: true,
    maxGuardianContacts: 999,
    maxTrustedContacts: 999,
    blackboxStorageDays: 90,
  );
}

class PaymentTransaction {
  final String id;
  final String reference;
  final int amount;
  final DateTime date;
  final String status;
  final String planName;

  PaymentTransaction({
    required this.id,
    required this.reference,
    required this.amount,
    required this.date,
    required this.status,
    required this.planName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'amount': amount,
    'date': date.toIso8601String(),
    'status': status,
    'planName': planName,
  };

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => PaymentTransaction(
    id: json['id'],
    reference: json['reference'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    status: json['status'],
    planName: json['planName'],
  );
}

class UserSubscription {
  final DateTime? trialStartDate;
  final DateTime? expiryDate;
  final String? activePlanName;

  UserSubscription({
    this.trialStartDate,
    this.expiryDate,
    this.activePlanName,
  });

  bool get isTrialActive {
    if (trialStartDate == null || expiryDate != null) return false;
    final now = DateTime.now();
    return now.difference(trialStartDate!).inDays < 7;
  }

  bool get isSubscribed {
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  bool get hasAccess => isTrialActive || isSubscribed;

  SubscriptionTier get tier => (isSubscribed || isTrialActive) ? SubscriptionTier.premium : SubscriptionTier.free;

  FeatureAccess get features => (isSubscribed || isTrialActive) ? FeatureAccess.premium : FeatureAccess.free;

  int get daysRemaining {
    if (isSubscribed) {
      return expiryDate!.difference(DateTime.now()).inDays;
    }
    if (isTrialActive) {
      return 7 - DateTime.now().difference(trialStartDate!).inDays;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'trialStartDate': trialStartDate?.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'activePlanName': activePlanName,
  };

  factory UserSubscription.fromJson(Map<String, dynamic> json) => UserSubscription(
    trialStartDate: json['trialStartDate'] != null ? DateTime.parse(json['trialStartDate']) : null,
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    activePlanName: json['activePlanName'],
  );
}
