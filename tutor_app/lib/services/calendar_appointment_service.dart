import '../models/calendar_appointment_model.dart';
import './local_database_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class CalendarAppointmentService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<List<CalendarAppointment>> fetchCalendarAppointments(id) async {
    // List<CalendarAppointment> localCalendarAppointments =
    //     await _dbService.getAppointments(id);
    // if (localCalendarAppointments.isNotEmpty) {
    //   return localCalendarAppointments;
    // }
    final apiUrl = '${EnvConfig.apiUrl}/api/booked-sessions/?id=$id';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<CalendarAppointment> calendarList =
            appointmentsFromJson(data["booked_sessions"], id);
        if (calendarList.isNotEmpty) {
          //await _dbService.bulkInsertCalendarAppointments(calendarList);
        }
        return calendarList;
      } else {
        throw Exception(
            'Failed to load appointments (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw "Please check your connection";
    }
  }
}
