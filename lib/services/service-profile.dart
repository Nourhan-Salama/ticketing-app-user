// // profile-service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ProfileService {
//   final http.Client client;
//   final FlutterSecureStorage secureStorage;
//   final String baseUrl;

//   ProfileService({
//     required this.client,
//     required this.secureStorage,
//     this.baseUrl = "https://graduation.arabic4u.org",
//   });

//   Future<String?> _getAccessToken() async {
//     return await secureStorage.read(key: 'access_token');
//   }

//   Future<Map<String, dynamic>> updateProfile({
//     required String name,
//     required String email,
//     File? avatar,
//   }) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception('User not authenticated');

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/auth/profile'),
//       )
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['name'] = name
//         ..fields['email'] = email;

//       if (avatar != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'avatar',
//             avatar.path,
//             filename: avatar.path.split('/').last,
//           ),
//         );
//       }

//       final response = await request.send();
//       final responseString = await response.stream.bytesToString();
//       final responseData = json.decode(responseString);

//       if (response.statusCode == 200) {
//         return responseData['data'] ?? {};
//       } else {
//         throw Exception('Failed to update profile: ${responseData['message']}');
//       }
//     } catch (e) {
//       throw Exception('Error updating profile: $e');
//     }
//   }

//   Future<Map<String, dynamic>> getProfile() async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception('User not authenticated');

//     final response = await client.get(
//       Uri.parse('$baseUrl/auth/profile'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );

//     final responseData = json.decode(response.body);
//     if (response.statusCode == 200) {
//       return responseData['data'] ?? {};
//     } else {
//       throw Exception('Failed to load profile: ${responseData['message']}');
//     }
//   }

//   Future<void> saveUserData({
//     required String name,
//     required String email,
//     String? imagePath,
//   }) async {
//     await secureStorage.write(key: 'user_name', value: name);
//     await secureStorage.write(key: 'user_email', value: email);
//     if (imagePath != null) {
//       await secureStorage.write(key: 'user_image_path', value: imagePath);
//     }
//   }

//   Future<Map<String, String?>> loadUserData() async {
//     return {
//       'name': await secureStorage.read(key: 'user_name'),
//       'email': await secureStorage.read(key: 'user_email'),
//       'image_path': await secureStorage.read(key: 'user_image_path'),
//     };
//   }

//   Future<void> clearUserData() async {
//     await secureStorage.delete(key: 'user_name');
//     await secureStorage.delete(key: 'user_email');
//     await secureStorage.delete(key: 'user_image_path');
//   }
// }

import 'dart:async';
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

  //  Get access token
  Future<String?> _getAccessToken() async {
    try {
      return await secureStorage.read(key: 'access_token');
    } catch (e) {
      throw Exception('Failed to retrieve access token: $e');
    }
  }

  //  Get profile from API
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found - User not authenticated');
    }

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data'] ?? {};
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - Please login again');
      } else {
        throw Exception(
          'Failed to load profile (${response.statusCode}): ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //  Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    File? avatar,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found - User not authenticated');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/profile'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['first_name'] = firstName
        ..fields['last_name'] = lastName
        ..fields['email'] = email;

      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      if (response.statusCode == 200) {
        return responseData['data'] ?? {};
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - Please login again');
      } else {
        throw Exception(
          'Failed to update profile (${response.statusCode}): ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //  Save user data securely
  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    required String email,
    String? imagePath,
  }) async {
    try {
      await secureStorage.write(key: 'user_first_name', value: firstName);
      await secureStorage.write(key: 'user_last_name', value: lastName);
      await secureStorage.write(key: 'user_email', value: email);
      if (imagePath != null) {
        await secureStorage.write(key: 'user_image_path', value: imagePath);
      }
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  //  Load user data from storage
  Future<Map<String, String?>> loadUserData() async {
    try {
      final firstName = await secureStorage.read(key: 'user_first_name');
      final lastName = await secureStorage.read(key: 'user_last_name');
      final email = await secureStorage.read(key: 'user_email');
      final imagePath = await secureStorage.read(key: 'user_image_path');

      return {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'image_path': imagePath,
      };
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  //  Clear user data
  Future<void> clearUserData() async {
    try {
      await secureStorage.delete(key: 'user_first_name');
      await secureStorage.delete(key: 'user_last_name');
      await secureStorage.delete(key: 'user_email');
      await secureStorage.delete(key: 'user_image_path');
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }
}
