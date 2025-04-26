import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationCacheService {
  static const _cacheKey = 'cached_notifications';

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((json) => NotificationModel.fromJson(json)).toList();
  }

Future<void> cacheNotificationsForUniversity(String university, List<NotificationModel> notifications) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = notifications.map((n) => n.toJson()).toList();
  prefs.setString('notifications_$university', jsonEncode(jsonList));
}

}
