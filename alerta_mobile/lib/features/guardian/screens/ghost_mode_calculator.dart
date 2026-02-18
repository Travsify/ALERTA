import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GhostModeCalculator extends StatefulWidget {
  const GhostModeCalculator({super.key});

  @override
  State<GhostModeCalculator> createState() => _GhostModeCalculatorState();
}

class _GhostModeCalculatorState extends State<GhostModeCalculator> {
  String _display = "0";
  String _input = "";
  final _storage = const FlutterSecureStorage();

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        _display = "0";
        _input = "";
      } else if (value == "=") {
        // Check if input matches PIN to unlock
        _checkUnlock(_input);
        _display = _calculate(_input); // Show fake calculation
        _input = "";
      } else {
        if (_display == "0") _display = "";
        _display += value;
        _input += value;
      }
    });
  }

  String _calculate(String expression) {
    // Very dummy calculation for disguise
    try {
      // Allow only simple addition for demo visual
      if (expression.contains('+')) {
        final parts = expression.split('+');
        int sum = 0;
        for (var p in parts) sum += int.tryParse(p) ?? 0;
        return sum.toString();
      }
      return expression; 
    } catch (e) {
      return "Error";
    }
  }

  Future<void> _checkUnlock(String input) async {
    // In real app, user sets this PIN. Defaulting to '1234' or '0000' for demo
    // Or fetch 'user_pin' from storage
    final String? userPin = await _storage.read(key: 'user_pin');
    
    // Safety fallback: 1234 always unlocks for demo if no pin set
    if (input == (userPin ?? "1234")) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  _display,
                  style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            // Keypad
            ...[
              ["C", "÷", "×", "⌫"],
              ["7", "8", "9", "-"],
              ["4", "5", "6", "+"],
              ["1", "2", "3", "="],
              ["0", ".", "", ""]
            ].map((row) => Expanded(
              child: Row(
                children: row.map((text) {
                  if (text.isEmpty) return const Spacer();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _onPressed(text),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: text == "=" 
                              ? Colors.orange 
                              : ["C", "⌫"].contains(text) ? Colors.grey : Colors.grey[900],
                          padding: const EdgeInsets.all(24),
                        ),
                        child: Text(text, style: const TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
