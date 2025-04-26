import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

class SessionFetchResult {
  final List<TutoringSession> sessions;
  final bool isFromCache;

  SessionFetchResult({required this.sessions, required this.isFromCache});
}


class TutoringSessionService {

  Future<SessionFetchResult> fetchOrderedSessions(int page) async { 
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'ordered_sessions_page_$page';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(cachedData);
        final parsedSessions = decodedList.map((json) => TutoringSession.fromJson(json)).toList();
        return SessionFetchResult(sessions: parsedSessions, isFromCache: true);
      } catch (e) {
        await prefs.remove(cacheKey);
      }
    }

    final url = Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-ordered/');
    List<TutoringSession> sessions = [];

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'page': page}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('tutoring_sessions')) {
            final List<dynamic> data = decodedBody['tutoring_sessions'];
            sessions = data.map((json) => TutoringSession.fromJson(json)).toList();
            final List<Map<String, dynamic>> rawSessionData = data.cast<Map<String, dynamic>>();
            await prefs.setString(cacheKey, jsonEncode(rawSessionData));
        } else {
           throw Exception('Failed to parse tutoring sessions: Missing key');
        }
      } else {
        throw Exception('Failed to load tutoring sessions (Status code: ${response.statusCode})');
      }
    } catch (e) {
       throw Exception('Failed to load tutoring sessions: $e');
    }

    return SessionFetchResult(sessions: sessions, isFromCache: false);
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

  Future<int> getEstimatedPrice({
    required int tutorId,
    required String courseUniversityName,
  }) async {
    final url = Uri.parse(
      '${EnvConfig.apiUrl}/api/course-estimate-price/?tutorId=$tutorId&courseUniversityName=$courseUniversityName',
    );

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded.containsKey('data')) {
         return decoded['data'] as int;
      } else {
         throw Exception("Failed to parse estimated price: 'data' key missing");
      }
    } else {
      throw Exception("Failed to fetch estimated price: ${response.body}");
    }
  }
}