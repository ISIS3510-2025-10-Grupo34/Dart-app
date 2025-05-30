import '../models/calendar_appointment_model.dart';
import './local_database_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CalendarAppointmentService {
  static Future<List<CalendarAppointment>> _fetchCalendarAppointments(
      id) async {
    final List<CalendarAppointment> fetchedAppointments = [];
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResult != ConnectivityResult.none;
    final LocalDatabaseService dbService = LocalDatabaseService();

    if (!isOnline) {
      if (kDebugMode) {
        print(
            '[CalendarAppointmentService] No internet. Fetching from local DB for ownerId: $id');
      }
      final localAppointments = await dbService.getAppointments(int.parse(id));
      if (localAppointments.isNotEmpty) {
        return localAppointments;
      } else {
        if (kDebugMode) {
          print(
              '[CalendarAppointmentService] No local data found for ownerId: $id');
        }
        return fetchedAppointments;
      }
    }

    if (kDebugMode) {
      print(
          '[CalendarAppointmentService] Internet connection available. Fetching from network for ownerId: $id');
    }
    final apiUrl =
        'http://tutorapp-env-1.eba-3gbpmybu.us-east-1.elasticbeanstalk.com/api/booked-sessions/?id=$id';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final rawJson = response.body;
        if (rawJson.isNotEmpty && rawJson != "[]") {
          try {
            final Map<String, dynamic> decodedJsonList =
                jsonDecode(rawJson) as Map<String, dynamic>;
            List<dynamic>? iterator = decodedJsonList["booked_sessions"] ?? [];
            for (var jsonData in iterator!) {
              if (jsonData is Map<String, dynamic>) {
                fetchedAppointments
                    .add(CalendarAppointment.fromJson(jsonData, int.parse(id)));
              }
            }
            await dbService.bulkInsertCalendarAppointments(fetchedAppointments);
            if (kDebugMode) {
              print(
                  '[CalendarAppointmentService] Local DB refreshed with ${fetchedAppointments.length} appointments for ownerId: $id');
            }
          } catch (e) {
            if (kDebugMode) {
              print(
                  '[CalendarAppointmentService] Error parsing or saving network data to DB: $e');
            }
          }
        }
        return fetchedAppointments;
      } else {
        if (kDebugMode) {
          print(
              '[CalendarAppointmentService] Failed to load appointments from network (Status code: ${response.statusCode}). Trying local DB for ownerId: $id');
        }
        final localAppointments =
            await dbService.getAppointments(int.parse(id));
        if (localAppointments.isNotEmpty) {
          return localAppointments;
        }
        throw Exception(
            'Failed to load appointments (Status code: ${response.statusCode}) and no local data available.');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '[CalendarAppointmentService] Network error: $e. Trying local DB for ownerId: $id');
      }
      final localAppointments = await dbService.getAppointments(int.parse(id));
      if (localAppointments.isNotEmpty) {
        return localAppointments;
      }
      throw "Please check your connection and no local data available.";
    }
  }

  static Future<List<CalendarAppointment>> fetchAndParseAppointmentsForOwner(
      Map<String, dynamic> message) async {
    final String ownerId = message['ownerId'] as String;
    final RootIsolateToken? token = message['token'] as RootIsolateToken?;

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    } else if (kDebugMode) {
      print(
          '[CalendarAppointmentService] Warning: RootIsolateToken is null. Plugin calls in isolate might fail if this is not the root isolate.');
    }

    try {
      final List<CalendarAppointment> appointments =
          await _fetchCalendarAppointments(ownerId);
      return appointments;
    } catch (e) {
      throw "[CalendarAppointmentService] Failed to process appointments for owner $ownerId: $e";
    }
  }
}
