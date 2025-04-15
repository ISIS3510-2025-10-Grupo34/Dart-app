class Review {
  final int tutoringSessionId;
  final int tutorId; // You can keep this in the model if needed elsewhere
  final int studentId;
  final double rating;
  final String comment;

  Review({
    required this.tutoringSessionId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      tutoringSessionId: json['tutoringSessionId'],
      tutorId: json['tutorId'],
      studentId: json['studentId'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutoringSessionId': tutoringSessionId,
      'studentId': studentId,
      'rating': rating,
      'comment': comment,
    };
  }
}
