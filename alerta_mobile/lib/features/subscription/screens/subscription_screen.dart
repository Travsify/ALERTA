import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/core/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';
import '../services/paystack_service.dart';
import '../../profile/services/user_profile_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool showBackButton;
  const SubscriptionScreen({super.key, this.showBackButton = true});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subService = SubscriptionService();
  final PaystackService _paystackService = PaystackService();
  final UserProfileService _profileService = UserProfileService();
  SubscriptionPlan? _selectedPlan;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: 'Monthly',
      price: 2000,
      duration: PlanDuration.oneMonth,
      features: ['Full App Access', 'Real-time Panic Notifications', 'Evidence VaultSync'],
    ),
    SubscriptionPlan(
      name: 'Bi-Annual',
      price: 10000,
      duration: PlanDuration.sixMonths,
      features: ['Full App Access', 'Real-time Panic Notifications', 'Evidence VaultSync', 'Priority Emergency Support'],
    ),
    SubscriptionPlan(
      name: 'Annual',
      price: 12000,
      duration: PlanDuration.oneYear,
      features: ['Full App Access', 'Real-time Panic Notifications', 'Evidence VaultSync', 'Priority Emergency Support', 'Best Value (₦1k/mo)'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _subService,
      builder: (context, child) {
        final sub = _subService.subscription;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryRed.withOpacity(0.2), Colors.black],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, sub),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'CHOOSE YOUR SAFETY PLAN',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelLarge.copyWith(fontSize: 18, letterSpacing: 2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ensure 24/7 protection for you and your loved ones.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 32),
                        ..._plans.map((plan) => _buildPlanCard(plan)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  _buildFooterAction(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserSubscription sub) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showBackButton)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            )
          else 
            const SizedBox(width: 48),
          
          Column(
            children: [
              Text(
                sub.isTrialActive ? 'TRIAL ACCESS' : (sub.isSubscribed ? 'PRO ACTIVE' : 'EXPIRED'),
                  style: AppTypography.labelLarge.copyWith(
                    color: sub.hasAccess ? AppTheme.successGreen : AppTheme.primaryRed,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
              ),
              Text(
                '${sub.daysRemaining} DAYS REMAINING',
                style: AppTypography.labelMedium.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    bool isSelected = _selectedPlan == plan;
    bool isBestValue = plan.duration == PlanDuration.oneYear;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed.withOpacity(0.1) : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.white10,
            width: 2,
          ),
          boxShadow: isSelected ? [
             BoxShadow(color: AppTheme.primaryRed.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
          ] : null,
        ),
        child: Column(
          children: [
            if (isBestValue)
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(color: AppTheme.successGreen, borderRadius: BorderRadius.circular(4)),
                     child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                   ),
                 ],
               ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: AppTypography.heading2.copyWith(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text('₦${plan.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', 
                        style: AppTypography.heading2.copyWith(color: AppTheme.primaryRed, fontSize: 18)),
                    ],
                  ),
                ),
                Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primaryRed : Colors.white24),
              ],
            ),
            if (isSelected) ...[
               const Divider(color: Colors.white10, height: 24),
               ...plan.features.map((f) => Padding(
                 padding: const EdgeInsets.only(bottom: 6),
                 child: Row(
                   children: [
                     const Icon(Icons.check, color: AppTheme.successGreen, size: 14),
                     const SizedBox(width: 8),
                     Text(f, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                   ],
                 ),
               )),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFooterAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _selectedPlan == null ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _selectedPlan == null ? 'SELECT A PLAN' : 'ACTIVATE ${_selectedPlan!.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Secured by Bank-grade Encryption. Change plans anytime.',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
    );

    if (mounted) {
      Navigator.pop(context); // Close loading indicator
      
      final email = _profileService.profile?.email ?? 'user@example.com';
      
      final success = await _paystackService.checkout(
        context: context,
        email: email,
        amount: _selectedPlan!.price,
        plan: _selectedPlan!,
      );

      if (success && mounted) {
        await _subService.purchasePlan(_selectedPlan!);
        _showSuccessDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Cancelled or Failed'), backgroundColor: AppTheme.primaryRed),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_rounded, color: AppTheme.successGreen, size: 80).animate().scale().then().shake(),
            const SizedBox(height: 24),
            const Text('SUBSCRIPTION ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              'Your Alerta Pro subscription is now active. You have full access to all emergency features.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (!widget.showBackButton) {
                  // If we forced them here, go to dashboard
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                  Navigator.pop(context); // Go back to original screen
                }
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}
