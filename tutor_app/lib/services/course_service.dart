import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../utils/env_config.dart';
import 'local_database_service.dart';

class CourseService {
  final String baseUrl = '${EnvConfig.apiUrl}/api/info/courses/';
  final LocalDatabaseService _dbService = LocalDatabaseService();

    Future<List<String>> fetchCourses(String university) async {
    List<String> localCourses =
        await _dbService.getCoursesByUniversityName(university);
    if (localCourses.isNotEmpty) {
      return localCourses;
    }

    final apiUrl =
        '${EnvConfig.apiUrl}/api/courses-by-university/?university=$university';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> courseList = data['courses'] as List<dynamic>? ?? [];
        List<String> fetchedCourses = List<String>.from(courseList);

        int? uniId = await _dbService.getUniversityIdByName(university);
        if (uniId == null) {
          await _dbService.insertUniversity(university);
          uniId = await _dbService.getUniversityIdByName(university);
        }

        if (uniId != null && fetchedCourses.isNotEmpty) {
          await _dbService.bulkInsertCoursesForUniversity(
              university, fetchedCourses);
        }

        return fetchedCourses;
      } else {
        throw Exception(
            'Failed to load courses (Status code: ${response.statusCode})');
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

  Future<String> fetchMostSubscribedCourseName() async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/most-subscribed-course/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final mostSubscribedCourse = decoded["most_subscribed_course"];
        return mostSubscribedCourse["course_name"] as String;
      } else {
        throw Exception('Error fetching most subscribed course name (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching most subscribed course name: $e');
    }
  }

}
