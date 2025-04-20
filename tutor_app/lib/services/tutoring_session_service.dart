import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

class TutoringSessionService {
  Future<List<TutoringSession>> fetchTutoringSessions() async {
    final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-with-names/'));

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

  Future<void> createTutoringSession({
    required int cost,
    required String dateTime,
    required int courseId,
    required int tutorId,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cost': cost,
        'dateTime': dateTime,
        'courseId': courseId,
        'tutorId': tutorId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creating tutoring session: ${response.body}");
    }
  }

}
