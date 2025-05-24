import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutor_app/services/notication_cache_servicie.dart';
import 'package:tutor_app/utils/env_config.dart';
import '../models/notification_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class NotificationController {
  final String baseUrl = "${EnvConfig.apiUrl}/api/get-notifications/";
  final NotificationCacheService cacheService = NotificationCacheService();

  Future<List<NotificationModel>> fetchNotificationsByUniversity(String universityName) async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity == ConnectivityResult.none) {
    return await getCachedNotifications(universityName);
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
    final notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
    await cacheNotificationsForUniversity(universityName, notifications);
    return notifications;
  } else {
    throw Exception('Error al obtener notificaciones: ${response.statusCode}');
  }
}
  Future<List<NotificationModel>> getCachedNotifications(String universityName) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('notifications_$universityName');
  if (jsonString == null) return [];
  final List data = jsonDecode(jsonString);
  return data.map((item) => NotificationModel.fromJson(item)).toList();
}


  Future<void> cacheNotificationsForUniversity(String university, List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications.map((n) => n.toJson()).toList();
    prefs.setString('notifications_$university', jsonEncode(jsonList));
  }

  Future<void> preloadAllNotifications(List<String> universities) async {
  for (final uni in universities) {
    try {
      final data = await fetchNotificationsByUniversity(uni);
      await cacheNotificationsForUniversity(uni, data);
    } catch (e) {
      // Manejo opcional de errores
      print("❌ Error al precargar notificaciones para $uni: $e");
    }
  }
}

}
