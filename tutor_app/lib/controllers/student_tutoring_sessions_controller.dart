import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/tutoring_session_model.dart';
import '../services/student_tutoring_sessions_service.dart';
import '../providers/auth_provider.dart';

class StudentTutoringSessionsController with ChangeNotifier {
  final AuthProvider _authProvider;
  final StudentTutoringSessionsService _sessionService;

  List<TutoringSession> _sessions = [];
  List<TutoringSession> _sessionsToReview = [];

  bool _isLoading = false;
  String? _errorMessage;

  StudentTutoringSessionsController({
    required StudentTutoringSessionsService studentTutoringSessionsService,
    required AuthProvider authProvider,
  })  : _sessionService = studentTutoringSessionsService,
        _authProvider = authProvider;

  List<TutoringSession> get sessions => _sessions;
  List<TutoringSession> get sessionsToReview => _sessionsToReview;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudentSessions() async {
    final String? studentId = _authProvider.currentUser?.id;
    if (studentId == null) {
      _errorMessage = "Student ID not found. Cannot fetch sessions.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sessions = await _sessionService.fetchTutoringSessions();
      _sessionsToReview = await _sessionService.fetchStudentSessions(studentId);
      await _cacheSessionsToReview();
    } catch (e) {
      _errorMessage = "Error loading sessions. Showing cached data.";

      final cachedSessions = await _getCachedSessionsToReview();
      if (cachedSessions.isNotEmpty) {
        _sessionsToReview = cachedSessions;
      } else {
        _errorMessage = "No sessions available, even from cache.";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> preloadStudentSessions() async {
    final String? studentId = _authProvider.currentUser?.id;
    if (studentId == null) return;

    try {
      final sessions = await _sessionService.fetchStudentSessions(studentId);
      _sessionsToReview = sessions;
      await _cacheSessionsToReview(); 
      notifyListeners();
    } catch (e) {

      _sessionsToReview = await _getCachedSessionsToReview();
      debugPrint("📥 Preloaded sessions from cache: ${_sessionsToReview.length} sessions");
      notifyListeners();
    }
  }

  Future<void> _cacheSessionsToReview() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewData = _sessionsToReview.map((s) => s.toJsonSTS()).toList();
    await prefs.setString('cached_sessions_to_review', jsonEncode(reviewData));
  }

  Future<List<TutoringSession>> _getCachedSessionsToReview() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_sessions_to_review');

    if (jsonString == null) {
      return [];
    }

    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => TutoringSession.fromJsonSTS(e)).toList();
    } catch (e) {
      return [];
    }
  }
}