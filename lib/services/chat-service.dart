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

      final String? token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception("Authentication token not found");

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

  // Send message with or without media
  Future<Map<String, dynamic>> sendMessage(
    String conversationId, {
    required int type,
    String? content,
    String? mediaPath,
    String? parentMessageId,
  }) async {
    try {
      print("[POST] Sending message - Type: $type, Content: $content, MediaPath: $mediaPath");
      
      final String? token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception("Authentication token not found");

      final uri = Uri.parse("$_baseUrl/api/conversations/$conversationId/messages");

      if (mediaPath != null && mediaPath.isNotEmpty) {
        print("Sending multipart request with media");
        
        // Send multipart with media
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['type'] = type.toString();

        if (content != null) {
          request.fields['content'] = content;
        }
        if (parentMessageId != null) {
          request.fields['parent_message_id'] = parentMessageId;
        }

        print("Request fields: ${request.fields}");
        
        // Add file
        final file = await http.MultipartFile.fromPath('media', mediaPath);
        request.files.add(file);
        
        print("Added file: ${file.filename}, Size: ${file.length}");

        final streamedResponse = await request.send();
        final responseBody = await streamedResponse.stream.bytesToString();

        print("Multipart Response Status: ${streamedResponse.statusCode}");
        print("Multipart Response Body: $responseBody");

        if (streamedResponse.statusCode == 201) {
          final responseData = json.decode(responseBody);
          print("Parsed response data: $responseData");
          return responseData;
        } else {
          throw Exception("Send failed: ${streamedResponse.statusCode} - $responseBody");
        }
      } else {
        print("Sending JSON request without media");
        
        // Send JSON without media
        final Map<String, dynamic> body = {
          'type': type,
          if (content != null) 'content': content,
          if (parentMessageId != null) 'parent_message_id': parentMessageId,
        };

        print("Request body: $body");

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(body),
        );

        print("JSON Response Status: ${response.statusCode}");
        print("JSON Response Body: ${response.body}");

        if (response.statusCode == 201) {
          final responseData = json.decode(response.body);
          print("Parsed response data: $responseData");
          return responseData;
        } else {
          throw Exception("Send failed: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      print("Error in sendMessage: $e");
      rethrow;
    }
  }
}
