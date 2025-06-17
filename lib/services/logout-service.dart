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
        // ✅ Clear all data even if no token
        await _clearAllData();
        return {
          'code': 200,
          'message': 'Local data cleared (no token found)',
        };
      }

      // ✅ Call API to logout
      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // ✅ Clear local data regardless of API response
      await _clearAllData();

      if (response.statusCode == 200) {
        return {
          'code': 200,
          'message': 'Logout successful',
        };
      } else {
        // ✅ Even if API fails, local data is cleared
        return {
          'code': 200,
          'message': 'Logout completed (API error but local data cleared)',
        };
      }
    } catch (e) {
      // ✅ Clear local data even on exception
      try {
        await _clearAllData();
      } catch (clearError) {
        print('Error clearing data: $clearError');
      }
      
      return {
        'code': 200,
        'message': 'Logout completed (error occurred but local data cleared)',
      };
    }
  }

  // ✅ Force logout - clears everything locally
  Future<Map<String, dynamic>> forceLogout() async {
    try {
      await _clearAllData();
      return {
        'code': 200,
        'message': 'Force logout completed',
      };
    } catch (e) {
      return {
        'code': 500,
        'message': 'Force logout error: ${e.toString()}',
      };
    }
  }

  // ✅ Clear all stored data
  Future<void> _clearAllData() async {
    try {
      // ✅ Clear all secure storage data
      await secureStorage.deleteAll();
      
      // ✅ Alternative: Clear specific keys if you want to keep some data
      // List<String> keysToDelete = [
      //   'access_token',
      //   'refresh_token',
      //   'user_name',
      //   'user_email',
      //   'user_id',
      //   // Add any other keys that should be cleared on logout
      // ];
      
      // for (String key in keysToDelete) {
      //   await secureStorage.delete(key: key);
      // }

      print('All user data cleared from secure storage');
    } catch (e) {
      print('Error clearing secure storage: $e');
      rethrow;
    }
  }
}
