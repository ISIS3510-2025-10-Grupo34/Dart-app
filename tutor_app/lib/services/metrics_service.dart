import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/utils/env_config.dart';

class MetricsService {
  Future<void> sendTimeToBook(int milliseconds) async {
    try {
      final url = Uri.parse('${EnvConfig.apiUrl}/api/time-to-book/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"time_to_book": milliseconds}),
      );

      if (response.statusCode != 201 && kDebugMode) {
        print('❌ Failed to send time-to-book: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending time-to-book: $e');
      }
    }
  }

  Future<void> sendTutorProfileLoadTime(int milliseconds) async {
    try {
      final url = Uri.parse('${EnvConfig.apiUrl}/api/tutor-profile-load-time/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"profile_load_time": milliseconds}),
      );

      if (response.statusCode != 201 && kDebugMode) {
        print('❌ Failed to send profile load time: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending profile load time: $e');
      }
    }
  }
}
