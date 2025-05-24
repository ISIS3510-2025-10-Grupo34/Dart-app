import '../models/calendar_appointment_model.dart';
import './local_database_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class CalendarAppointmentService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  static Future<String> _fetchCalendarAppointments(id) async {
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
        return response.body;
      } else {
        throw Exception(
            'Failed to load appointments (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw "Please check your connection";
    }
  }

  static Future<List<CalendarAppointment>> fetchAndParseAppointmentsForOwner(
      String ownerId) async {
    try {
      final String rawJson = await _fetchCalendarAppointments(ownerId);

      if (rawJson.isEmpty || rawJson == "[]") {
        return [];
      }

      final List<dynamic> decodedJsonList =
          jsonDecode(rawJson) as List<dynamic>;
      List<CalendarAppointment> appointments = [];
      List<String> parsingErrors = [];

      for (var jsonData in decodedJsonList) {
        if (jsonData is Map<String, dynamic>) {
          try {
            appointments.add(
                CalendarAppointment.fromJson(jsonData, int.parse(ownerId)));
          } catch (e) {
            parsingErrors.add(
                "Failed to parse appointment item (ID: ${jsonData['id'] ?? 'N/A'}): $e");
          }
        } else {
          parsingErrors.add("Invalid item format in JSON list: $jsonData");
        }
      }
      if (parsingErrors.isNotEmpty) {
        if (appointments.isEmpty) {
          // If no items could be parsed at all
          throw Exception(
              "All items failed to parse for owner $ownerId. First error: ${parsingErrors.first}");
        }
      }
      return appointments;
    } catch (e) {
      throw Exception(
          "Failed to process appointments for owner $ownerId in isolate: $e");
    }
  }
}
