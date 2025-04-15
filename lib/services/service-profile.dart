import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  final http.Client client;
  final FlutterSecureStorage secureStorage;
  final String baseUrl;

  ProfileService({
    required this.client,
    required this.secureStorage,
    this.baseUrl = "https://graduation.arabic4u.org",
  });

  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('No access token found');

    final response = await client.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? {};
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? imageUrl,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('No access token found');

    final response = await client.post(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (imageUrl != null) 'avatar': imageUrl, 
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('No access token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/upload-profile-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    var response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseData);
      return jsonResponse['data']['imageUrl'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
