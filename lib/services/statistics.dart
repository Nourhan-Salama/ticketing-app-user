import 'dart:convert';
import 'package:final_app/models/statistics-model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStatisticsService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://graduation.arabic4u.org/api';

  Future<TicketStatistics?> fetchStatistics() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('No authentication token found');

      print('Sending request to: $_baseUrl/users/statistics');
      print('Authorization: Bearer $token');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/statistics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched data: $data');
        return TicketStatistics.fromJson(data['data']);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow;
    }
  }
}

