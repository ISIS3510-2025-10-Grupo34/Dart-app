import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class AreaOfExpertiseService {
  Future<List<String>> fetchAreaOfExpertise() async {
    final apiUrl = '${EnvConfig.apiUrl}/api/get-area-of-expertise/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> uniList = data['data'] as List<dynamic>? ?? [];
        return List<String>.from(uniList);
      } else {
        throw Exception(
            'Failed to load area of expertise (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching area of expertise : ${e.toString()}');
    }
  }
}
