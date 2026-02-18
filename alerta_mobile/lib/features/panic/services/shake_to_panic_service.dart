import 'dart:async';
import 'dart:math';
import 'package:alerta_mobile/features/panic/services/panic_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service that detects violent shaking and triggers SOS
class ShakeToPanicService {
  static final ShakeToPanicService _instance = ShakeToPanicService._internal();
  factory ShakeToPanicService() => _instance;
  ShakeToPanicService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  final PanicService _panicService = PanicService();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  // Shake detection parameters
  static const double _shakeThreshold = 25.0; // Acceleration threshold (m/s²)
  static const int _shakeCountRequired = 3; // Number of shakes needed
  static const int _shakeTimeWindow = 2000; // Time window in milliseconds

  final List<DateTime> _shakeTimestamps = [];
  DateTime? _lastShakeTime;

  /// Enable shake detection
  void enable() {
    if (_isEnabled) return;
    
    _isEnabled = true;
    _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
    debugPrint("🤝 Shake to Panic: ENABLED");
  }

  /// Disable shake detection
  void disable() {
    _isEnabled = false;
    _subscription?.cancel();
    _subscription = null;
    _shakeTimestamps.clear();
    debugPrint("🤝 Shake to Panic: DISABLED");
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate magnitude of acceleration
    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    // Ignore if shake happened too recently (debounce)
    final now = DateTime.now();
    if (_lastShakeTime != null && 
        now.difference(_lastShakeTime!).inMilliseconds < 200) {
      return;
    }

    // Check if acceleration exceeds threshold
    if (magnitude > _shakeThreshold) {
      _lastShakeTime = now;
      _shakeTimestamps.add(now);

      // Remove old timestamps outside the time window
      _shakeTimestamps.removeWhere(
        (timestamp) => now.difference(timestamp).inMilliseconds > _shakeTimeWindow
      );

      debugPrint("🤝 Shake detected! Count: ${_shakeTimestamps.length}");

      // Check if we have enough shakes in the time window
      if (_shakeTimestamps.length >= _shakeCountRequired) {
        _triggerPanic();
        _shakeTimestamps.clear();
      }
    }
  }

  void _triggerPanic() {
    debugPrint("🚨 SHAKE PANIC TRIGGERED!");
    _panicService.triggerPanic();
  }

  void dispose() {
    disable();
  }
}
