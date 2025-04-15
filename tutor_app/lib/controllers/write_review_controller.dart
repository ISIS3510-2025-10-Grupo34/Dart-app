import '../models/review_model.dart';
import '../services/user_service.dart';
import '../services/review_service.dart';

class WriteReviewController {
  final UserService _userService;
  final ReviewService _reviewService;

  WriteReviewController({
    UserService? userService,
    ReviewService? reviewService,
  })  : _userService = userService ?? UserService(),
        _reviewService = reviewService ?? ReviewService();

  Future<Map<String, dynamic>> getTutorProfile(int tutorId) async {
    final profile = await _userService.fetchTutorProfile(tutorId.toString());
    return profile ?? {};
  }

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
    return await _reviewService.submitReview(review);
  }
}
