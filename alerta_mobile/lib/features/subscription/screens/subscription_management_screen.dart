import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/subscription_service.dart';
import '../models/subscription_plan.dart';
import 'subscription_screen.dart';
import 'payment_history_screen.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final SubscriptionService _subService = SubscriptionService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _subService,
      builder: (context, child) {
        final sub = _subService.subscription;
        
        return Scaffold(
          backgroundColor: AppTheme.darkBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.cardSurface,
            title: const Text('Subscription Management'),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildCurrentPlanCard(sub),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildFeaturesList(sub.features),
              const SizedBox(height: 24),
              if (sub.isSubscribed) _buildCancelButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(UserSubscription sub) {
    final statusColor = sub.isTrialActive ? Colors.orange : (sub.isSubscribed ? AppTheme.successGreen : AppTheme.primaryRed);
    final statusText = sub.isTrialActive ? 'TRIAL ACTIVE' : (sub.isSubscribed ? 'PREMIUM ACTIVE' : 'FREE PLAN');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.2), AppTheme.cardSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub.activePlanName ?? 'Free',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Icon(Icons.verified_user, color: statusColor, size: 48).animate().scale().then().shimmer(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Days Remaining', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${sub.daysRemaining}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (sub.expiryDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Renews On', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${sub.expiryDate!.day}/${sub.expiryDate!.month}/${sub.expiryDate!.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.upgrade,
                title: 'Upgrade Plan',
                color: AppTheme.successGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.receipt_long,
                title: 'Payment History',
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesList(FeatureAccess features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Features', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _FeatureItem(
          icon: Icons.cloud_upload,
          title: 'Cloud Backup',
          enabled: features.cloudBackup,
        ),
        _FeatureItem(
          icon: Icons.support_agent,
          title: 'Priority Support',
          enabled: features.prioritySupport,
        ),
        _FeatureItem(
          icon: Icons.analytics,
          title: 'Advanced Analytics',
          enabled: features.advancedAnalytics,
        ),
        _FeatureItem(
          icon: Icons.storage,
          title: 'Extended Storage (${features.blackboxStorageDays} days)',
          enabled: features.extendedStorage,
        ),
        _FeatureItem(
          icon: Icons.notifications_active,
          title: 'Custom Alerts',
          enabled: features.customAlerts,
        ),
        _FeatureItem(
          icon: Icons.people,
          title: 'Trusted Contacts (${features.maxTrustedContacts == 999 ? "Unlimited" : features.maxTrustedContacts})',
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: _showCancelDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryRed.withOpacity(0.2),
        foregroundColor: AppTheme.primaryRed,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: AppTheme.primaryRed.withOpacity(0.5)),
      ),
      child: const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Subscription?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to all premium features immediately.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription', style: TextStyle(color: AppTheme.successGreen)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _subService.cancelSubscription();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription cancelled'), backgroundColor: AppTheme.primaryRed),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;

  const _FeatureItem({required this.icon, required this.title, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: enabled ? AppTheme.successGreen.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            child: Icon(icon, color: enabled ? AppTheme.successGreen : Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.lock,
            color: enabled ? AppTheme.successGreen : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
