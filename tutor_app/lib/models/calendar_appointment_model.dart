import 'dart:convert';

class CalendarAppointment {
  final int id;

  final String course;

  final String tutor;

  final String student;

  final DateTime date;

  final double cost;

  final int ownerId;

  CalendarAppointment({
    required this.id,
    required this.course,
    required this.tutor,
    required this.student,
    required this.date,
    required this.cost,
    required this.ownerId,
  });
  factory CalendarAppointment.fromJson(Map<String, dynamic> json, int oId) {
    return CalendarAppointment(
        id: json['id'] as int,
        course: json['courseName'] as String,
        tutor: json['tutorName'] as String,
        student: json['student'] as String,
        date: DateTime.parse(json['dateTime'] as String),
        cost: double.parse(json['cost']),
        ownerId: oId);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'tutor': tutor,
      'student': student,
      'date': date.toIso8601String(),
      'cost': cost,
      'ownerId': ownerId
    };
  }
}

List<CalendarAppointment> appointmentsFromJson(List<dynamic> json, int oId) {
  List<CalendarAppointment> appointments = [];
  for (var item in json) {
    appointments.add(CalendarAppointment.fromJson(item, oId));
  }
  return appointments;
}

List<CalendarAppointment> parseAppointmentsInIsolate(String jsonString, id) {
  final List<dynamic> decodedJson = jsonDecode(jsonString) as List<dynamic>;
  List<CalendarAppointment> appointments = decodedJson.map((dynamic item) {
    if (item is Map<String, dynamic>) {
      try {
        return CalendarAppointment.fromJson(item, id);
      } catch (e) {
        rethrow;
      }
    } else {
      throw FormatException(
          'Invalid item format in JSON list (in isolate): $item');
    }
  }).toList();

  return appointments;
}
