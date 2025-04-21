import 'dart:convert';
import 'package:final_app/models/ticket-details-model.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:final_app/models/service-model.dart';

class TicketService {
  final String baseUrl = 'https://graduation.arabic4u.org/api/users/tickets';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>> createTicket({
  
    required String description,
    required String title,
    required String serviceId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    final response = await http.post(
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

    final json = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': json['data'],
        'message': json['message'],
      };
    } else if (response.statusCode == 422) {
      return {
        'success': false,
        'message': json['message'] ?? 'Validation error',
      };
    } else {
      return {
        'success': false,
        'message': json['message'] ?? 'Something went wrong',
      };
    }
  }

  Future<List<ServiceModel>> fetchServices() async {
    final token = await _getToken();
    final url = Uri.parse('https://graduation.arabic4u.org/api/select_menu/services');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<ServiceModel> services = (data['data'] as List)
          .map((service) => ServiceModel.fromJson(service))
          .toList();
      return services;
    } else {
      throw Exception('Failed to fetch services: ${response.statusCode}');
    }
  }

  // Add this method to your TicketService class
  Future<Map<String, dynamic>> getPaginatedTickets(int page) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl?page=$page');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        'tickets': (json['data'] as List).map((t) => TicketModel.fromJson(t)).toList(),
        'current_page': json['meta']['current_page'],
        'last_page': json['meta']['last_page'],
        'total': json['meta']['total'],
      };
    } else {
      throw Exception('Failed to load tickets: ${response.statusCode}');
    }
  }

 Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
  final token = await _getToken();
  final url = Uri.parse('$baseUrl/$ticketId');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return TicketDetailsModel.fromJson(json['data']);
  } else {
    throw Exception('Failed to load ticket details: ${response.statusCode}');
  }
}
}