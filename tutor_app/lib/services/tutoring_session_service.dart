import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

void _isolateEntryPoint(Map<String, dynamic> message) async {
  final SendPort sendPort = message['port'] as SendPort;
  final String apiUrl = message['apiUrl'] as String;

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> resultMaps =
          List<Map<String, dynamic>>.from(data);
      sendPort.send({'status': 'success', 'data': resultMaps});
    } else {
      sendPort.send({
        'status': 'error',
        'message': 'Failed to load sessions: Status code ${response.statusCode}'
      });
    }
  } catch (e) {
    sendPort.send({'status': 'error', 'message': e.toString()});
  }
}

class TutoringSessionService {
  Future<List<TutoringSession>> fetchTutoringSessions() async {
    final apiUrl = '${EnvConfig.apiUrl}/api/tutoring-sessions-with-names/'; //
    final ReceivePort receivePort = ReceivePort();
    final Completer<List<TutoringSession>> completer =
        Completer<List<TutoringSession>>();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn(
          _isolateEntryPoint, {'port': receivePort.sendPort, 'apiUrl': apiUrl},
          onError: receivePort.sendPort,
          onExit: receivePort.sendPort,
          errorsAreFatal: true);
      receivePort.listen((dynamic message) {
        if (message is Map<String, dynamic>) {
          final String status = message['status'];
          if (status == 'success') {
            final List<Map<String, dynamic>> resultMaps = message['data'];
            final sessions = resultMaps
                .map((json) => TutoringSession.fromJson(json))
                .toList(); //
            if (!completer.isCompleted) {
              completer.complete(sessions);
            }
          } else if (status == 'error') {
            final String errorMessage =
                message['message'] ?? 'Unknown isolate error';
            if (!completer.isCompleted) {
              completer.completeError(Exception(errorMessage));
            }
          } else {
            if (!completer.isCompleted) {
              completer.completeError(
                  Exception("Received unexpected message format from isolate"));
            }
          }
        } else {
          if (!completer.isCompleted) {
            completer.completeError(Exception(
                "Received unexpected data type from isolate: ${message.runtimeType}"));
          }
        }
        receivePort.close();
        isolate?.kill(priority: Isolate.immediate);
        isolate = null;
      });
    } catch (e) {
      receivePort.close();
      isolate?.kill(priority: Isolate.immediate);
      isolate = null;
      if (!completer.isCompleted) {
        completer.completeError(Exception('Failed to spawn isolate: $e'));
      }
    }
    return completer.future;
  }

  Future<List<TutoringSession>> fetchAvailableTutoringSessions() async {
    final allSessions = await fetchTutoringSessions();
    return allSessions.where((session) => session.student == null).toList();
  }

  Future<void> createTutoringSession({
    required int cost,
    required String dateTime,
    required int courseId,
    required int tutorId,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cost': cost,
        'dateTime': dateTime,
        'courseId': courseId,
        'tutorId': tutorId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Error creating tutoring session: ${response.body}");
    }
  }

  Future<int> getEstimatedPrice({
    required int tutorId,
    required String courseUniversityName,
  }) async {
    final url = Uri.parse(
      '${EnvConfig.apiUrl}/api/course-estimate-price/?tutorId=$tutorId&courseUniversityName=$courseUniversityName',
    );

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] as int;
    } else {
      throw Exception("Failed to fetch estimated price: ${response.body}");
    }
  }
}
