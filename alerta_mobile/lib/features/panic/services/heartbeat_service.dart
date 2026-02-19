import 'dart:async';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class HeartbeatService {
  static final HeartbeatService _instance = HeartbeatService._internal();
  factory HeartbeatService() => _instance;
  HeartbeatService._internal();

  Timer? _timer;
  int? _activeAlertId;

  /// Start a proactive timer on the server
  Future<void> startProactiveTimer(int minutes) async {
    final position = await _getCurrentLocation();
    final expiresAt = DateTime.now().add(Duration(minutes: minutes));

    try {
      final response = await ApiService().post('/panic/heartbeat', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'expires_at': expiresAt.toIso8601String(),
      });
      debugPrint("🛡️ SERVER: Proactive monitoring active until $expiresAt");
    } catch (e) {
      debugPrint("⚠️ SERVER: Heartbeat failed: $e");
    }
  }

  /// Start periodic heartbeats for an ACTIVE alert (Tracking)
  void startTracking(int alertId) {
    _activeAlertId = alertId;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) => _sendTrackingHeartbeat());
    debugPrint("📡 TRACKING: Heartbeat monitoring started for alert #$alertId");
  }

  /// Stop all heartbeats
  void stop() {
    _timer?.cancel();
    _timer = null;
    _activeAlertId = null;
    debugPrint("🛑 TRACKING: Heartbeat monitoring stopped");
  }

  Future<void> _sendTrackingHeartbeat() async {
    if (_activeAlertId == null) return;

    try {
      final position = await _getCurrentLocation();
      await ApiService().post('/panic/heartbeat', {
        'alert_id': _activeAlertId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      debugPrint("📡 TRACKING: Heartbeat sent (#$_activeAlertId)");
    } catch (e) {
      debugPrint("⚠️ TRACKING: Heartbeat failed: $e");
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }
}
