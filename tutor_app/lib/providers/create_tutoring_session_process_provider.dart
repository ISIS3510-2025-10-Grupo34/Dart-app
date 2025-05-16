import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../services/local_cache_service.dart';
import '../services/tutoring_session_service.dart';
import '../misc/constants.dart';

enum TutoringSessionSubmissionState {
  idle,
  submitting,
  success,
  error,
  queuedOffline,
}

class CreateTutoringSessionProcessProvider with ChangeNotifier {
  final TutoringSessionService _sessionService;
  final LocalCacheService _localCacheService;

  late Box _sessionBox;

  CreateTutoringSessionProcessProvider({
    required TutoringSessionService sessionService,
    required LocalCacheService localCacheService,
  })  : _sessionService = sessionService,
        _localCacheService = localCacheService {
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    _sessionBox = await Hive.openBox(HiveKeys.sessionProgressBox);
  }

  int? _cost;
  int? _courseId;
  int? _tutorId;
  String? _dateTime;
  String? _universityName;
  String? _courseName;

  TutoringSessionSubmissionState _submissionState = TutoringSessionSubmissionState.idle;
  TutoringSessionSubmissionState get submissionState => _submissionState;

  String? _submissionError;
  String? get submissionError => _submissionError;

  // Getters para los datos guardados
  int? get savedCost => _sessionBox.get(HiveKeys.cost, defaultValue: _cost);
  int? get savedCourseId => _sessionBox.get(HiveKeys.courseId, defaultValue: _courseId);
  int? get savedTutorId => _sessionBox.get(HiveKeys.tutorId, defaultValue: _tutorId);
  String? get savedDateTime => _sessionBox.get(HiveKeys.dateTime, defaultValue: _dateTime);
  String? get savedUniversity => _sessionBox.get(HiveKeys.university, defaultValue: _universityName);
  String? get savedCourseName => _sessionBox.get(HiveKeys.courseName, defaultValue: _courseName);

  // Setter para guardar todos los datos de la sesión
  Future<void> setSessionDetails({
    required int cost,
    required int courseId,
    required int tutorId,
    required String dateTime,
    required String universityName,
    required String courseName,
  }) async {
    _cost = cost;
    _courseId = courseId;
    _tutorId = tutorId;
    _dateTime = dateTime;
    _universityName = universityName;
    _courseName = courseName;

    await _sessionBox.put(HiveKeys.cost, cost);
    await _sessionBox.put(HiveKeys.courseId, courseId);
    await _sessionBox.put(HiveKeys.tutorId, tutorId);
    await _sessionBox.put(HiveKeys.dateTime, dateTime);
    await _sessionBox.put(HiveKeys.universityTutoringSession, universityName);
    await _sessionBox.put(HiveKeys.courseName, courseName);

    notifyListeners();
  }

  Future<void> clearSessionProgress() async {
    await _sessionBox.clear();
    _cost = null;
    _courseId = null;
    _tutorId = null;
    _dateTime = null;
    _universityName = null;
    _courseName = null;
    notifyListeners();
  }

  Future<void> submitTutoringSession() async {
    if (_submissionState == TutoringSessionSubmissionState.submitting ||
        _submissionState == TutoringSessionSubmissionState.queuedOffline) {
      return;
    }

    if (_cost == null || _courseId == null || _tutorId == null || _dateTime == null) {
      _submissionError = "Missing essential session information.";
      _submissionState = TutoringSessionSubmissionState.error;
      notifyListeners();
      return;
    }

    _submissionState = TutoringSessionSubmissionState.submitting;
    _submissionError = null;
    notifyListeners();

    try {
      await _sessionService.createTutoringSession(
        cost: _cost!,
        dateTime: _dateTime!,
        courseId: _courseId!,
        tutorId: _tutorId!,
      );

      _submissionState = TutoringSessionSubmissionState.success;
      await clearSessionProgress();
    } on SocketException {
      _submissionError = "No internet connection. Session queued.";
      _submissionState = TutoringSessionSubmissionState.queuedOffline;

      final sessionData = {
        'cost': _cost,
        'courseId': _courseId,
        'tutorId': _tutorId,
        'dateTime': _dateTime,
        'university': _universityName,
        'courseName': _courseName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _localCacheService.cachePendingRegistration(sessionData);
    } catch (e) {
      _submissionError = "Error: ${e.toString()}";
      _submissionState = TutoringSessionSubmissionState.error;
    } finally {
      notifyListeners();
    }
  }

  void setBackgroundSyncSuccess() {
    if (_submissionState == TutoringSessionSubmissionState.queuedOffline ||
        _submissionState == TutoringSessionSubmissionState.submitting) {
      _submissionState = TutoringSessionSubmissionState.success;
      _submissionError = null;
      clearSessionProgress();
      notifyListeners();
    }
  }

  void setBackgroundSyncError(String error) {
    _submissionState = TutoringSessionSubmissionState.error;
    _submissionError = error;
    notifyListeners();
  }

  void reset() {
    _cost = null;
    _courseId = null;
    _tutorId = null;
    _dateTime = null;
    _universityName = null;
    _courseName = null;
    _submissionState = TutoringSessionSubmissionState.idle;
    _submissionError = null;
    notifyListeners();
  }

  bool get hasSavedProgress => _sessionBox.isNotEmpty;
}
