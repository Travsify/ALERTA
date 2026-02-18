import 'dart:convert';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final bool isVerified;
  final DateTime? createdAt;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.isVerified = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'isVerified': isVerified,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'User',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    isVerified: json['isVerified'] ?? false,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
  );

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isVerified,
  }) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    isVerified: isVerified ?? this.isVerified,
    createdAt: createdAt,
  );
}

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final _storage = const FlutterSecureStorage();
  final _api = ApiService();
  static const String _profileKey = 'user_profile';

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool get isLoggedIn => _profile != null;

  /// Load profile from storage or server
  Future<void> loadProfile() async {
    try {
      // 1. Try to load from server first (if token exists)
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final response = await _api.get('/user');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _profile = UserProfile.fromJson(data['user']);
          await _saveProfileLocally();
          notifyListeners();
          return;
        }
      }

      // 2. Fallback to local storage if offline or server fails
      final data = await _storage.read(key: _profileKey);
      if (data != null) {
        _profile = UserProfile.fromJson(jsonDecode(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Initialize profile (Usually handled after register/login)
  Future<void> createProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _profile = UserProfile(
      name: name,
      email: email,
      phone: phone,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    await _saveProfileLocally();
    notifyListeners();
  }

  /// Update profile on server and locally
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (_profile == null) return;
    
    // Sync with server
    try {
      final response = await _api.put('/profile', {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profile = UserProfile.fromJson(data['user']);
        await _saveProfileLocally();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      // Update locally as fallback
      _profile = _profile!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      await _saveProfileLocally();
      notifyListeners();
    }
  }

  Future<void> _saveProfileLocally() async {
    if (_profile != null) {
      await _storage.write(key: _profileKey, value: jsonEncode(_profile!.toJson()));
    }
  }

  /// Logout - clear all user data
  Future<void> logout() async {
    try {
      await _api.post('/logout', {});
    } catch (_) {}
    
    await _storage.delete(key: _profileKey);
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_pin');
    await _storage.delete(key: 'duress_pin');
    _profile = null;
    notifyListeners();
    debugPrint('User logged out');
  }

  /// Change Master PIN
  Future<void> changeMasterPin(String oldPin, String newPin) async {
    final response = await _api.put('/profile/password', {
      'current_password': oldPin,
      'password': newPin,
      'password_confirmation': newPin,
    });

    if (response.statusCode == 200) {
      await _storage.write(key: 'user_pin', value: newPin);
      debugPrint('Master PIN changed on server');
    } else {
      throw Exception('Failed to change PIN: ${response.body}');
    }
  }

  /// Change Ghost/Duress PIN
  Future<void> changeGhostPin(String masterPin, String newGhostPin) async {
    final response = await _api.put('/profile/duress-pin', {
      'password': masterPin,
      'duress_pin': newGhostPin,
    });

    if (response.statusCode == 200) {
      await _storage.write(key: 'duress_pin', value: newGhostPin);
      debugPrint('Ghost PIN changed on server');
    } else {
      throw Exception('Failed to change Ghost PIN: ${response.body}');
    }
  }
}
