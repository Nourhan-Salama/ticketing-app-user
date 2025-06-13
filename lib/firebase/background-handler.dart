// background_handler.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler for when the app is terminated
/// This must be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 Handling background message: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');
  debugPrint('📱 Message notification: ${message.notification?.title}');
  
  // You can add additional background processing here if needed
  // For example, updating local database, sending analytics events, etc.
  
  // Note: Don't try to update UI or navigate from here as the app is not running
  // Navigation will be handled when the app starts and processes the initial message
}