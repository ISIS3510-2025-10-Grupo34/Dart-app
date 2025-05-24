class TutorListItemModel {
  final String id;
  final String name;
  final String university;
  final String profilePicture;
  final List<String> subjects;
  final double averageRating;

  TutorListItemModel({
    required this.id,
    required this.name,
    required this.university,
    required this.profilePicture,
    required this.subjects,
    required this.averageRating,
  });

  factory TutorListItemModel.fromJson(Map<String, dynamic> json) {
    return TutorListItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Name',
      university: json['university'] ?? 'Unknown University',
      profilePicture: json['profile_picture'] ?? '',
      subjects:
          json['subjects'] != null ? List<String>.from(json['subjects']) : [],
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
