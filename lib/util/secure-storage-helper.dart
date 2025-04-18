import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveProfileImagePath(String path) async {
    await _storage.write(key: 'profile_image', value: path);
  }

  static Future<String?> getProfileImagePath() async {
    return await _storage.read(key: 'profile_image');
  }

  static Future<void> deleteProfileImage() async {
    await _storage.delete(key: 'profile_image');
  }
}
