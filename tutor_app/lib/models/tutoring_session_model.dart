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

  /// Desde API (formato original del backend)
  factory TutoringSession.fromJson(Map<String, dynamic> json) {
    return TutoringSession(
      id: json['id'] ?? 0,
      tutorName: json['tutor'] ?? '',
      tutorId: json['tutor_id'] ?? 0,
      course: json['course'] ?? '',
      university: json['university'] ?? '',
      cost: _parseDouble(json['cost']),
      dateTime: json['date_time'] ?? '',
      student: json['student']?.toString(), 
    );
  }

  /// Desde caché de Student Tutoring Sessions (formato alterno)
  factory TutoringSession.fromJsonSTS(Map<String, dynamic> json) {
    return TutoringSession(
      id: json['id'] ?? 0,
      tutorName: json['tutorName'] ?? '',
      tutorId: json['tutorId'] ?? 0,
      course: json['courseName'] ?? '',
      university: json['university'] ?? '',
      cost: _parseDouble(json['cost']),
      dateTime: json['dateTime'] ?? '',
      student: json['student']?.toString(),
    );
  }

  /// Para guardar en caché (formato API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor': tutorName,
      'tutor_id': tutorId,
      'course': course,
      'university': university,
      'cost': cost,
      'date_time': dateTime,
      'student': student,
    };
  }

  /// Para guardar en caché (formato STS)
  Map<String, dynamic> toJsonSTS() {
    return {
      'id': id,
      'tutorName': tutorName,
      'tutorId': tutorId,
      'courseName': course,
      'university': university,
      'cost': cost,
      'dateTime': dateTime,
      'student': student,
    };
  }

  /// Método auxiliar para evitar errores al parsear números
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
