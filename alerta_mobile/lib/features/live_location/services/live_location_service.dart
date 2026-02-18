import 'dart:async';
import 'package:alerta_mobile/features/contacts/services/trusted_contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveLocationService extends ChangeNotifier {
  static final LiveLocationService _instance = LiveLocationService._internal();
  factory LiveLocationService() => _instance;
  LiveLocationService._internal();

  StreamSubscription<Position>? _positionStream;
  final TrustedContactsService _contactsService = TrustedContactsService();

  bool _isSharing = false;
  bool get isSharing => _isSharing;

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  DateTime? _sharingStartTime;
  int? _shareDurationMinutes;
  Timer? _endTimer;
  Timer? _updateTimer;

  /// Start sharing location with trusted contacts
  Future<void> startSharing({int durationMinutes = 30, int updateIntervalMinutes = 5}) async {
    if (_isSharing) return;

    _isSharing = true;
    _sharingStartTime = DateTime.now();
    _shareDurationMinutes = durationMinutes;
    notifyListeners();

    // Load contacts
    await _contactsService.loadContacts();
    final recipients = _contactsService.getLocationShareNumbers();

    if (recipients.isEmpty) {
      debugPrint("⚠️ No contacts to share location with");
      return;
    }

    // Get initial position and share
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _lastPosition = position;
    await _sendLocationUpdate(recipients, "Started sharing", position);

    // Start periodic updates
    _updateTimer = Timer.periodic(Duration(minutes: updateIntervalMinutes), (timer) async {
      if (_isSharing) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _lastPosition = pos;
        await _sendLocationUpdate(recipients, "Location update", pos);
        notifyListeners();
      }
    });

    // Auto-stop after duration
    _endTimer = Timer(Duration(minutes: durationMinutes), () {
      stopSharing();
    });

    debugPrint("📍 Live location sharing started for $durationMinutes minutes");
  }

  /// Stop sharing location
  Future<void> stopSharing() async {
    if (!_isSharing) return;

    _isSharing = false;
    _updateTimer?.cancel();
    _endTimer?.cancel();

    // Notify contacts that sharing has stopped
    await _contactsService.loadContacts();
    final recipients = _contactsService.getLocationShareNumbers();
    if (recipients.isNotEmpty && _lastPosition != null) {
      await _sendLocationUpdate(recipients, "Stopped sharing", _lastPosition!);
    }

    _lastPosition = null;
    _sharingStartTime = null;
    notifyListeners();

    debugPrint("📍 Live location sharing stopped");
  }

  Future<void> _sendLocationUpdate(List<String> recipients, String status, Position position) async {
    final mapLink = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    final message = "📍 Alerta Live Location\n"
        "Status: $status\n"
        "Location: $mapLink\n"
        "Time: ${DateTime.now().toString().substring(0, 19)}";

    if (await Permission.sms.request().isGranted) {
      try {
        await sendSMS(message: message, recipients: recipients);
        debugPrint("📱 Location SMS sent to ${recipients.length} contacts");
      } catch (e) {
        debugPrint("SMS Error: $e");
      }
    }
  }

  int get remainingMinutes {
    if (_sharingStartTime == null || _shareDurationMinutes == null) return 0;
    final elapsed = DateTime.now().difference(_sharingStartTime!).inMinutes;
    return (_shareDurationMinutes! - elapsed).clamp(0, _shareDurationMinutes!);
  }

  @override
  void dispose() {
    stopSharing();
    super.dispose();
  }
}
