import 'dart:async';
import 'package:alerta_mobile/features/panic/services/panic_service.dart';
import 'package:flutter/foundation.dart';

class GuardianService extends ChangeNotifier {
  final PanicService _panicService = PanicService();
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isActive = false;

  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;

  // Start the Guardian Timer
  void startMonitoring(int durationInMinutes) {
    if (_isActive) return;

    _remainingSeconds = durationInMinutes * 60;
    _isActive = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _triggerTimeout();
      }
    });
  }

  // User confirmed safety
  void stopMonitoring() {
    _timer?.cancel();
    _isActive = false;
    _remainingSeconds = 0;
    notifyListeners();
  }

  // Timer expired - DANGER
  void _triggerTimeout() {
    stopMonitoring();
    // Trigger SOS automatically
    _panicService.triggerPanic();
    debugPrint("GUARDIAN MODE: TIMEOUT TRIGGERED SOS");
  }
  
  String get formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
