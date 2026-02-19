import 'dart:async';
import 'package:alerta_mobile/features/panic/services/heartbeat_service.dart';
import 'package:flutter/foundation.dart';

class DeadManService extends ChangeNotifier {
  static final DeadManService _instance = DeadManService._internal();
  factory DeadManService() => _instance;
  DeadManService._internal();

  Timer? _localDisplayTimer;
  int _secondsRemaining = 0;
  bool _isActive = false;

  bool get isActive => _isActive;
  int get secondsRemaining => _secondsRemaining;

  /// Start the countdown and register with server
  Future<void> start(int minutes) async {
    _isActive = true;
    _secondsRemaining = minutes * 60;
    _localDisplayTimer?.cancel();
    
    // 1. Register with Server (Critical)
    await HeartbeatService().startProactiveTimer(minutes);

    // 2. Start Local Display Timer
    _localDisplayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _onLocalTimeout();
      }
    });
    
    debugPrint("⏲️ DEAD MAN'S SWITCH: Activated and Synced with Server");
    notifyListeners();
  }

  /// Stop/Reset (User is safe)
  void stop() {
    _isActive = false;
    _localDisplayTimer?.cancel();
    _localDisplayTimer = null;
    
    // Stop all heartbeat tracking
    HeartbeatService().stop();
    
    notifyListeners();
    debugPrint("✅ DEAD MAN'S SWITCH: Deactivated");
  }

  void _onLocalTimeout() {
    _isActive = false;
    _localDisplayTimer?.cancel();
    _localDisplayTimer = null;
    debugPrint("⏳ DEAD MAN'S SWITCH: Local countdown finished. Server will escalate shortly if not resolved.");
    notifyListeners();
  }
}
