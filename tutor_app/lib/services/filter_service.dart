import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class FilterService {
  Future<Map<String, dynamic>> fetchFilterData() async {
    final response = await http.get(
      Uri.parse('${EnvConfig.apiUrl}/api/search-results-filter/'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body)['data'];
      return data;
    } else {
      throw Exception('Failed to load filter options');
    }
  }

  Future<void> increaseFilterCount(String filter) async {
    final response = await http.post(
      Uri.parse('${EnvConfig.apiUrl}/api/increase-filter-count/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"filter": filter}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register filter count');
    }
  }
}
