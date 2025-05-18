import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class TopPostingTimesService {
  Future<List<Map<String, dynamic>>> fetchTopPostingTimes() async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/top-posting-times/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch top posting times');
    }
  }
}
