import 'dart:convert';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthResult { success, duress, failure }

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();
  
  Future<AuthResult> login(String email, String pin) async {
    try {
      final response = await _api.post('/login', {
        'email': email,
        'password': pin,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'auth_token', value: data['token']);
        await _storage.write(key: 'user_pin', value: pin); // Cache locally for fast biometric unlock

        if (data['is_duress'] == true) {
          return AuthResult.duress;
        }
        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String pin,
    required String duressPin,
  }) async {
    final response = await _api.post('/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': pin,
      'duress_pin': duressPin,
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'user_pin', value: pin);
      await _storage.write(key: 'duress_pin', value: duressPin);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<bool> checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<bool> hasStoredCredentials() async {
    final pin = await _storage.read(key: 'user_pin');
    return pin != null;
  }
}

