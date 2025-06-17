import 'dart:convert';
import 'package:final_app/models/section-model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://graduation.arabic4u.org';

  Future<List<SectionModel>> fetchSections(int serviceId) async {
    final url = Uri.parse('$baseUrl/api/select_menu/sections')
        .replace(queryParameters: {'service_id': serviceId.toString()});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      
      if (jsonResponse['type'] == 'success') {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => SectionModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'API Error: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load sections. Status code: ${response.statusCode}');
    }
  }
}