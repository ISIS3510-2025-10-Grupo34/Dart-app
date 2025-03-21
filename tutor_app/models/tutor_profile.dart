class TutorProfile {
  final String name;
  final String university;
  final String profilePicture;
  final double ratings;
  final List<Review> reviews;
  final List<String> subjects;
  final String whatsappContact;

  TutorProfile({
    required this.name,
    required this.university,
    required this.profilePicture,
    required this.ratings,
    required this.reviews,
    required this.subjects,
    required this.whatsappContact,
  });

  factory TutorProfile.fromJson(Map<String, dynamic> json) {
    return TutorProfile(
      name: json['name'],
      university: json['university'],
      profilePicture: json['profile_picture'],
      ratings: (json['ratings'] as num).toDouble(),
      reviews: (json['reviews'] as List).map((r) => Review.fromJson(r)).toList(),
      subjects: List<String>.from(json['subjects']),
      whatsappContact: json['whatsapp_contact'],
    );
  }
}

class Review {
  final String initials;
  final double rating;
  final String comment;

  Review({required this.initials, required this.rating, required this.comment});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      initials: json['initials'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
    );
  }
}
