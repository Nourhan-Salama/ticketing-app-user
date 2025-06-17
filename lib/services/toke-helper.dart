// import 'package:final_app/services/login-service.dart';

// class AuthHelper {
//   final AuthApi authApi;

//   AuthHelper(this.authApi);

//   Future<bool> checkAndRefreshToken() async {
//     try {
//       // In a real app, you would check token expiration here
//       // For simplicity, we'll just try to refresh
//       return await authApi.refreshToken();
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<String?> getValidToken() async {
//     try {
//       final currentToken = await authApi.getAccessToken();
//       if (currentToken == null) return null;
      
//       // Try to refresh if needed
//       final refreshed = await checkAndRefreshToken();
//       if (refreshed) {
//         return await authApi.getAccessToken();
//       }
//       return currentToken;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<bool> isAuthenticated() async {
//     final token = await getValidToken();
//     return token != null;
//   }
// }