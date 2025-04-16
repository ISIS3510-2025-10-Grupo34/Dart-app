class Course {
  final int id;
  final int tutorId;
  final String tutorName;
  final String university;
  final String courseName;
  final String major;
  final double price;

  Course({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.university,
    required this.courseName,
    required this.major,
    required this.price,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      tutorId: json['tutor_id'],
      tutorName: json['tutor_name'],
      university: json['university'],
      courseName: json['course_name'],
      major: json['major'],
      price: json['price'].toDouble(),
    );
  }
}
 