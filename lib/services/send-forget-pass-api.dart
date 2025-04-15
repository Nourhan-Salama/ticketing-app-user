import 'dart:convert';
import 'package:http/http.dart' as http;

class SendForgetPassApi {
  final String baseUrl;
  final http.Client client;

  SendForgetPassApi({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> sendForgetPass({required String handle}) async {
    final url = Uri.parse('$baseUrl/auth/password/forgot_password');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'handle': handle}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["type"] == "success") {
        return {
          "success": true,
          "message": responseData["message"],
          "showToast": responseData["showToast"] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}",
      };
    }
  }
}
