class Course {
  final int id;
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