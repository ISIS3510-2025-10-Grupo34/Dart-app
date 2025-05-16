import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class UniversitiesService {
  Future<List<String>> fetchUniversities() async {
    final apiUrl = '${EnvConfig.apiUrl}/api/universities/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> uniList = data['universities'] as List<dynamic>? ?? [];
        return List<String>.from(uniList);
      } else {
        throw Exception(
            'Failed to load universities (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw ('Error fetching universities. Please check your connection.');
    }
  }
}
