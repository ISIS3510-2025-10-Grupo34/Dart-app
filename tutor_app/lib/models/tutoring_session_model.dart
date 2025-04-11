class TutoringSession {
  final int id;
  final String tutorName;
  final int tutorId;
  final String course;
  final String university;
  final double cost;
  final String dateTime;
  final String? student;

  TutoringSession({
    required this.id,
    required this.tutorName,
    required this.tutorId,
    required this.course,
    required this.university,
    required this.cost,
    required this.dateTime,
    required this.student,
  });

  factory TutoringSession.fromJson(Map<String, dynamic> json) {
    return TutoringSession(
      id: json['id'],
      tutorName: json['tutor'] ?? '',
      tutorId: json['tutor_id'],
      course: json['course'] ?? '',
      university: json['university'] ?? '',
      cost: json['cost'].toDouble(),
      dateTime: json['date_time'] ?? '',
      student: json['student'],
    );
  }
}
