import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/utils/env_config.dart';

class ProfileCreationTimeService {
  Future<void> sendTimeIfNeeded(DateTime? startTime) async {
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    final timeInSeconds = duration.inSeconds + 40;
    final url = Uri.parse('${EnvConfig.apiUrl}/api/profile-creation-time/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "time_in_seconds": timeInSeconds,
        }),
      );

      if (response.statusCode != 200) {
      }
    } catch (e) {
    }
  }
}