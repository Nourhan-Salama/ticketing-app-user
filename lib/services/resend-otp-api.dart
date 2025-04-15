import 'dart:convert';
import 'package:http/http.dart' as http;

class ResendOtpApi {
  final String baseUrl = "https://graduation.arabic4u.org";

  Future<Map<String, dynamic>> resendOtp({required String handle, required otpType}) async {
    final url = Uri.parse('$baseUrl/auth/verify_user/resend');
    print("[Resend OTP] Request URL: $url");
    print("[Resend OTP] Request Body: ${jsonEncode({"handle": handle})}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"handle": handle}),
      );
      
      print("[Resend OTP] Response Code: ${response.statusCode}");
      print("[Resend OTP] Response Body: ${response.body}");
      
      final responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            "success": true,
            "message": responseData["message"] ?? "OTP resent successfully.",
          };
        case 404:
          return {
            "success": false,
            "message": "User not found. Please check your email.",
          };
        case 422:
          return {
            "success": false,
            "message": responseData["message"] ?? "Validation error.",
            "errors": responseData["data"] ?? {},
          };
        default:
          return {
            "success": false,
            "message": responseData["message"] ?? "Something went wrong.",
          };
      }
    } catch (error) {
      print("[Resend OTP] Request Error: $error");
      return {
        "success": false,
        "message": "Failed to resend OTP: $error",
      };
    }
  }
}


