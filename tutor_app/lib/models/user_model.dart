import 'review_model.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? university;
  String? major;
  String? areaOfExpertise;
  String? learningStyles;
  String? profilePicturePath;
  String? role;
  double? avgRating;
  List<Review>? reviews;

  User(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.university,
      this.major,
      this.areaOfExpertise,
      this.learningStyles,
      this.profilePicturePath,
      this.role,
      this.avgRating,
      this.reviews});

  void fromLoginJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    role = json['role'];
    email = json['email'];
  }

  void fromJsonStudent(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['phone_number'];
    university = json['university'];
    major = json['major'];
    learningStyles = json['learning_styles'].join(', ');
    profilePicturePath = json['profile_picture'] ?? "";
  }

  void fromJsonTutor(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['whatsappContact'];
    university = json['university'];
    areaOfExpertise = json['subjects'];
    avgRating = json['ratings'].toDouble() ?? 0.0;
    final List<Review> reviewList = [];
    for (Map<String, dynamic> review in json['reviews']) {
      reviewList.add(Review(
        rating: review['rating'].toDouble(),
        comment: review['comment'],
        tutoringSessionId: review['tutoringSessionId'],
        tutorId: review['tutorId'],
        studentId: review['studentId'],
      ));
    }
    reviews = reviewList;
  }

  void fromJsonTutorProfile(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['whatsappContact'];
    university = json['university'];
    areaOfExpertise = json['subjects'];
    avgRating = json['ratings'].toDouble() ?? 0.0;
    final List<Review> reviewList = [];
    for (Map<String, dynamic> review in json['reviews']) {
      reviewList.add(Review(
        rating: review['rating'].toDouble(),
        comment: review['comment'],
      ));
    }
    reviews = reviewList;
  }
}
