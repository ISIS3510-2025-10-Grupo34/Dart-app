import 'package:flutter/foundation.dart';
import '../models/tutoring_session_model.dart';
import '../services/student_tutoring_sessions_service.dart';
import '../providers/auth_provider.dart';

class StudentTutoringSessionsController with ChangeNotifier {
  final AuthProvider _authProvider;
  final StudentTutoringSessionsService _sessionService;

  List<TutoringSession> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  StudentTutoringSessionsController({
    required StudentTutoringSessionsService studentTutoringSessionsService,
    required AuthProvider authProvider,
  })  : _sessionService = studentTutoringSessionsService,
        _authProvider = authProvider;

  List<TutoringSession> get sessions => _sessions;
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
      _sessions = await _sessionService.fetchStudentSessions(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      _sessions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
