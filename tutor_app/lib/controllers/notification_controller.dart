import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tutor_app/utils/env_config.dart';
import '../models/notification_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NotificationController {
  final String baseUrl = "${EnvConfig.apiUrl}/api/get-notifications/";

  Future<List<NotificationModel>> fetchNotificationsByUniversity(String universityName) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw Exception("Sin conexión. Intenta más tarde.");
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"universityName": universityName}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener notificaciones: ${response.statusCode}');
    }
  }
}
