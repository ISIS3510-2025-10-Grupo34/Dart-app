import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/utils/env_config.dart';

class MetricsService {
  Future<void> sendTimeToBook(int milliseconds) async {
    try {
      final url = Uri.parse('${EnvConfig.apiUrl}/api/time-to-book/');
      final now = DateTime.now().toIso8601String();

      final body = {
        "duration": milliseconds,
        "time": now,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 201 && kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  Future<void> sendTutorProfileLoadTime(int milliseconds) async {
    try {
      final url = Uri.parse('${EnvConfig.apiUrl}/api/tutor-profile-load-time/');

      final body = {
        "profile_load_time": milliseconds,
        "time": DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 201 && kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }
}
