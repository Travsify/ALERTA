import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_plan.dart';

class FeatureGateService {
  static final FeatureGateService _instance = FeatureGateService._internal();
  factory FeatureGateService() => _instance;
  FeatureGateService._internal();

  final SubscriptionService _subService = SubscriptionService();

  // Feature access checks
  bool canAccessCloudBackup() {
    return _subService.subscription.features.cloudBackup;
  }

  bool canAccessPrioritySupport() {
    return _subService.subscription.features.prioritySupport;
  }

  bool canAccessAdvancedAnalytics() {
    return _subService.subscription.features.advancedAnalytics;
  }

  bool canAccessExtendedStorage() {
    return _subService.subscription.features.extendedStorage;
  }

  bool canAccessCustomAlerts() {
    return _subService.subscription.features.customAlerts;
  }

  int getMaxTrustedContacts() {
    return _subService.subscription.features.maxTrustedContacts;
  }

  int getMaxGuardianContacts() {
    return _subService.subscription.features.maxGuardianContacts;
  }

  int getBlackboxStorageDays() {
    return _subService.subscription.features.blackboxStorageDays;
  }

  // Show upgrade prompt
  void showUpgradePrompt(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade400),
            const SizedBox(width: 12),
            const Text('Premium Feature', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureName is a premium feature.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upgrade to Alerta Pro to unlock:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('☁️ Cloud Backup'),
            _buildFeatureItem('⚡ Priority Support'),
            _buildFeatureItem('📊 Advanced Analytics'),
            _buildFeatureItem('💾 Extended Storage'),
            _buildFeatureItem('🔔 Custom Alerts'),
            _buildFeatureItem('👥 Unlimited Contacts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }

  // Check if feature is accessible, show prompt if not
  bool checkFeatureAccess(BuildContext context, String featureName, bool hasAccess) {
    if (!hasAccess) {
      showUpgradePrompt(context, featureName);
      return false;
    }
    return true;
  }
}
