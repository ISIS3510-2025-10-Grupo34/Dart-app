import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/services/metrics_service.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutoring_session_model.dart';
import '../services/tutor_service.dart';
import '../services/tutoring_session_service.dart';

enum StudentHomeState { initial, loading, loaded, error }

enum StudentHomeNavigationTarget { none, profile, review, booking }

class StudentHomeController with ChangeNotifier {
  final TutorService _tutorService;
  final AuthProvider _authProvider;
  final TutoringSessionService _sessionService;
  final MetricsService _metricsService;  

  StudentHomeController({
    required TutorService tutorService,
    required AuthProvider authProvider,
    required TutoringSessionService sessionService,
    required MetricsService metricsService,  
  })  : _tutorService = tutorService,
        _authProvider = authProvider,
        _sessionService = sessionService,
        _metricsService = metricsService;  

  StudentHomeState _state = StudentHomeState.initial;
  StudentHomeState get state => _state;

  List<TutorListItemModel> _tutors = [];
  List<TutorListItemModel> get tutors => _tutors;

  List<TutoringSession> _sessions = [];
  List<TutoringSession> get sessions => _sessions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentHomeNavigationTarget _navigationTarget =
      StudentHomeNavigationTarget.none;
  StudentHomeNavigationTarget get navigationTarget => _navigationTarget;

  Future<void> loadTutors() async {
    if (_state == StudentHomeState.loading) return;

    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tutors = await _tutorService.fetchTutors();
      _tutors.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadTutoringSessions() async {
    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _sessions = await _sessionService.fetchTutoringSessions();
      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadAvailableTutoringSessions() async {
    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _sessions = await _sessionService.fetchAvailableTutoringSessions();
      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendTimeToBookMetric(int milliseconds) async {
    try {
      await _metricsService.sendTimeToBook(milliseconds); 
    } catch (e) {
      if (kDebugMode) {
        print(' Error sending time-to-book: $e');
      }
    }
  }

  Future<void> sendTutorProfileLoadTime(int milliseconds) async {
    try {
      await _metricsService.sendTutorProfileLoadTime(milliseconds);  
    } catch (e) {
      if (kDebugMode) {
        print(' Error sending profile load time: $e');
      }
    }
  }

  void navigateToStudentProfile() {
    _navigationTarget = StudentHomeNavigationTarget.none;
    _errorMessage = null;

    final String? studentId = _authProvider.currentUser?.id;

    if (studentId != null && studentId.isNotEmpty) {
      _navigationTarget = StudentHomeNavigationTarget.profile;
    } else {
      _errorMessage = "Error: Student profile ID not found.";
      _state = StudentHomeState.error;
    }
    notifyListeners();
  }

  void resetNavigationState() {
    _navigationTarget = StudentHomeNavigationTarget.none;
  }
}
