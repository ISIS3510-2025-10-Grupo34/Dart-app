import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

class StudentTutoringSessionsService {
  Future<List<TutoringSession>> fetchStudentSessions(String studentId) async {
    try {
      final baseUrl = '${EnvConfig.apiUrl}/api/tutoring-sessions-to-review/';

      final queryParameters = {
        'studentId': studentId.toString(),
      };
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> dataList = data["data"];
        return dataList
            .map((json) => TutoringSession.fromJsonSTS(json))
            .toList();
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
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
