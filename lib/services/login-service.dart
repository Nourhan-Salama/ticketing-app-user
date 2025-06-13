import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

class AuthApi {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  AuthApi({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : client = client ?? http.Client(),
        secureStorage = storage ?? const FlutterSecureStorage();

  HttpWithMiddleware httpLogger = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await httpLogger.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data'] == null) {
          throw Exception("No data in response");
        }

        final data = responseData['data'];
        
        // ✅ Clear any existing data before saving new user data
        await _clearUserData();
        
        // ✅ Save new user data
        await _saveTokens(data['token'], data['refresh_token']);
        await _saveUserInfo(data['user']['name'], data['user']['email']);
        
        // ✅ Save user ID if available
        if (data['user']['id'] != null) {
          await secureStorage.write(key: 'user_id', value: data['user']['id'].toString());
        }

        return {
          'code': 200,
          'message': responseData['message'],
          'data': data,
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {
        'code': 500,
        'message': 'networkError'.tr(),
        'error': e.toString(),
      };
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final url = Uri.parse('$baseUrl/auth/refresh_tokens/refresh');
      final response = await httpLogger.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await secureStorage.write(
          key: 'access_token',
          value: responseData['data']['token'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'access_token', value: accessToken);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _saveUserInfo(String name, String email) async {
    await secureStorage.write(key: 'user_name', value: name);
    await secureStorage.write(key: 'user_email', value: email);
  }

  // ✅ Clear user-specific data (but keep app settings)
  Future<void> _clearUserData() async {
    List<String> userDataKeys = [
      'access_token',
      'refresh_token',
      'user_name',
      'user_email',
      'user_id',
    ];

    for (String key in userDataKeys) {
      await secureStorage.delete(key: key);
    }
  }

  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      return {
        'code': response.statusCode,
        'message': responseData['message'] ?? 'loginFailed'.tr(),
      };
    } catch (e) {
      return {
        'code': response.statusCode,
        'message': 'loginFailed'.tr(),
      };
    }
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  // ✅ Updated logout method with complete cleanup
  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_id');
    
    // ✅ Add any other user-specific keys that should be cleared
    print('AuthApi: User data cleared');
  }
}
// // }
// import 'dart:convert';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:pretty_http_logger/pretty_http_logger.dart';

// class AuthApi {
//   final String baseUrl;
//   final http.Client client;
//   final FlutterSecureStorage secureStorage;

//   AuthApi({
//     this.baseUrl = "https://graduation.arabic4u.org",
//     http.Client? client,
//     FlutterSecureStorage? storage,
//   })  : client = client ?? http.Client(),
//         secureStorage = storage ?? const FlutterSecureStorage();

//   HttpWithMiddleware httpLogger = HttpWithMiddleware.build(middlewares: [
//     HttpLogger(logLevel: LogLevel.BODY),
//   ]);

//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     final url = Uri.parse('$baseUrl/auth/login');

//     try {
//       final response = await httpLogger.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         if (responseData['data'] == null) {
//           throw Exception("No data in response");
//         }

//         final data = responseData['data'];
//         await _saveTokens(data['token'], data['refresh_token']);
//         await _saveUserInfo(data['user']['name'], data['user']['email']);

//         return {
//           'code': 200,
//           'message': responseData['message'],
//           'data': data,
//         };
//       } else {
//         return _handleError(response);
//       }
//     } catch (e) {
//       return {
//         'code': 500,
//         'message': 'networkError'.tr(),
//         'error': e.toString(),
//       };
//     }
//   }

//   Future<bool> refreshToken() async {
//     try {
//       final refreshToken = await secureStorage.read(key: 'refresh_token');
//       if (refreshToken == null) return false;

//       final url = Uri.parse('$baseUrl/auth/refresh_tokens/refresh');
//       final response = await httpLogger.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refresh_token': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         await secureStorage.write(
//           key: 'access_token',
//           value: responseData['data']['token'],
//         );
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> _saveTokens(String accessToken, String refreshToken) async {
//     await secureStorage.write(key: 'access_token', value: accessToken);
//     await secureStorage.write(key: 'refresh_token', value: refreshToken);
//   }

//   Future<void> _saveUserInfo(String name, String email) async {
//     await secureStorage.write(key: 'user_name', value: name);
//     await secureStorage.write(key: 'user_email', value: email);
//   }

//   Map<String, dynamic> _handleError(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return {
//         'code': response.statusCode,
//         'message': responseData['message'] ?? 'loginFailed'.tr(),
//       };
//     } catch (e) {
//       return {
//         'code': response.statusCode,
//         'message': 'loginFailed'.tr(),
//       };
//     }
//   }

//   Future<String?> getAccessToken() async {
//     return await secureStorage.read(key: 'access_token');
//   }

//   Future<void> logout() async {
//     await secureStorage.delete(key: 'access_token');
//     await secureStorage.delete(key: 'refresh_token');
//     await secureStorage.delete(key: 'user_name');
//     await secureStorage.delete(key: 'user_email');
//   }
// }
