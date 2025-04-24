import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/user_service.dart';
import '../services/review_service.dart';
import '../services/local_cache_service.dart';

class WriteReviewController extends ChangeNotifier {
  final UserService _userService;
  final ReviewService _reviewService;
  final LocalCacheService _cacheService;

  WriteReviewController({
    required UserService userService,
    required ReviewService reviewService,
    required LocalCacheService cacheService,
  })  : _userService = userService,
        _reviewService = reviewService,
        _cacheService = cacheService;

  /// Fetches the tutor profile by ID.
  Future<Map<String, dynamic>> getTutorProfile(int tutorId) async {
    try {
      final profile = await _userService.fetchTutorProfile(tutorId.toString());
      return profile ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Submits a review. If it fails (even without exception), caches it for later sync.
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

    try {
      final success = await _reviewService.submitReview(review);
      if (!success) {
        await _cacheService.cachePendingReview(review);
      }
      return success;
    } catch (e) {
      await _cacheService.cachePendingReview(review);
      return false;
    }
  }
}
