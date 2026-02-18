import 'package:alerta_mobile/features/contacts/services/trusted_contacts_service.dart';
import 'package:alerta_mobile/features/panic/services/mesh_service.dart';
import 'package:alerta_mobile/features/prevention/services/recorder_service.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:alerta_mobile/core/services/api_service.dart';

class PanicService {
  final Battery _battery = Battery();
  final TrustedContactsService _contactsService = TrustedContactsService();
  final RecorderService _recorder = RecorderService();
  final MeshService _meshService = MeshService();

  /// Trigger full panic mode - SMS + Blackbox
  Future<void> triggerPanic() async {
    debugPrint("🚨 PANIC TRIGGERED");
    
    // 1. Get Vital Data
    final position = await _getCurrentLocation();
    final batteryLevel = await _battery.batteryLevel;
    
    // 2. Construct Message
    final mapLink = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    final message = "🆘 SOS EMERGENCY! I am in DANGER. Help me! \n"
        "📍 Location: $mapLink\n"
        "🔋 Battery: $batteryLevel%\n"
        "⏰ Time: ${DateTime.now()}";

    // 3. Get trusted contacts dynamically
    await _contactsService.loadContacts();
    List<String> recipients = _contactsService.getSOSNumbers();
    
    // Fallback if no contacts saved (for demo)
    if (recipients.isEmpty) {
      recipients = ['08012345678']; // Demo number
      debugPrint("⚠️ No trusted contacts saved, using demo number");
    }

    // 4. SMS logic moved to Step 6 for Smart Routing Fallback

    // 5. Trigger Backend Alert (Online Sync: Push + Telegram)
    final sosPayload = {
      'user_id': UserProfileService().profile?.id ?? 'unknown',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'battery_level': batteryLevel,
      'alert_type': 'emergency',
      'is_duress': false,
    };

    bool syncSuccess = false;
    try {
      final response = await ApiService().post('/panic/trigger', {
        ...sosPayload,
        'message': message,
      }).timeout(const Duration(seconds: 5)); // 5s Smart Timeout
      
      if (response.statusCode == 201) {
        syncSuccess = true;
        debugPrint("✅ SOS: Backend synchronized. Push/Telegram triggered.");
      }
    } catch (e) {
      debugPrint("⚠️ SOS: Backend Sync Failed/Timeout. Falling back to Hardware...");
    }

    // 6. Hardware Fallback (Native SIM SMS + Mesh Relay)
    if (!syncSuccess) {
      debugPrint("🚨 SOS: Executing Hardware Fallback (SMS + Mesh)");
      await _sendSMS(message, recipients);
      await _meshService.broadcastSOSOffline(sosPayload);
    }

    // 6. Start Blackbox Recording
    await _startBlackbox();
  }

  /// Silent alarm - same as panic but no local UI feedback
  Future<void> triggerSilentAlarm() async {
    debugPrint("🤫 SILENT ALARM ACTIVATED - Duress PIN Used");
    await triggerPanic();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    // High accuracy is critical for kidnap scenarios
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _sendSMS(String message, List<String> recipients) async {
    debugPrint("📱 Sending SMS to: $recipients");
    
    if (await Permission.sms.request().isGranted) {
      try {
        String result = await sendSMS(message: message, recipients: recipients);
        debugPrint("SMS Result: $result");
      } catch (e) {
        debugPrint("SMS Error: $e");
      }
    } else {
      debugPrint("❌ SMS permission denied");
    }
  }

  Future<void> _startBlackbox() async {
    debugPrint("📹 BLACKBOX: Starting emergency recording...");
    try {
      await _recorder.initialize();
      await _recorder.startAudioRecording();
      debugPrint("✅ Blackbox recording started");
    } catch (e) {
      debugPrint("❌ Blackbox error: $e");
    }
  }
  // Shake Detection
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 15.0; // Sensitivity 
  static const int _shakeDebounceTimeMs = 3000; // 3 seconds between shakes

  /// Start monitoring for shake gestures
  void startShakeDetection() {
    debugPrint("📱 Shake detection started");
    _accelerometerSubscription = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval
    ).listen((UserAccelerometerEvent event) {
        double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
        
        if (acceleration > _shakeThreshold) {
          final now = DateTime.now();
          if (_lastShakeTime == null || 
              now.difference(_lastShakeTime!).inMilliseconds > _shakeDebounceTimeMs) {
            _lastShakeTime = now;
            debugPrint("📳 SHAKE DETECTED! Triggering Panic...");
            triggerPanic();
          }
        }
      },
      onError: (e) => debugPrint("❌ Accelerometer error: $e"),
      cancelOnError: false,
    );
  }

  /// Stop monitoring shake gestures
  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    debugPrint("🛑 Shake detection stopped");
  }

  /// Dispose service resources
  void dispose() {
    stopShakeDetection();
  }
}
