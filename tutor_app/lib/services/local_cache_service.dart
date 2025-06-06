import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:tutor_app/models/tutoring_session_model.dart';
import '../models/review_model.dart';
import 'location_service.dart';

class LocalCacheService {
  static const String _pendingReviewsKey = 'pending_reviews';
  static const String _pendingNotificationsKey = 'pending_notifications';
  static const String _pendingRegistrationsKey = 'pending_registrations';
  static const String _cachedSessionsKey = 'cached_sessions';
  static const String _cachedStylesKey = 'cached_styles';


  /// ---------------- Reviews ----------------
  Future<void> cachePendingReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final reviews = prefs.getStringList(_pendingReviewsKey) ?? [];
    reviews.add(jsonEncode(review.toJson()));
    await prefs.setStringList(_pendingReviewsKey, reviews);
  }

  Future<List<Review>> getPendingReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingReviewsKey) ?? [];
    return list.map((s) => Review.fromJson(jsonDecode(s))).toList();
  }

  Future<void> removePendingReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingReviewsKey) ?? [];
    list.removeWhere((s) {
      final r = Review.fromJson(jsonDecode(s));
      return r.tutoringSessionId == review.tutoringSessionId &&
          r.tutorId == review.tutorId &&
          r.studentId == review.studentId &&
          r.comment == review.comment &&
          r.rating == review.rating;
    });
    await prefs.setStringList(_pendingReviewsKey, list);
  }

  /// ---------------- Notifications ----------------

  String _notifKey(Map<String, String> n) =>
      "${n['title']}|${n['message']}|${n['place']}|${n['university']}";

  Future<void> cachePendingNotification(
      Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pendingNotificationsKey) ?? [];

    // Normalize all values to String
    final sanitized = <String, String>{};
    notification.forEach((k, v) {
      sanitized[k] = v.toString();
    });
    sanitized.putIfAbsent('university', () => 'General');
    if (!sanitized.containsKey('deadline')) {
      final deadline = DateTime.now().add(Duration(hours: 1)); // ⏰ por defecto
      sanitized['deadline'] = deadline.toIso8601String();
    }

    // Avoid duplicates by key
    final exists = raw.any((s) {
      final m = Map<String, String>.from(jsonDecode(s));
      return _notifKey(m) == _notifKey(sanitized);
    });

    if (!exists) {
      raw.add(jsonEncode(sanitized));
      await prefs.setStringList(_pendingNotificationsKey, raw);
    }
  }

  Future<List<Map<String, String>>> getPendingNotificationsRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pendingNotificationsKey) ?? [];
    return raw.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v.toString()));
    }).toList();
  }

  Future<void> overwriteNotifications(List<Map<String, String>> notifs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _pendingNotificationsKey,
      notifs.map(jsonEncode).toList(),
    );
  }

  Future<void> markNotificationAsSent(Map<String, String> notif) async {
    final all = await getPendingNotificationsRaw();
    final updated = all.map((n) {
      return _notifKey(n) == _notifKey(notif) ? {...n, 'isSent': 'true'} : n;
    }).toList();
    await overwriteNotifications(updated);
  }

  Future<void> removeSingleNotification(Map<String, String> notif) async {
    final all = await getPendingNotificationsRaw();
    final filtered =
        all.where((n) => _notifKey(n) != _notifKey(notif)).toList();
    await overwriteNotifications(filtered);
  }

  Future<void> clearSentNotifications() async {
    final all = await getPendingNotificationsRaw();
    final pending = all.where((n) => n['isSent'] != 'true').toList();
    await overwriteNotifications(pending);
  }

  /// Sends all pending notifications, dedupes and cleans up
  Future<int> syncNotificationsWithService(
    LocationService service, {
    List<Map<String, String>>? notificationsToSend,
  }) async {
    // Dedupe
    final raw = await getPendingNotificationsRaw();
    final uniques = <String, Map<String, String>>{};
    for (var n in raw) {
      final key = _notifKey(n);
      uniques.putIfAbsent(key, () => n);
    }
    await overwriteNotifications(uniques.values.toList());
    int sentCount = 0;
    final pending = notificationsToSend ??
        (await getPendingNotificationsRaw())
            .where((n) => n['isSent'] != 'true')
            .toList();

    for (var notif in pending) {
      bool sent = false;
      for (int attempt = 1; attempt <= 6 && !sent; attempt++) {
        final success = await service.sendNotification(
          title: notif['title']!,
          message: notif['message']!,
          place: notif['place']!,
          university: notif['university']!,
        );
        if (success) {
          sent = true;
          sentCount++;
          await markNotificationAsSent(notif);
          await removeSingleNotification(notif);
        } else {
          await Future.delayed(Duration(seconds: 3 * attempt));
        }
      }
    }

    await clearSentNotifications();
    return sentCount;
  }

  /// ---------------- Registrations ----------------

  Future<void> cachePendingRegistration(
      Map<String, dynamic> registrationData) async {
    final prefs = await SharedPreferences.getInstance();
    final registrations = prefs.getStringList(_pendingRegistrationsKey) ?? [];
    final String newDataString = jsonEncode(registrationData);
    if (!registrations.contains(newDataString)) {
      registrations.add(newDataString);
      await prefs.setStringList(_pendingRegistrationsKey, registrations);
      debugPrint("Cached registration data.");
    } else {
      debugPrint("Attempted to cache duplicate registration data.");
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingRegistrationsKey) ?? [];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<void> removePendingRegistration(
      Map<String, dynamic> registrationData) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingRegistrationsKey) ?? [];
    final timestampToRemove = registrationData['timestamp'];
    if (timestampToRemove != null) {
      list.removeWhere((s) {
        try {
          final data = jsonDecode(s) as Map<String, dynamic>;
          return data['timestamp'] == timestampToRemove;
        } catch (e) {
          debugPrint("Error decoding registration for removal: $e");
          return false;
        }
      });
      await prefs.setStringList(_pendingRegistrationsKey, list);
      debugPrint(
          "Removed registration data with timestamp: $timestampToRemove");
    } else {
      debugPrint(
          "Could not remove registration: missing timestamp identifier.");
    }
  }
  /// ---------------- Sessions ----------------
      Future<void> cacheTutoringSessions(List<TutoringSession> sessions) async {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sessions.map((s) => jsonEncode(s.toJsonSTS())).toList();
      await prefs.setStringList(_cachedSessionsKey, jsonList);
    }

    Future<List<TutoringSession>> getCachedTutoringSessions() async {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_cachedSessionsKey);
      if (jsonList == null) return [];
      return jsonList
          .map((s) => TutoringSession.fromJsonSTS(jsonDecode(s)))
          .toList();
    }
  /// ---------------- Learning Styles ----------------
    Future<void> cacheLearningStyles(Map<String, String> styles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(styles);
    await prefs.setString(_cachedStylesKey, encoded);
  }

  Future<Map<String, String>> getCachedLearningStyles() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_cachedStylesKey);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    return Map<String, String>.from(decoded);
  }

}
