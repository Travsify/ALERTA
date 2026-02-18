import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/guardian/services/guardian_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GuardianModeScreen extends StatefulWidget {
  const GuardianModeScreen({super.key});

  @override
  State<GuardianModeScreen> createState() => _GuardianModeScreenState();
}

class _GuardianModeScreenState extends State<GuardianModeScreen> {
  // Simple local state for demo, ideally provide via Riverpod/Provider
  final GuardianService _service = GuardianService();
  double _sliderValue = 15; // Default 15 mins

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _service.isActive ? Colors.black : AppTheme.darkBackground,
          appBar: AppBar(
            title: const Text('Guardian Mode'),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_service.isActive) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot exit while Active! Stop the timer first.')));
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_service.isActive) ...[
                  // SETUP VIEW
                  const Icon(FontAwesomeIcons.personWalkingArrowRight, size: 64, color: AppTheme.primaryBlue),
                  const SizedBox(height: 24),
                  Text('Set Journey Timer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'If you don\'t check in before the timer ends, we will automatically send an SOS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 48),
                  
                  Text('${_sliderValue.round()} min', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  Slider(
                    value: _sliderValue, 
                    min: 5, 
                    max: 60, 
                    divisions: 11,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (v) => setState(() => _sliderValue = v)
                  ),
                  
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         _service.startMonitoring(_sliderValue.round());
                      },
                      icon: const Icon(Icons.shield),
                      label: const Text('START MONITORING'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                    ),
                  )
                ] else ...[
                  // ACTIVE VIEW
                  const Spacer(),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryRed, width: 4),
                      boxShadow: [
                         BoxShadow(color: AppTheme.primaryRed.withOpacity(0.4), blurRadius: 40, spreadRadius: 10)
                      ]
                    ),
                    child: Center(
                      child: Text(
                        _service.formattedTime,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
                      ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds).then().fade(begin: 1, end: 0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('GUARDIAN ACTIVE', style: TextStyle(color: AppTheme.primaryRed, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const Text('We are watching over you.', style: TextStyle(color: Colors.white38)),
                  
                  const Spacer(),
                  const Text('Requires PIN to cancel', style: TextStyle(color: Colors.white24, fontSize: 12)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // In real app, prompt for PIN here
                        _showPinDialog(context);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('I\'M SAFE - STOP TIMER'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.successGreen,
                        side: const BorderSide(color: AppTheme.successGreen, width: 2),
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text("Confirm Safety", style: TextStyle(color: Colors.white)),
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
            onPressed: () {
              if (pinController.text == "1234") { // Mock PIN
                 _service.stopMonitoring();
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardian Mode Deactivated. Glad you are safe.")));
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect PIN!"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }
}
