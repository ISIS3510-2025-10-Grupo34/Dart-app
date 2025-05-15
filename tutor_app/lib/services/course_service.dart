import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../utils/env_config.dart';
import 'local_database_service.dart';

class CourseService {
  final String baseUrl = '${EnvConfig.apiUrl}/api/info/courses/';
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<List<Course>> fetchCourses() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> courseList = decoded["courses"];

        // Preparar lista de mapas para insertar en la base local
        List<Map<String, dynamic>> coursesToInsert = courseList.map((courseJson) {
          return {
            'course_name': courseJson['course_name'],
            'university_id': courseJson['university_id']
          };
        }).toList();

        // Guardar en local en batch
        await _dbService.bulkInsertCourses(coursesToInsert);

        // Retornar lista de objetos Course
        return courseList.map((courseJson) => Course.fromJson(courseJson)).toList();
      } else {
        throw Exception('Error fetching courses (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<List<Course>> fetchCoursesByUniversity(String universityName) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/courses-by-university/?university=$universityName');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> courseList = decoded["courses"];

        return courseList.map((courseJson) => Course.fromJson(courseJson)).toList();
      } else {
        throw Exception('Error fetching courses (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

}
