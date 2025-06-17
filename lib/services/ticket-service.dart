import 'dart:convert';
import 'dart:async';
import 'package:final_app/models/ticket-details-model.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:final_app/models/service-model.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:http/http.dart' as http;

class TicketService {
  final String baseUrl = 'https://graduation.arabic4u.org/api/users/tickets';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String _refreshUrl = 'https://graduation.arabic4u.org/api/refresh';

  HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Access token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      print('❌ No refresh token found');
      return false;
    }

    final response = await http.post(
      Uri.parse(_refreshUrl),
      headers: {'Accept': 'application/json'},
      body: {'refresh_token': refreshToken},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      if (newAccessToken != null && newRefreshToken != null) {
        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> createTicket({
    required String description,
    required String title,
    required String serviceId,
      required String sectionId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'description': description,
        'title': title,
        'service_id': serviceId,
        'section_id': sectionId,
      },
    );

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await createTicket(description: description, title: title, serviceId: serviceId, sectionId: sectionId);
    }

    final json = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': json['data'],
        'message': json['message'],
      };
    } else {
      return {
        'success': false,
        'message': json['message'] ?? 'Something went wrong',
      };
    }
  }

  Future<List<TicketModel>> getAllTickets() async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse(baseUrl);

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await getAllTickets();
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> ticketsJson = json['data'] ?? [];
      
      return ticketsJson
          .map((ticketJson) => TicketModel.fromJson(ticketJson as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load all tickets: ${response.statusCode}');
    }
  }

  Future<TicketModel> getTicketById(int ticketId) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('https://graduation.arabic4u.org/api/users/tickets/$ticketId');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await getTicketById(ticketId);
    }

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return TicketModel.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load ticket: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateTicket({
    required int ticketId,
    required String description,
    required String title,
    required String serviceId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$ticketId');

    var response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'description': description,
        'title': title,
        'service_id': serviceId,
      },
    );

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await updateTicket(ticketId: ticketId, description: description, title: title, serviceId: serviceId);
    }

    final json = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': json['data'],
        'message': json['message'],
      };
    } else {
      return {
        'success': false,
        'message': json['message'] ?? 'Something went wrong',
      };
    }
  }

  Future<List<ServiceModel>> fetchServices() async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('https://graduation.arabic4u.org/api/select_menu/services');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await fetchServices();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((s) => ServiceModel.fromJson(s))
          .toList();
    } else {
      throw Exception('Failed to fetch services: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPaginatedTickets(int page) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$baseUrl?page=$page');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await getPaginatedTickets(page);
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      final List<dynamic> ticketsJson = json['data'] ?? [];
      final List<TicketModel> tickets = ticketsJson
          .map((ticketJson) => TicketModel.fromJson(ticketJson as Map<String, dynamic>))
          .toList();
      
      return {
        'tickets': tickets,
        'current_page': json['meta']?['current_page'] ?? 1,
        'last_page': json['meta']?['last_page'] ?? 1,
        'total': json['meta']?['total'] ?? 0,
      };
    } else {
      throw Exception('Failed to load tickets: ${response.statusCode}');
    }
  }

  Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$baseUrl/$ticketId');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && await refreshAccessToken()) {
      return await getTicketDetails(ticketId);
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TicketDetailsModel.fromJson(json['data']);
    } else {
      throw Exception('Failed to load ticket details: ${response.statusCode}');
    }
  }
}