import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class LocalCacheService {
  static const String _pendingReviewsKey = 'pending_reviews';
  static const String _pendingNotificationsKey = 'pending_notifications';

  /// Cacha reseña como JSON
  Future<void> cachePendingReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final reviews = prefs.getStringList(_pendingReviewsKey) ?? [];
    reviews.add(jsonEncode(review.toJson()));
    await prefs.setStringList(_pendingReviewsKey, reviews);
  }

  /// Obtiene reseñas pendientes
  Future<List<Review>> getPendingReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_pendingReviewsKey) ?? [];
    return reviewsJson.map((json) => Review.fromJson(jsonDecode(json))).toList();
  }

  /// Elimina una reseña específica
  Future<void> removePendingReview(Review reviewToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_pendingReviewsKey) ?? [];

    reviewsJson.removeWhere((json) {
      final review = Review.fromJson(jsonDecode(json));
      return _isSameReview(review, reviewToRemove);
    });

    await prefs.setStringList(_pendingReviewsKey, reviewsJson);
  }

  /// Limpia todas las reseñas
  Future<void> clearPendingReviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingReviewsKey);
  }

  /// Cacha notificación como JSON
  Future<void> cachePendingNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_pendingNotificationsKey) ?? [];
    notifications.add(jsonEncode(notification));
    await prefs.setStringList(_pendingNotificationsKey, notifications);
  }

  /// Obtiene notificaciones pendientes
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_pendingNotificationsKey) ?? [];
    return notificationsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
  }

  /// Limpia todas las notificaciones
  Future<void> clearPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingNotificationsKey);
  }

  /// Compara reseñas por atributos clave
  bool _isSameReview(Review a, Review b) {
    return a.tutoringSessionId == b.tutoringSessionId &&
           a.tutorId == b.tutorId &&
           a.studentId == b.studentId &&
           a.comment == b.comment &&
           a.rating == b.rating;
  }
}
