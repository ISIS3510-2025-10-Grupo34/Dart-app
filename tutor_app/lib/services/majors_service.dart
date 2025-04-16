import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class MajorsService {
  Future<List<String>> fetchMajors() async {
    final apiUrl = '${EnvConfig.apiUrl}/api/majors/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> uniList = data['majors'] as List<dynamic>? ?? [];
        return List<String>.from(uniList);
      } else {
        throw Exception(
            'Failed to load majors (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching majors: ${e.toString()}');
    }
  }
}
