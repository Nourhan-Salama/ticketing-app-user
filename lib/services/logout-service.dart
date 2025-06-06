import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogoutService {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  LogoutService({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : client = client ?? http.Client(),
        secureStorage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await secureStorage.read(key: 'access_token');

      if (token == null) {
        return {
          'code': 401,
          'message': 'No access token found',
        };
      }

      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await secureStorage.delete(key: 'access_token');
        await secureStorage.delete(key: 'refresh_token');

        // Add logs to verify token deletion
        print(
            'Access token deleted: ${await secureStorage.read(key: 'access_token')}');
        print(
            'Refresh token deleted: ${await secureStorage.read(key: 'refresh_token')}');

        return {
          'code': 200,
          'message': 'Logout successful',
        };
      } else {
        final error = response.body;
        return {
          'code': response.statusCode,
          'message': 'Logout failed: $error',
        };
      }
    } catch (e) {
      return {
        'code': 500,
        'message': 'Logout error: ${e.toString()}',
      };
    }
  }
}
