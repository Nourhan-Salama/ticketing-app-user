import 'dart:async';
import 'dart:convert';
import 'package:final_app/models/statistics-model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StatisticsService {
  static const String _baseUrl = 'https://graduation.arabic4u.org';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<TicketStatistics> getTechnicianStatistics() async {
    try {
      print('🔍 Step 1: Reading token from Secure Storage...');
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ Token is null or empty');
        throw Exception('No authentication token found');
      }
      print('✅ Token retrieved: ${accessToken.substring(0, 20)}...');

      final url = Uri.parse('$_baseUrl/api/users/statistics');
      print('🌐 Request URL: $url');

      print('📤 Sending GET request with token...');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('🔍 Decoded JSON: $responseData');

        if (responseData['data'] == null) {
          print('⚠️ Data field is null');
          throw Exception('API returned null data');
        }

        try {
          final model = TicketStatistics.fromJson(responseData['data']);
          print('✅ Statistics model parsed successfully');
          return model;
        } catch (e) {
          print('❌ Error parsing statistics model: $e');
          print('🧪 Raw data that caused issue: ${responseData['data']}');
          throw Exception('Failed to parse statistics data');
        }

      } else if (response.statusCode == 401) {
        print('🔐 Token expired. Attempting to refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          print('🔁 Token refreshed. Retrying getTechnicianStatistics...');
          return await getTechnicianStatistics();
        } else {
          throw Exception('Unable to refresh token');
        }

      } else if (response.statusCode == 403) {
        print('❌ Access Denied (403): Check token validity or user permissions');
        final errorResponse = json.decode(response.body);
        print('🔒 Error Message: ${errorResponse['message']}');
        throw Exception('Access Denied: ${errorResponse['message']}');
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to load statistics');
      }

    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Network error occurred');
    } on TimeoutException catch (e) {
      print('⏱ Request timeout: $e');
      throw Exception('Request timed out');
    } catch (e) {
      print('❗ Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token found');
        return false;
      }

      final url = Uri.parse('$_baseUrl/auth/refresh_tokens/refresh');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': refreshToken,
        }),
      ).timeout(const Duration(seconds: 30));

      print('🔄 Refresh Token Response: ${response.statusCode}');
      print('📥 Refresh Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null && newRefreshToken != null) {
          await _storage.write(key: 'access_token', value: newAccessToken);
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
          print('✅ Tokens refreshed successfully');
          return true;
        } else {
          print('❌ Missing tokens in response');
          return false;
        }
      } else {
        print('❌ Failed to refresh token: ${response.statusCode}');
        return false;
      }

    } catch (e) {
      print('❌ Exception during token refresh: $e');
      return false;
    }
  }
}

