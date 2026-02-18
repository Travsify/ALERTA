import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/auth/screens/login_screen.dart';
import 'package:alerta_mobile/features/auth/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome to Alerta',
      'desc': 'Your personal safety companion. Designed for Nigeria, built for you.',
      'icon': Icons.shield_moon_rounded,
      'color': AppTheme.primaryBlue,
    },
    {
      'title': 'Smart Panic Button',
      'desc': 'One tap sends your Live Location, Battery Level, and Audio Evidence to trusted contacts.',
      'icon': Icons.sos_rounded,
      'color': AppTheme.primaryRed,
    },
    {
      'title': 'Ride Vetting',
      'desc': 'Stop "One-Chance". Verify every Uber, Bolt, or Bus plate number before you settle in.',
      'icon': Icons.directions_car_filled_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Offline Mesh Network',
      'desc': 'No Service? No Problem. Your SOS hops safely through other Alerta users to reach help.',
      'icon': Icons.wifi_tethering,
      'color': Colors.purple,
    },
    {
      'title': 'Family Crisis Vault',
      'desc': 'A secure, encrypted timeline to manage kidnapping incidents and coordinate with police.',
      'icon': Icons.lock_person,
      'color': AppTheme.successGreen,
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(duration: 500.ms, curve: Curves.easeOutQuart);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage != _slides.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Minimalist Icon Container
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (slide['color'] as Color).withOpacity(0.1),
                            border: Border.all(
                              color: (slide['color'] as Color).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 80,
                            color: slide['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isCurrent = _currentPage == index;
                  return AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isCurrent ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isCurrent ? _slides[_currentPage]['color'] as Color : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: _currentPage == _slides.length - 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _finishOnboarding,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: const Text('SKIP', style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _slides[_currentPage]['color'] as Color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
