import 'dart:async';
import 'package:alerta_mobile/features/panic/services/panic_service.dart';
import 'package:flutter/foundation.dart';

class DeadManService extends ChangeNotifier {
  static final DeadManService _instance = DeadManService._internal();
  factory DeadManService() => _instance;
  DeadManService._internal();

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isActive = false;

  bool get isActive => _isActive;
  int get secondsRemaining => _secondsRemaining;

  /// Start the countdown
  void start(int minutes) {
    _isActive = true;
    _secondsRemaining = minutes * 60;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _onTimeout();
      }
    });
    
    debugPrint("⏲️ DEAD MAN'S SWITCH: Activated for $minutes minutes");
  }

  /// Stop/Reset the countdown (User is safe)
  void stop() {
    _isActive = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
    debugPrint("✅ DEAD MAN'S SWITCH: Deactivated");
  }

  /// Extend timer
  void extend(int minutes) {
    _secondsRemaining += (minutes * 60);
    notifyListeners();
    debugPrint("➕ DEAD MAN'S SWITCH: Extended by $minutes minutes");
  }

  // Define a duration for the proactive monitoring, e.g., 5 minutes
  final Duration _proactiveMonitoringDuration = const Duration(minutes: 5);

  void _triggerEmergency() {
    _isActive = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners(); // Notify listeners that the state has changed

    debugPrint("🆘 DEAD MAN'S SWITCH: TIMEOUT! Triggering emergency alert...");
    PanicService().triggerPanic();
  }

  Future<void> _onTimeout() async { // Changed to async
    _isActive = false;
    _timer?.cancel();
    // Proactive Server-Side Monitoring
    try {
      await ApiService().post('/panic/heartbeat', {
        'expires_at': DateTime.now().add(_proactiveMonitoringDuration).toIso8601String(), // Use defined duration
        'latitude': 0.0, // Placeholder
        'longitude': 0.0,
      });
      debugPrint("🛡️ BACKEND: Proactive monitoring active");
    } catch (e) {
      debugPrint("⚠️ BACKEND: Could not start proactive monitoring: $e");
    }

    _timer = Timer(_proactiveMonitoringDuration, () { // Use defined duration
      _triggerEmergency();
    });
    // The original debugPrint and PanicService().triggerPanic() are now moved to _triggerEmergency()
    // as they should only happen after the proactive monitoring duration expires.
    debugPrint("⏳ DEAD MAN'S SWITCH: Countdown finished. Proactive monitoring started for ${_proactiveMonitoringDuration.inMinutes} minutes.");
    notifyListeners(); // Notify listeners about the state change (e.g., _isActive)
  }
}
