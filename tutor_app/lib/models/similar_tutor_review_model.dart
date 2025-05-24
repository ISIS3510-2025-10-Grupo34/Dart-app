import 'package:flutter/foundation.dart';

class SimilarTutorReviewsResponse {
  final List<SimilarTutorInfo> similarTutorReviews;

  SimilarTutorReviewsResponse({required this.similarTutorReviews});

  factory SimilarTutorReviewsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['similar_tutor_reviews'] as List?;
    List<SimilarTutorInfo> reviewsList = list != null
        ? list.map((i) => SimilarTutorInfo.fromJson(i)).toList()
        : [];
    return SimilarTutorReviewsResponse(similarTutorReviews: reviewsList);
  }
}

class SimilarTutorInfo {
  final int similarTutorId;
  final List<String> similarityBasis;
  final List<BestReview> bestReviews;

  SimilarTutorInfo({
    required this.similarTutorId,
    required this.similarityBasis,
    required this.bestReviews,
  });

  factory SimilarTutorInfo.fromJson(Map<String, dynamic> json) {
    var basisList = json['similarity_basis'] as List?;
    List<String> basis =
        basisList != null ? basisList.map((s) => s.toString()).toList() : [];

    var reviewsList = json['best_reviews'] as List?;
    List<BestReview> bestReviewsList = reviewsList != null
        ? reviewsList.map((i) => BestReview.fromJson(i)).toList()
        : [];

    return SimilarTutorInfo(
      similarTutorId: json['similar_tutor_id'] ?? 0,
      similarityBasis: basis,
      bestReviews: bestReviewsList,
    );
  }
}

class BestReview {
  final int rating;
  final String comment;
  final String courseName;
  final String reviewDate;

  BestReview({
    required this.rating,
    required this.comment,
    required this.courseName,
    required this.reviewDate,
  });

  factory BestReview.fromJson(Map<String, dynamic> json) {
    return BestReview(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? 'No comment provided',
      courseName: json['course_name'] ?? 'Unknown Course',
      reviewDate: json['review_date'] ?? 'Unknown Date',
    );
  }
}
