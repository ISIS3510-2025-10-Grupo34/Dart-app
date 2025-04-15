import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

class StudentTutoringSessionsService {
  Future<List<TutoringSession>> fetchStudentSessions(String studentId) async {
    final response = await http.post(
      Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-to-review/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"studentId": studentId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TutoringSession.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load student tutoring sessions (Status code: ${response.statusCode})');
    }
  }

  Future<List<TutoringSession>> fetchTutoringSessions() async {
    final response = await http.get(
        Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-with-names/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TutoringSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tutoring sessions');
    }
  }

  Future<List<TutoringSession>> fetchAvailableTutoringSessions() async {
    final allSessions = await fetchTutoringSessions();
    return allSessions.where((session) => session.student == null).toList();
  }
}
