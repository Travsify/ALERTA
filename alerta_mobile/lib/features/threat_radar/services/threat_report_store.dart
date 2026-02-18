import 'package:flutter/foundation.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_radar_service.dart';

/// Singleton store for community-reported threats
/// In production, this would sync with a backend database
class ThreatReportStore extends ChangeNotifier {
  static final ThreatReportStore _instance = ThreatReportStore._internal();
  factory ThreatReportStore() => _instance;
  ThreatReportStore._internal();

  final List<ThreatZone> _reports = [];

  List<ThreatZone> get reports => List.unmodifiable(_reports);

  /// Add a new threat report from the Safety Map
  void addReport({
    required String name,
    required double latitude,
    required double longitude,
    required String type, // 'danger', 'checkpoint', 'accident'
    double radiusMeters = 300,
  }) {
    final report = ThreatZone(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      type: type,
    );

    _reports.add(report);
    notifyListeners();

    debugPrint('THREAT REPORTED: $name at ($latitude, $longitude)');
  }

  /// Clear old reports (e.g., older than 24 hours)
  void clearOldReports() {
    // In production, filter by timestamp
    // _reports.removeWhere((r) => r.timestamp.isBefore(DateTime.now().subtract(Duration(hours: 24))));
    notifyListeners();
  }

  /// Get all threat zones (mock + community reports)
  List<ThreatZone> getAllThreatZones() {
    // Combine mock data with real reports
    final mockZones = [
      ThreatZone(
        id: 'mock_1',
        name: 'High Risk Area - Armed Robbery',
        latitude: 6.5244,
        longitude: 3.3792,
        radiusMeters: 300,
        type: 'danger',
      ),
      ThreatZone(
        id: 'mock_2',
        name: 'Police Checkpoint',
        latitude: 6.5300,
        longitude: 3.3800,
        radiusMeters: 200,
        type: 'checkpoint',
      ),
    ];

    return [...mockZones, ..._reports];
  }
}
