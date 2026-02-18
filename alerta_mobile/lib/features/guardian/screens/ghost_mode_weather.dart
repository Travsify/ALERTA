import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GhostModeWeather extends StatefulWidget {
  const GhostModeWeather({super.key});

  @override
  State<GhostModeWeather> createState() => _GhostModeWeatherState();
}

class _GhostModeWeatherState extends State<GhostModeWeather> {
  final _storage = const FlutterSecureStorage();
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap == null || now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTap = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      _showPinDialog(context);
    }
  }

  Future<void> _unlock() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _showPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text("Unlock Alerta", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pinController,
          autofocus: true,
          keyboardType: TextInputType.number,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
             hintText: "Enter PIN",
             hintStyle: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 0),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final storedPin = await _storage.read(key: 'user_pin') ?? "1234";
              if (pinController.text == storedPin) {
                 if (context.mounted) {
                    Navigator.pop(context);
                    _unlock();
                 }
              } else {
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect PIN!"), backgroundColor: Colors.red));
                 }
              }
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FAAFF), Color(0xFF1E88E5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Secret Unlock Area: Tap 5 times or long press "Lagos"
              GestureDetector(
                onTap: _handleTap,
                onLongPress: _unlock,
                behavior: HitTestBehavior.opaque,
                child: const Column(
                  children: [
                    Text(
                      'Lagos',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      'Mostly Clear',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '28°',
                style: TextStyle(color: Colors.white, fontSize: 96, fontWeight: FontWeight.w100),
              ),
              const FaIcon(FontAwesomeIcons.cloudSun, size: 80, color: Colors.white),
              const SizedBox(height: 48),
              
              // Mock Forecast Data
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _WeatherSmall(day: 'Mon', icon: Icons.wb_sunny, temp: '31°'),
                      _WeatherSmall(day: 'Tue', icon: Icons.wb_cloudy, temp: '29°'),
                      _WeatherSmall(day: 'Wed', icon: Icons.thunderstorm, temp: '26°'),
                      _WeatherSmall(day: 'Thu', icon: Icons.grain, temp: '27°'),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Updated: 2 mins ago',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Text(
                      'tap city 5x',
                      style: TextStyle(color: Colors.white10, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherSmall extends StatelessWidget {
  final String day;
  final IconData icon;
  final String temp;

  const _WeatherSmall({required this.day, required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Icon(icon, color: Colors.white),
        const SizedBox(height: 8),
        Text(temp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
