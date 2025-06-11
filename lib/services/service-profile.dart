import 'dart:convert';
import 'dart:io';
import 'package:final_app/models/profile-model.dart';
import 'package:http/http.dart' as https;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

class ProfileService {
  static HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  static const String _baseUrl = 'https://graduation.arabic4u.org';
  static const storage = FlutterSecureStorage();

  static Future<String?> _getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  static Future<ProfileModel?> getProfile() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final profile = ProfileModel.fromJson(jsonData['data']);
      
      // ✅ Store user id - this line was moved inside the if block
      await storage.write(key: 'user_id', value: profile.id.toString());
      
      return profile;
    } else {
      print('Get profile failed: ${response.body}');
      return null;
    }
  }

  static Future<bool> updateProfile({
    String? name = '',
    String? email = '',
    File? avatar,
    bool removeAvatar = false,
  }) async {
    final token = await _getAccessToken();
    final request = https.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/auth/profile')
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name ?? '';
    request.fields['email'] = email ?? '';

    if (avatar != null) {
      request.files.add(await https.MultipartFile.fromPath(
        'avatar',
        avatar.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else if (removeAvatar) {
      request.fields['avatar'] = '';
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return true;
      } else {
        print('Update profile failed: $responseBody');
        return false;
      }
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}