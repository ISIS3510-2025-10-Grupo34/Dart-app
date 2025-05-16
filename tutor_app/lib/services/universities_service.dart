import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import 'local_database_service.dart';

class UniversitiesService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<List<String>> fetchUniversities() async {
    List<String> localUniversities = await _dbService.getUniversities();
    if (localUniversities.isNotEmpty) {
      return localUniversities;
    }
    final apiUrl = '${EnvConfig.apiUrl}/api/universities/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> uniList = data['universities'] as List<dynamic>? ?? [];
        List<String> fetchedUniversities = List<String>.from(uniList);
        if (fetchedUniversities.isNotEmpty) {
          await _dbService.bulkInsertUniversities(fetchedUniversities);
        }
        return List<String>.from(uniList);
      } else {
        throw Exception(
            'Failed to load universities (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching universities: ${e.toString()}');
    }
  }
}
