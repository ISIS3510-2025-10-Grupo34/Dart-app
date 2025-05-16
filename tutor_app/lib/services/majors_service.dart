import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import 'local_database_service.dart';

class MajorsService {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  Future<List<String>> fetchMajors(String university) async {
    List<String> localMajors =
        await _dbService.getMajorsByUniversityName(university);
    if (localMajors.isNotEmpty) {
      return localMajors;
    }
    final apiUrl =
        '${EnvConfig.apiUrl}/api/majors-by-university/?university=$university';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> majorsListDynamic =
            data['majors'] as List<dynamic>? ?? [];
        List<String> fetchedMajors = List<String>.from(majorsListDynamic);
        int? uniId = await _dbService.getUniversityIdByName(university);
        if (uniId == null) {
          await _dbService.insertUniversity(university);
          uniId = await _dbService.getUniversityIdByName(university);
        }

        if (uniId != null && fetchedMajors.isNotEmpty) {
          await _dbService.bulkInsertMajorsForUniversity(
              university, fetchedMajors);
        }
        return fetchedMajors;
      } else {
        throw Exception(
            'Failed to load majors (Status code: ${response.statusCode})');
      }
    } catch (e) {
      final String error = e.toString();
      if (error == "Connection failed") {
        throw "Please check your connection";
      } else {
        throw e.toString();
      }
    }
  }
}
