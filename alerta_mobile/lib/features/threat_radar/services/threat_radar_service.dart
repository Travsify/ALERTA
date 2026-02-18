import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_report_store.dart';

class ThreatZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String type; // 'danger', 'checkpoint', 'accident'

  ThreatZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 500,
    required this.type,
  });
}

class ThreatRadarService extends ChangeNotifier {
  StreamSubscription<Position>? _positionStream;
  List<ThreatZone> _threatZones = [];
  ThreatZone? _nearestThreat;
  double? _distanceToThreat;

  ThreatZone? get nearestThreat => _nearestThreat;
  double? get distanceToThreat => _distanceToThreat;

  // Mock data - In reality, this would come from the Safety Map backend
  void loadMockThreatZones() {
    _threatZones = [
      ThreatZone(
        id: 'tz_1',
        name: 'High Risk Area - Armed Robbery',
        latitude: 6.5244,
        longitude: 3.3792,
        radiusMeters: 300,
        type: 'danger',
      ),
      ThreatZone(
        id: 'tz_2',
        name: 'Police Checkpoint - Verify Before Proceeding',
        latitude: 6.5300,
        longitude: 3.3800,
        radiusMeters: 200,
        type: 'checkpoint',
      ),
      ThreatZone(
        id: 'tz_3',
        name: 'Reported Kidnap Spot',
        latitude: 6.5180,
        longitude: 3.3900,
        radiusMeters: 400,
        type: 'danger',
      ),
    ];
  }

  void startMonitoring() {
    // Load threat zones from the shared store
    _threatZones = ThreatReportStore().getAllThreatZones();

    // Listen for new reports
    ThreatReportStore().addListener(_onNewReport);

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Update every 50 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _checkProximity(position);
    });

    debugPrint("ThreatRadar: Monitoring Started");
  }

  void stopMonitoring() {
    _positionStream?.cancel();
    ThreatReportStore().removeListener(_onNewReport);
    _nearestThreat = null;
    _distanceToThreat = null;
    notifyListeners();
    debugPrint("ThreatRadar: Monitoring Stopped");
  }

  void _onNewReport() {
    // Reload threat zones when new reports come in
    _threatZones = ThreatReportStore().getAllThreatZones();
    debugPrint("ThreatRadar: Reloaded ${_threatZones.length} threat zones");
  }

  void _checkProximity(Position currentPosition) {
    ThreatZone? closest;
    double minDistance = double.infinity;

    for (final zone in _threatZones) {
      final distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance < zone.radiusMeters && distance < minDistance) {
        closest = zone;
        minDistance = distance;
      }
    }

    if (closest != null) {
      _nearestThreat = closest;
      _distanceToThreat = minDistance;
      notifyListeners();
      debugPrint("THREAT ALERT: ${closest.name} is ${minDistance.toStringAsFixed(0)}m away!");
    } else if (_nearestThreat != null) {
      // User left the threat zone
      _nearestThreat = null;
      _distanceToThreat = null;
      notifyListeners();
    }
  }

  // Haversine formula for distance calculation
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
