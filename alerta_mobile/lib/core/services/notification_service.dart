import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // Get the token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToBackend(token);
      }

      // Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _saveTokenToBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Foreground message: ${message.notification?.title}");
        // We can show a local notification here if needed
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      debugPrint("Saving FCM Token to backend: $token");
      await ApiService().post('/profile/fcm-token', {'fcm_token': token});
    } catch (e) {
      debugPrint("Error saving FCM token: $e");
    }
  }
}
