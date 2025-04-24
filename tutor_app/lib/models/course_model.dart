class Course {
  final int id;
<<<<<<< HEAD
  final String course_name;
  final double university_id;

  Course({
    required this.id,
    required this.course_name,
    required this.university_id,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      course_name: json['course_name'],
      university_id: json['university_id'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': course_name,
      'university_id': university_id,
    };
  }

}
=======
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

  // Convertir JSON a objeto Course
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
 
>>>>>>> main
