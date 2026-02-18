import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/core/utils/biometric_helper.dart';
import 'package:alerta_mobile/features/auth/screens/register_screen.dart';
import 'package:alerta_mobile/features/auth/services/auth_service.dart';
import 'package:alerta_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:alerta_mobile/features/profile/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:alerta_mobile/features/panic/services/panic_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  final _authService = AuthService();
  final _biometricHelper = BiometricHelper();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    // Only prompt biometrics if user has logged in before (has stored PIN)
    final hasCredentials = await _authService.hasStoredCredentials();
    if (!hasCredentials) return;

    // Small delay to let the UI build slightly before prompting
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final available = await _biometricHelper.isAvailable();
      if (available) {
         _handleBiometricLogin();
      }
    } catch (e) {
      debugPrint("Biometric check failed: $e");
    }
  }


  void _handleLogin() async {
    setState(() => _isLoading = true);
    final result = await _authService.login(_emailController.text, _pinController.text);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result == AuthResult.success || result == AuthResult.duress) {
        
        // Load profile from server now that we have a token
        await UserProfileService().loadProfile();

        if (result == AuthResult.duress) {
           // SILENT ALARM TRAP
           // We do NOT tell the user. We just trigger it.
           PanicService().triggerSilentAlarm(); 
           debugPrint("SILENT DURESS ALARM TRIGGERED");
        }

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN or Email')));
      }
    }
  }

  void _handleBiometricLogin() async {
    final available = await _biometricHelper.isAvailable();
    if (!available) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not set up or unavailable')));
       return;
    }

    final authenticated = await _biometricHelper.authenticate();
    if (authenticated && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo / Brand
              const Icon(
                Icons.shield_moon_rounded,
                size: 80,
                color: AppTheme.primaryRed,
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              Text(
                'Alerta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Safety in your pocket.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white54,
                    ),
              ),
              const SizedBox(height: 60),

              // Inputs
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                 style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Master PIN', // Changed from Security PIN
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                  suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.white54),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 32),

              // Actions
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Access Safe Vault'),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Biometric Option
              OutlinedButton.icon(
                onPressed: _handleBiometricLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.fingerprint, size: 28),
                label: const Text('Unlock with Biometrics'),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

              const Spacer(),
              TextButton(
                onPressed: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterScreen()));
                },
                child: RichText(
                  text: const TextSpan(
                    text: "New to Alerta? ",
                    style: TextStyle(color: Colors.white54),
                    children: [
                      TextSpan(
                        text: "Activate Account",
                        style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
