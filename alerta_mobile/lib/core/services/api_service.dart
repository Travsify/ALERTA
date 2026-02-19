import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alerta_mobile/core/services/navigation_service.dart';
import 'package:alerta_mobile/features/auth/screens/login_screen.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  
  // Base URL loaded from environment variables
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://alerta-backend.onrender.com/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));
      _handleUnauthorized(response);
      return response;
    } catch (e) {
      debugPrint('API GET Error: $e');
      throw Exception('Network Error');
    }
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      _handleUnauthorized(response);
      return response;
    } catch (e) {
      debugPrint('API POST Error: $e');
      throw Exception('Network Error');
    }
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      _handleUnauthorized(response);
      return response;
    } catch (e) {
      debugPrint('API PUT Error: $e');
      throw Exception('Network Error');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));
      _handleUnauthorized(response);
      return response;
    } catch (e) {
      debugPrint('API DELETE Error: $e');
      throw Exception('Network Error');
    }
  }

  void _handleUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      debugPrint('Unauthorized: Clearing token and logging out');
      _storage.delete(key: 'auth_token');
      
      // Trigger global navigation to login
      NavigationService().pushAndRemoveUntil(const LoginScreen());
    }
  }
}
