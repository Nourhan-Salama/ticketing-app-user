
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/services/pusher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/ticketing-app.dart';
import 'package:firebase_core/firebase_core.dart';

// Global Pusher flag
bool _pusherInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  const storage = FlutterSecureStorage();

  // Test secure storage
  try {
    await storage.write(key: 'test_key', value: 'test_value');
    await storage.read(key: 'test_key');
    await storage.delete(key: 'test_key');
    log('✅ Secure storage test successful');
  } catch (e) {
    log('❌ Secure storage failed: $e');
  }

  final userIdStr = await storage.read(key: 'user_id');
  final accessToken = await storage.read(key: 'access_token');
  final savedLocale = await storage.read(key: 'locale');

  // Initialize Pusher if user is logged in
  if (userIdStr != null && userIdStr.isNotEmpty) {
    await PusherManager.initializeForUser(userIdStr);
  }

  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('en'), const Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale != null ? Locale(savedLocale) : const Locale('en'),
      child: MyApp(
        accessToken: accessToken,
        userId: userIdStr,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? accessToken;
  final String? userId;

  const MyApp({
    Key? key,
    required this.accessToken,
    required this.userId,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectPusher();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        log('📱 App resumed');
        _reconnectPusherIfNeeded();
        break;
      case AppLifecycleState.paused:
        log('📱 App paused');
        break;
      case AppLifecycleState.detached:
        log('📱 App detached - Disconnecting Pusher');
        _disconnectPusher();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _reconnectPusherIfNeeded() async {
    if (widget.userId != null && !PusherService.isConnected) {
      log('🔄 Attempting to reconnect Pusher...');
      await PusherManager.initializeForUser(widget.userId!);
    }
  }

  Future<void> _disconnectPusher() async {
    if (_pusherInitialized) {
      try {
        await PusherService.disconnect();
        _pusherInitialized = false;
        log('✅ Pusher disconnected successfully');
      } catch (e) {
        log('❌ Error disconnecting Pusher: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketingApp(
      accessToken: widget.accessToken,
    );
  }
}

class PusherManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> initializeForUser(String userId) async {
    try {
      await _storage.write(key: 'user_id', value: userId);
      await PusherService.initPusher(userId: userId);
      _pusherInitialized = true;
      log('✅ Pusher initialized for user: $userId');
    } catch (e) {
      log('❌ Failed to initialize Pusher for user: $e');
    }
  }

  static Future<void> disconnectForLogout() async {
    try {
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'access_token');
      await PusherService.disconnect();
      _pusherInitialized = false;
      log('✅ Pusher disconnected for logout');
    } catch (e) {
      log('❌ Error during logout disconnect: $e');
    }
  }

  static bool get isInitialized => _pusherInitialized && PusherService.isConnected;

  static Future<String?> getCurrentUserId() async {
    return await _storage.read(key: 'user_id');
  }
}

// import 'dart:developer';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/services/pusher.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'screens/ticketing-app.dart';
// import 'package:firebase_core/firebase_core.dart';

// // Global variable to track Pusher initialization status
// bool _pusherInitialized = false;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   await EasyLocalization.ensureInitialized();
//   await Firebase.initializeApp();
  
//   const storage = FlutterSecureStorage();
  
//   // Test secure storage
//   try {
//     await storage.write(key: 'test_key', value: 'test_value');
//     await storage.read(key: 'test_key');
//     await storage.delete(key: 'test_key');
//     log('✅ Secure storage test successful');
//   } catch (e) {
//     log('❌ Secure storage failed: $e');
//   }
  
//   // Get user data from storage
//   final userIdStr = await storage.read(key: 'user_id');
//   final accessToken = await storage.read(key: 'access_token');
//   final savedLocale = await storage.read(key: 'locale');
  
//   // Initialize Pusher if user is logged in
//   await _initializePusherIfNeeded(userIdStr);
  
//   runApp(
//     EasyLocalization(
//       supportedLocales: [const Locale('en'), const Locale('ar')],
//       path: 'assets/translations',
//       fallbackLocale: const Locale('en'),
//       startLocale: savedLocale != null ? Locale(savedLocale) : const Locale('en'),
//       child: MyApp(
//         accessToken: accessToken,
//         userId: userIdStr,
//       ),
//     ),
//   );
// }

// /// Initialize Pusher if user is logged in
// Future<void> _initializePusherIfNeeded(String? userIdStr) async {
//   if (userIdStr == null || userIdStr.isEmpty) {
//     log('⚠️ No user_id found in secure storage. Pusher not initialized.');
//     return;
//   }
  
//   try {
//     await PusherService.initPusher(userId: userIdStr);
//     _pusherInitialized = true;
//     log('✅ Pusher initialized successfully for user: $userIdStr');
//   } catch (e) {
//     log('❌ Failed to initialize Pusher: $e');
//     _pusherInitialized = false;
//   }
// }

// /// Handle Pusher disconnection when app is terminated
// Future<void> _disconnectPusher() async {
//   if (_pusherInitialized) {
//     try {
//       await PusherService.disconnect();
//       _pusherInitialized = false;
//       log('✅ Pusher disconnected successfully');
//     } catch (e) {
//       log('❌ Error disconnecting Pusher: $e');
//     }
//   }
// }

// class MyApp extends StatefulWidget {
//   final String? accessToken;
//   final String? userId;
  
//   const MyApp({
//     Key? key,
//     required this.accessToken,
//     required this.userId,
//   }) : super(key: key);
  
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     // Add observer to handle app lifecycle changes
//     WidgetsBinding.instance.addObserver(this);
//   }
  
//   @override
//   void dispose() {
//     // Remove observer and disconnect Pusher
//     WidgetsBinding.instance.removeObserver(this);
//     _disconnectPusher();
//     super.dispose();
//   }
  
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     switch (state) {
//       case AppLifecycleState.paused:
//         log('📱 App paused - Pusher still connected');
//         break;
//       case AppLifecycleState.resumed:
//         log('📱 App resumed');
//         // Reconnect Pusher if needed when app resumes
//         _reconnectPusherIfNeeded();
//         break;
//       case AppLifecycleState.detached:
//         log('📱 App detached - Disconnecting Pusher');
//         _disconnectPusher();
//         break;
//       case AppLifecycleState.inactive:
//         log('📱 App inactive');
//         break;
//       case AppLifecycleState.hidden:
//         log('📱 App hidden');
//         break;
//     }
//   }
  
//   /// Reconnect Pusher if it was previously initialized but now disconnected
//   Future<void> _reconnectPusherIfNeeded() async {
//     if (widget.userId != null && !PusherService.isConnected) {
//       log('🔄 Attempting to reconnect Pusher...');
//       await _initializePusherIfNeeded(widget.userId);
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return TicketingApp(
//       accessToken: widget.accessToken,
//     );
//   }
// }

// /// Utility class to handle Pusher operations throughout the app
// class PusherManager {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
//   /// Initialize Pusher for a newly logged-in user
//   static Future<void> initializeForUser(String userId) async {
//     try {
//       // Save user ID to storage
//       await _storage.write(key: 'user_id', value: userId);
      
//       // Initialize Pusher
//       await PusherService.initPusher(userId: userId);
//       _pusherInitialized = true;
      
//       log('✅ Pusher initialized for new user: $userId');
//     } catch (e) {
//       log('❌ Failed to initialize Pusher for user: $e');
//     }
//   }
  
//   /// Disconnect Pusher when user logs out
//   static Future<void> disconnectForLogout() async {
//     try {
//       // Clear user data from storage
//       await _storage.delete(key: 'user_id');
//       await _storage.delete(key: 'access_token');
      
//       // Disconnect Pusher
//       await PusherService.disconnect();
//       _pusherInitialized = false;
      
//       log('✅ Pusher disconnected for logout');
//     } catch (e) {
//       log('❌ Error during logout disconnect: $e');
//     }
//   }
  
//   /// Check if Pusher is properly initialized
//   static bool get isInitialized => _pusherInitialized && PusherService.isConnected;
  
//   /// Get current user ID from storage
//   static Future<String?> getCurrentUserId() async {
//     return await _storage.read(key: 'user_id');
//   }
// }