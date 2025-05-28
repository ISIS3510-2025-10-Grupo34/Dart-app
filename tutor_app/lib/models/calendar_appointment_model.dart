import 'dart:convert';

class CalendarAppointment {
  final int id;

  final String courseName;

  final String tutorName;

  final String student;

  final DateTime dateTime;

  final double cost;

  final int ownerId;

  CalendarAppointment({
    required this.id,
    required this.courseName,
    required this.tutorName,
    required this.student,
    required this.dateTime,
    required this.cost,
    required this.ownerId,
  });
  factory CalendarAppointment.fromJson(Map<String, dynamic> json, int oId) {
    double parsedCost;
    if (json['cost'] is String) {
      parsedCost = double.tryParse(json['cost'] as String) ?? 0.0;
    } else if (json['cost'] is num) {
      parsedCost = (json['cost'] as num).toDouble();
    } else {
      parsedCost = 0.0;
    }
    return CalendarAppointment(
        id: json['id'] as int,
        courseName: json['courseName'] as String,
        tutorName: json['tutorName'] as String,
        student: json['student'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        cost: parsedCost,
        ownerId: oId);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'tutorName': tutorName,
      'student': student,
      'dateTime': dateTime.toIso8601String(),
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
