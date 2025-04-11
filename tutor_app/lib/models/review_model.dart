class Review {
  final double rating;
  final String comment;

  Review(this.rating, this.comment);

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      (json['rating'] as num).toDouble(),
      json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
