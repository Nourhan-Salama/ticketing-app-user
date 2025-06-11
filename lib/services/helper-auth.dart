import 'dart:developer';
import 'package:final_app/services/pusher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Handle user login and initialize Pusher
  static Future<void> handleLogin({
    required String userId,
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      // Save authentication data
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      // Initialize Pusher for the logged-in user
      await PusherService.initPusher(userId: userId);
      
      log('✅ User login successful - Pusher initialized for user: $userId');
    } catch (e) {
      log('❌ Error during login process: $e');
      rethrow;
    }
  }

  /// Handle user logout and disconnect Pusher
  static Future<void> handleLogout() async {
    try {
      // Disconnect Pusher first
      await PusherService.disconnect();
      
      // Clear all stored authentication data
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      
      log('✅ User logout successful - Pusher disconnected');
    } catch (e) {
      log('❌ Error during logout process: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: 'access_token');
    final userId = await _storage.read(key: 'user_id');
    return accessToken != null && userId != null;
  }

  /// Get current user ID
  static Future<String?> getCurrentUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// Get current access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Reinitialize Pusher (useful for app resume or reconnection)
  static Future<void> reconnectPusher() async {
    final userId = await getCurrentUserId();
    if (userId != null && !PusherService.isConnected) {
      try {
        await PusherService.initPusher(userId: userId);
        log('✅ Pusher reconnected for user: $userId');
      } catch (e) {
        log('❌ Failed to reconnect Pusher: $e');
      }
    }
  }

  /// Force refresh Pusher connection
  static Future<void> refreshPusherConnection() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      try {
        // Disconnect first
        await PusherService.disconnect();
        
        // Reconnect
        await PusherService.initPusher(userId: userId);
        
        log('✅ Pusher connection refreshed for user: $userId');
      } catch (e) {
        log('❌ Failed to refresh Pusher connection: $e');
      }
    }
  }
}