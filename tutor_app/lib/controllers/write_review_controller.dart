import 'package:flutter/foundation.dart'; // Import ChangeNotifier
import '../services/review_service.dart';
import '../services/local_database_service.dart';
import '../models/review_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WriteReviewController extends ChangeNotifier { // Extend ChangeNotifier
  final ReviewService _reviewService;
  final LocalDatabaseService _localDb;

  WriteReviewController({
    ReviewService? reviewService,
    LocalDatabaseService? localDatabaseService,
  })  : _reviewService = reviewService ?? ReviewService(),
        _localDb = localDatabaseService ?? LocalDatabaseService();

  Future<bool> submitReview({
    required int tutoringSessionId,
    required int tutorId,
    required int studentId,
    required double rating,
    required String comment,
  }) async {
    final review = Review(
      tutoringSessionId: tutoringSessionId,
      tutorId: tutorId,
      studentId: studentId,
      rating: rating,
      comment: comment,
    );

    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity != ConnectivityResult.none;

    if (hasInternet) {
      final success = await _reviewService.submitReview(review);
      if (success) return true;
    }

    await _localDb.cachePendingReview(review);
    return false;
  }

  Future<bool> hasPendingReviewForSession(int sessionId) async {
    return await _localDb.hasReviewForSession(sessionId);
  }

  Future<bool> reviewAlreadySent(Review review) async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity != ConnectivityResult.none;

    if (hasInternet) {
      return await _reviewService.checkIfReviewExists(review);
    } else {
      return await _localDb.hasReviewForSession(review.tutoringSessionId ?? 0);
    }
  }

  Future<Map<String, String>> getTutorProfile(int tutorId) async {
    return await _reviewService.fetchTutorProfile(tutorId);
  }
}