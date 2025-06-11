import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MessageService {
  static const String _baseUrl = "https://graduation.arabic4u.org";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Fetch messages for a conversation
  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      print("[GET] Fetching messages for conversation: $conversationId");
      print("Page: $page, Per Page: $perPage");

      // Get auth token
      final String? token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception("Authentication token not found");

      // Make API request
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/api/conversations/$conversationId/messages?page=$page&per_page=$perPage",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          "Failed to fetch messages: ${response.statusCode} - ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      print("Error in getMessages: $e");
      rethrow;
    }
  }

    // Upload media and get path
  Future<String> uploadMedia(File file) async {
    try {
      final String? token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception("Authentication token not found");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/api/upload-media"),
      )..headers.addAll({
          'Authorization': 'Bearer $token',
        })..files.add(await http.MultipartFile.fromPath('media', file.path));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['media_path'];
      } else {
        throw Exception("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading media: $e");
      rethrow;
    }
  }


  // Updated sendMessage to handle media upload
  Future<Map<String, dynamic>> sendMessage(
    String conversationId, {
    required int type,
    String? content,
    String? mediaPath,
    String? parentMessageId,
  }) async {
    try {
      // Upload media first if exists
      String? finalMediaPath;
     if (type != 0 && mediaPath != null) {
  finalMediaPath = await uploadMedia(File(mediaPath));
}


      final String? token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception("Authentication token not found");

      final Map<String, dynamic> body = {
        'type': type,
        if (content != null) 'content': content,
        if (finalMediaPath != null) 'media': finalMediaPath,
        if (parentMessageId != null) 'parent_message_id': parentMessageId,
      };

      final response = await http.post(
        Uri.parse("$_baseUrl/api/conversations/$conversationId/messages"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception("Send failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in sendMessage: $e");
      rethrow;
    }
  }
}