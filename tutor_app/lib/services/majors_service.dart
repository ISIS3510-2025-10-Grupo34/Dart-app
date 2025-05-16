import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class MajorsService {
  Future<List<String>> fetchMajors(String university) async {
    final apiUrl =
        '${EnvConfig.apiUrl}/api/majors-by-university/?university=$university';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
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
      final String error = e.toString();
      if (error == "Connection failed") {
        throw "Please check your connection";
      } else {
        throw ("Please check your conection.");
      }
    }
  }
}
