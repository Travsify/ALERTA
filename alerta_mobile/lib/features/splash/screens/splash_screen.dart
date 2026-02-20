import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/auth/screens/login_screen.dart';
import 'package:alerta_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:alerta_mobile/features/subscription/services/subscription_service.dart';
import 'package:alerta_mobile/features/profile/services/user_profile_service.dart';
import 'package:alerta_mobile/features/guardian/screens/ghost_mode_calculator.dart';
import 'package:alerta_mobile/features/guardian/screens/ghost_mode_weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    try {
      debugPrint("[SPLASH] Initializing services...");
      
      // Minimum display time for branding
      final minTime = Future.delayed(const Duration(seconds: 3));
      
      final subService = SubscriptionService();
      
      // Initialize critical services in parallel
      await Future.wait([
        subService.initialize(),
        UserProfileService().loadProfile(),
        minTime,
      ]).timeout(const Duration(seconds: 7), onTimeout: () {
        debugPrint("[SPLASH] Startup timed out, proceeding...");
        return [];
      });

      final storage = const FlutterSecureStorage();
      final ghostMode = await storage.read(key: 'ghost_mode_enabled');
      final ghostType = await storage.read(key: 'ghost_mode_type') ?? 'calculator';
      final isLoggedIn = await storage.read(key: 'auth_token') != null;

      if (!mounted) return;

      Widget nextScreen;
      if (ghostMode == 'true') {
        nextScreen = ghostType == 'weather' 
            ? const GhostModeWeather() 
            : const GhostModeCalculator();
      } else if (isLoggedIn) {
        nextScreen = const DashboardScreen();
      } else {
        nextScreen = const LoginScreen();
      }

      // Remove native splash just before showing the new screen
      FlutterNativeSplash.remove();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      debugPrint("[SPLASH] Critical Error: $e");
      FlutterNativeSplash.remove();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Minimalist pulse
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryRed.withOpacity(0.15),
                  ),
                ).animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(1, 1), end: const Offset(1.8, 1.8), duration: 2.seconds)
                .fadeOut(duration: 2.seconds),
                
                const Icon(
                  Icons.shield_moon_rounded,
                  size: 90,
                  color: AppTheme.primaryRed,
                ).animate().fadeIn(duration: 600.ms).scale(duration: 600.ms),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'ALERTA',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 12),
            Text(
              'NIGERIA\'S SAFETY COMPANION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 800.ms),
            const Spacer(),
            const Text(
              'BUILD: 1.0.2-FINAL-CHECK',
              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 10),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
