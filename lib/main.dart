

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/ticketing-app.dart';
import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  try {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'test_key', value: 'test_value');
    await storage.read(key: 'test_key');
    await storage.delete(key: 'test_key');
    log('✅ Secure storage test successful');
  } catch (e) {
    log('❌ Secure storage failed: $e');
  }

  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');
  final savedLocale = await storage.read(key: 'locale');

  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('en'), const Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale != null ? Locale(savedLocale) : const Locale('en'),
      child: TicketingApp(
        accessToken: accessToken,
      ),
    ),
  );
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//    await Firebase.initializeApp();

//   // Verify secure storage works
//   try {
//     const storage = FlutterSecureStorage();
//     await storage.write(key: 'test_key', value: 'test_value');
//     await storage.read(key: 'test_key');
//     await storage.delete(key: 'test_key');
//     // add log developer package
//     log('✅ Secure storage test successful');
//   } catch (e) {
//     log('❌ Secure storage failed: $e');
//     // Fallback to alternative storage if needed
//   }
//   final storage =  FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'access_token');
//   runApp(
//     EasyLocalization(
//         supportedLocales: [Locale('en'), Locale('ar')],
//         path:
//             'assets/translations', // <-- change the path of the translation files
//         fallbackLocale: Locale('en'),
//         child: TicketingApp(
//           accessToken: accessToken,
//         )),
//   );
// }
