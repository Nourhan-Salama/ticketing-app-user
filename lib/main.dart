import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/ticketing-app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  
  // Verify secure storage works
  try {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'test_key', value: 'test_value');
    await storage.read(key: 'test_key');
    await storage.delete(key: 'test_key');
    print('✅ Secure storage test successful');
  } catch (e) {
    print('❌ Secure storage failed: $e');
    // Fallback to alternative storage if needed
  }

  runApp(TicketingApp()); 
}

