import 'dart:convert';
import 'package:http/http.dart' as http;

class RestPassApi {
  final String baseUrl;
  final http.Client client;

  RestPassApi({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> resetPassword({required String handle}) async {
    final url = Uri.parse('$baseUrl/auth/password/reset_password');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'handle': handle}),
      );

      final responseData = jsonDecode(response.body);
      return _handleResponse(response.statusCode, responseData);
    } catch (e) {
      return {'type': 'error', 'message': 'An unexpected error occurred'};
    }
  }

  Map<String, dynamic> _handleResponse(int code, Map<String, dynamic> responseData) {
    if (code == 200) {
      return {
        'type': 'success',
        'message': responseData['message'],
        'showToast': responseData['showToast'] ?? false,
      };
    } else if (code == 422) {
      if (responseData['data']?['handle'] != null) {
        return {'type': 'error', 'message': responseData['data']['handle']};
      }
      if (responseData['data']?['password'] != null) {
        return {'type': 'error', 'message': responseData['data']['password']};
      }
      if (responseData['data']?['code'] != null) {
        return {'type': 'error', 'message': responseData['data']['code']};
      }
    }
    return {'type': 'error', 'message': responseData['message'] ?? 'Unknown error occurred'};
  }
}
