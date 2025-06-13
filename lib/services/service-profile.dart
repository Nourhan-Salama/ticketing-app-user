// import 'dart:convert';
// import 'dart:io';
// import 'package:final_app/models/profile-model.dart';
// import 'package:http/http.dart' as https;
// import 'package:http_parser/http_parser.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:pretty_http_logger/pretty_http_logger.dart';

// class ProfileService {
//   static HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
//     HttpLogger(logLevel: LogLevel.BODY),
//   ]);

//   static const String _baseUrl = 'https://graduation.arabic4u.org';
//   static const storage = FlutterSecureStorage();

//   static Future<String?> _getAccessToken() async {
//     return await storage.read(key: 'access_token');
//   }

//   static Future<ProfileModel?> getProfile() async {
//     final token = await _getAccessToken();
//     if (token == null) return null;

//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/auth/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final profile = ProfileModel.fromJson(jsonData['data']);
        
//         // Store user id
//         await storage.write(key: 'user_id', value: profile.id.toString());
        
//         return profile;
//       } else {
//         print('Get profile failed: ${response.statusCode} - ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Get profile error: $e');
//       return null;
//     }
//   }

//   static Future<bool> updateProfile({
//     String? name = '',
//     String? email = '',
//     File? avatar,
//     bool removeAvatar = false,
//   }) async {
//     final token = await _getAccessToken();
//     if (token == null) return false;

//     try {
//       // ✅ SOLUTION 1: Try using DELETE method for removing avatar
//       if (removeAvatar && avatar == null) {
//         return await _removeAvatar(token);
//       }

//       // ✅ SOLUTION 2: Use multipart form for updating profile
//       final request = https.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/auth/profile')
//       );

//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Accept'] = 'application/json';

//       // Add form fields
//       if (name != null && name.isNotEmpty) {
//         request.fields['name'] = name;
//       }
//       if (email != null && email.isNotEmpty) {
//         request.fields['email'] = email;
//       }

//       // Handle avatar
//       if (avatar != null) {
//         // Add new avatar file
//         request.files.add(await https.MultipartFile.fromPath(
//           'avatar',
//           avatar.path,
//           contentType: MediaType('image', 'jpeg'),
//         ));
//       }

//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         print('Profile updated successfully');
//         return true;
//       } else {
//         print('Update profile failed: ${response.statusCode} - $responseBody');
//         return false;
//       }
//     } catch (e) {
//       print('Update profile error: $e');
//       return false;
//     }
//   }

//   // ✅ SOLUTION 3: Separate method to remove avatar
//   static Future<bool> _removeAvatar(String token) async {
//     try {
//       // Method 1: Try DELETE request to specific endpoint
//       var response = await http.delete(
//         Uri.parse('$_baseUrl/auth/profile/avatar'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         print('Avatar removed successfully via DELETE');
//         return true;
//       }

//       // Method 2: Try POST with remove_avatar flag
//       response = await http.post(
//         Uri.parse('$_baseUrl/auth/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'remove_avatar': true,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Avatar removed successfully via POST with flag');
//         return true;
//       }

//       // Method 3: Try sending empty string for avatar
//       final request = https.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/auth/profile')
//       );

//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Accept'] = 'application/json';
//       request.fields['avatar'] = ''; // Empty string
//       request.fields['remove_avatar'] = '1'; // Flag to remove

//       final multipartResponse = await request.send();
//       final responseBody = await multipartResponse.stream.bytesToString();

//       if (multipartResponse.statusCode == 200) {
//         print('Avatar removed successfully via multipart');
//         return true;
//       }

//       print('Failed to remove avatar: $responseBody');
//       return false;
//     } catch (e) {
//       print('Remove avatar error: $e');
//       return false;
//     }
//   }

//   // ✅ ADD: Method to clear cached profile data
//   static Future<void> clearCachedProfile() async {
//     await storage.delete(key: 'user_id');
//     // Add any other profile-related cached data here
//   }
// }
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