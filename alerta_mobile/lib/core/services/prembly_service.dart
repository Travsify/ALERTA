import 'dart:convert';
import 'package:http/http.dart' as http;

class PremblyService {
  // Base URL for Prembly IdentityPass API
  static const String _baseUrl = 'https://api.prembly.com/identitypass/verification';
  
  // TODO: Replace with your actual API Key and App ID (if applicable)
  // It is recommended to use flutter_dotenv to store these securely
  static const String _apiKey = 'live_sk_2a238fff60994964b3f8d9a5a6178d23';
 

  /// Verifies a vehicle plate number
  /// Returns the API response as a Map
  Future<Map<String, dynamic>> verifyVehicle(String plateNumber) async {
    final url = Uri.parse('$_baseUrl/vehicle');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey, 
        },
        body: jsonEncode({
          'vehicle_number': plateNumber, // Common field name, might be plate_number
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return data['data'] ?? data;
        } else {
           throw Exception(data['message'] ?? 'Verification failed');
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
