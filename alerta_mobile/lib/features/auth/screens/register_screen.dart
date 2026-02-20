import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/core/theme/typography.dart';
import 'package:alerta_mobile/features/auth/services/auth_service.dart';
import 'package:alerta_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:alerta_mobile/features/profile/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();
  final _duressPinController = TextEditingController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
         backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Basic Progress Indicator (Counter updated)
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: index <= _currentPage ? AppTheme.primaryRed : Colors.white12,
                ),
              );
            }),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: [
                _buildDetailsPage(),
                _buildOtpPage(),
                _buildSecurityPage(),
                _buildCompletionPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who are you?',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: 8),
          Text('Verification is required to prevent misuse.', style: AppTypography.bodySmall),
          const SizedBox(height: 32),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
          ),
          
          const Spacer(),
          ElevatedButton(
            onPressed: () {
               // Mock sending OTP
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending code to your phone...')));
               _nextPage();
            },
            child: const Text('Send Verification Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify Phone',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: 8),
          Text('Enter the code sent to ${_phoneController.text}', style: AppTypography.bodySmall),
          const SizedBox(height: 32),
          
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(letterSpacing: 8),
            decoration: const InputDecoration(
              hintText: '000000',
              prefixIcon: Icon(Icons.sms),
            ),
          ),
          
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // Mock Verify
              if (_otpController.text == '123456') {
                 _nextPage();
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Code (Try 123456)')));
              }
            },
            child: const Text('Verify Code'),
          ),
          TextButton(onPressed: () => _pageController.previousPage(duration: 300.ms, curve: Curves.ease), child: const Text("Edit Information"))
        ],
      ),
    );
  }

  Widget _buildSecurityPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set your Vault Keys',
               style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a 4-Digit Master PIN for daily access, and a Ghost PIN for when you are in danger.', 
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
        
            TextField(
              controller: _pinController,
              obscureText: true,
               keyboardType: TextInputType.number,
               maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Master PIN (4 Digits)',
                helperText: 'Use this to unlock the app normally.',
                prefixIcon: Icon(Icons.lock),
                counterText: "",
              ),
            ),
            const SizedBox(height: 24),
             TextField(
              controller: _duressPinController,
              obscureText: true,
               keyboardType: TextInputType.number,
               maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Ghost/Duress PIN (4 Digits)',
                helperText: 'ALERT: Entering this PIN will unlock the app but silently send your live location to police. Use only in emergencies.',
                helperMaxLines: 3,
                prefixIcon: Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.warningOrange, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                 counterText: "",
              ),
            ),
        
            const SizedBox(height: 32), // Replaced spacer with fixed height for scrollview
            ElevatedButton(
              onPressed: () async {
                try {
                  // 1. Register on server
                  await AuthService().register(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    pin: _pinController.text,
                    duressPin: _duressPinController.text,
                  );
                  
                  // 2. Initialize local profile
                  await UserProfileService().createProfile(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                  );
                  
                  _nextPage();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Secure My Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: AppTheme.successGreen)
              .animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text('You are Alerta Ready', style: AppTypography.heading2),
          const SizedBox(height: 16),
          Text(
            'Your implementation of safety starts now.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
               Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
            },
            child: const Text('Enter Dashboard'),
          ),
        ],
      ),
    );
  }
}
