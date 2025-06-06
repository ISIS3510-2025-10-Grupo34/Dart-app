import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/tutoring_session_model.dart';
import '../utils/env_config.dart';

class SessionFetchResult {
  final List<TutoringSession> sessions;
  final bool isFromCache;

  SessionFetchResult({required this.sessions, required this.isFromCache});
}


void _isolateEntryPoint(Map<String, dynamic> message) async {
  final SendPort sendPort = message['port'] as SendPort;
  final String apiUrl = message['apiUrl'] as String;
  final String method = message['method'] as String? ?? 'GET'; 
  final Map<String, dynamic>? body = message['body'] as Map<String, dynamic>?; 
  final Map<String, String> headers = {'Content-Type': 'application/json'}; 

  try {
    http.Response response;
    if (method.toUpperCase() == 'POST') {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body), 
      );
    } else { 
      response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );
    }

    if (response.statusCode == 200) {
      final dynamic decodedBody = jsonDecode(response.body);

      if (apiUrl.contains('/api/tutoring-sessions-ordered/')) {
          if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('tutoring_sessions')) {
              final List<dynamic> data = decodedBody['tutoring_sessions'];
              final List<Map<String, dynamic>> resultMaps = List<Map<String, dynamic>>.from(data);
              sendPort.send({'status': 'success', 'data': resultMaps});
          } else {
              sendPort.send({
                'status': 'error',
                'message': 'Failed to parse ordered sessions: Unexpected response format'
              });
          }
      } else if (apiUrl.contains('/api/tutoring-sessions-with-names/')) {
          if (decodedBody is List) {
              final List<dynamic> data = decodedBody;
              final List<Map<String, dynamic>> resultMaps = List<Map<String, dynamic>>.from(data);
              sendPort.send({'status': 'success', 'data': resultMaps});
          } else {
              sendPort.send({
                'status': 'error',
                'message': 'Failed to parse sessions-with-names: Unexpected response format'
              });
          }
      }
      else {
          sendPort.send({
            'status': 'error',
            'message': 'Isolate does not know how to handle response from $apiUrl'
          });
      }

    } else {
      sendPort.send({
        'status': 'error',
        'message': 'Request failed: Status code ${response.statusCode}, Body: ${response.body}' 
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
  Future<TutoringSession> fetchTutoringSessionById(int sessionId) async {
  final response = await http.get(
    Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions/$sessionId/'),
    headers: {
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return TutoringSession.fromJson(data);
  } else {
    throw Exception('Failed to fetch tutoring session details');
  }
}

  Future<SessionFetchResult> fetchOrderedSessions(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'ordered_sessions_page_$page';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(cachedData);
        final parsedSessions = decodedList.map((json) => TutoringSession.fromJson(json)).toList();
        return SessionFetchResult(sessions: parsedSessions, isFromCache: true);
      } catch (e) {
        await prefs.remove(cacheKey);
      }
    }

    final apiUrl = '${EnvConfig.apiUrl}/api/tutoring-sessions-ordered/';
    final ReceivePort receivePort = ReceivePort();
    final Completer<List<TutoringSession>> networkCompleter = Completer<List<TutoringSession>>();
    Isolate? isolate;
    List<TutoringSession> sessions = [];

    try {
       isolate = await Isolate.spawn(
          _isolateEntryPoint,
          {
            'port': receivePort.sendPort,
            'apiUrl': apiUrl,
            'method': 'POST', 
            'body': {'page': page} 
          },
          onError: receivePort.sendPort,
          onExit: receivePort.sendPort,
          errorsAreFatal: true);

       receivePort.listen((dynamic message) {

         if (message is Map<String, dynamic>) {
           final String status = message['status'];
           if (status == 'success') {
             final List<Map<String, dynamic>> resultMaps = message['data'];

             final parsedSessions = resultMaps.map((json) => TutoringSession.fromJson(json)).toList();
             if (!networkCompleter.isCompleted) networkCompleter.complete(parsedSessions);
           } else if (status == 'error') {
             final String errorMessage = message['message'] ?? 'Unknown isolate error';
             if (!networkCompleter.isCompleted) networkCompleter.completeError(Exception(errorMessage));
           } else {
              if (!networkCompleter.isCompleted) networkCompleter.completeError(Exception("Unexpected message status from isolate"));
           }
         } else {
            if (!networkCompleter.isCompleted) networkCompleter.completeError(Exception("Unexpected data type from isolate: ${message.runtimeType}"));
         }

         receivePort.close();
         isolate?.kill(priority: Isolate.immediate);
         isolate = null;
       });


       sessions = await networkCompleter.future;
       final List<Map<String, dynamic>> sessionsToCache = sessions.map((s) => s.toJson()).toList(); // Assuming toJson exists
       await prefs.setString(cacheKey, jsonEncode(sessionsToCache));

       return SessionFetchResult(sessions: sessions, isFromCache: false);

    } catch (e) {
      receivePort.close(); 
      isolate?.kill(priority: Isolate.immediate); 
      isolate = null;
      throw Exception('Failed to load ordered sessions via isolate: $e');
    }
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
      if (decoded.containsKey('data')) {
         return decoded['data'] as int;
      } else {
         throw Exception("Failed to parse estimated price: 'data' key missing");
      }
    } else {
      throw Exception("Failed to fetch estimated price: ${response.body}");
    }
  }

  Future<List<TutoringSession>> fetchTutoringSessionsInOrder() async {
    try {
      // 1. Obtener todas las sesiones
      final responseSessions = await http.get(
        Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-with-names/'),
        headers: {'Content-Type': 'application/json'},
      );

      // 2. Obtener el orden de tutores
      final responseOrderedTutors = await http.get(
        Uri.parse('${EnvConfig.apiUrl}/api/tutors_id_ordered/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (responseSessions.statusCode == 200 && responseOrderedTutors.statusCode == 200) {
        final List<dynamic> sessionList = jsonDecode(responseSessions.body);
        final Map<String, dynamic> orderedTutorsJson = jsonDecode(responseOrderedTutors.body);
        final List<dynamic> orderedTutorIds = orderedTutorsJson['ordered_tutor_ids'];

        final List<Map<String, dynamic>> sessions = List<Map<String, dynamic>>.from(sessionList);

        // Filtrar por sesiones disponibles (student == null)
        final availableSessions = sessions.where((session) => session['student'] == null).toList();

        // Ordenar según el orden de tutor_id
        availableSessions.sort((a, b) {
          final int indexA = orderedTutorIds.indexOf(a['tutor_id']);
          final int indexB = orderedTutorIds.indexOf(b['tutor_id']);

          if (indexA == -1 && indexB == -1) return 0;
          if (indexA == -1) return 1;
          if (indexB == -1) return -1;
          return indexA.compareTo(indexB);
        });

        // Mapear a TutoringSession model
        return availableSessions.map((json) => TutoringSession.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error en la carga de sesiones (${responseSessions.statusCode}) o en la carga de orden de tutores (${responseOrderedTutors.statusCode})');
      }
    } catch (e) {
      throw Exception('Error al obtener sesiones ordenadas: $e');
    }
  }

  Future<List<TutoringSession>> fetchPaginatedSessions({
    required int page,
    String? universityFilter,
    String? courseFilter,
    String? tutorNameFilter,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-ordered/');

    final Map<String, dynamic> body = {
      'page': page,
      if (universityFilter != null && universityFilter.isNotEmpty)
        'university_filter': universityFilter,
      if (courseFilter != null && courseFilter.isNotEmpty)
        'course_filter': courseFilter,
      if (tutorNameFilter != null && tutorNameFilter.isNotEmpty)
        'tutor_name_filter': tutorNameFilter,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['tutoring_sessions'];
      return data.map((json) => TutoringSession.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch sessions: ${response.statusCode} - ${response.body}");
    }
  }
  
}