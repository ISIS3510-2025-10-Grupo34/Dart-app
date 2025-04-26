import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/auth_provider.dart'; 
import 'package:tutor_app/services/metrics_service.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutoring_session_model.dart';
import '../services/tutor_service.dart';
import '../services/tutoring_session_service.dart'; 

enum StudentHomeState { initial, loading, loadingNextPage, loaded, error } 

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
        _metricsService = metricsService {
        loadOrderedSessions(loadFirstPage: true);
        }

  StudentHomeState _state = StudentHomeState.initial;
  StudentHomeState get state => _state;

  List<TutorListItemModel> _tutors = [];
  List<TutorListItemModel> get tutors => _tutors;

  List<TutoringSession> _sessions = [];
  List<TutoringSession> get sessions => _sessions;

  List<TutoringSession> _displayedSessions = [];

  int _currentPage = 1;
  bool _hasMorePages = true; 
  bool _isLoadingPage = false; 
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasMorePages => _hasMorePages;

  StudentHomeNavigationTarget _navigationTarget =
      StudentHomeNavigationTarget.none;
  StudentHomeNavigationTarget get navigationTarget => _navigationTarget;

  String _activeUniversityFilter = '';
  String _activeCourseFilter = '';
  String _activeTutorFilter = '';

  bool get isFilterActive =>
      _activeUniversityFilter.isNotEmpty ||
      _activeCourseFilter.isNotEmpty ||
      _activeTutorFilter.isNotEmpty;

  void _applyFilters() {
    List<TutoringSession> filtered = List.from(_sessions);

    if (_activeUniversityFilter.isNotEmpty) {
      filtered = filtered.where((session) =>
          session.university.toLowerCase().contains(_activeUniversityFilter.toLowerCase())
      ).toList();
    }
    if (_activeCourseFilter.isNotEmpty) {
      filtered = filtered.where((session) =>
          session.course.toLowerCase().contains(_activeCourseFilter.toLowerCase())
      ).toList();
    }
    if (_activeTutorFilter.isNotEmpty) {
      filtered = filtered.where((session) =>
          session.tutorName.toLowerCase().contains(_activeTutorFilter.toLowerCase())
      ).toList();
    }

    _displayedSessions = filtered;
  }

  Future<void> loadOrderedSessions({bool loadFirstPage = false}) async {
    if (_isLoadingPage || (!_hasMorePages && !loadFirstPage)) return;

    _isLoadingPage = true;
    _errorMessage = null;
    StudentHomeState previousState = _state; 

    if (loadFirstPage) {
      _state = StudentHomeState.loading;
      _currentPage = 1;
      _hasMorePages = true;
      _sessions = []; 
      _displayedSessions = []; 
      _activeUniversityFilter = '';
      _activeCourseFilter = '';
      _activeTutorFilter = '';
    } else {
      _state = StudentHomeState.loadingNextPage;
    }
    notifyListeners();

    try {
      final SessionFetchResult result = await _sessionService.fetchOrderedSessions(_currentPage);

      _sessions.addAll(result.sessions);
      _applyFilters(); 

      const int sessionsPerPage = 10;
      if (result.sessions.length < sessionsPerPage) {
        _hasMorePages = false;
      }

      _currentPage++;
      _state = StudentHomeState.loaded;


    } catch (e) {
      _errorMessage = "Failed to load sessions: ${e.toString()}";
      _state = StudentHomeState.error;
      if (!loadFirstPage) {
           _state = previousState; 
      }
    } finally {
      _isLoadingPage = false;
      notifyListeners();
    }
  }
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

  void applyFiltersAndUpdate(String university, String course, String tutor) {
     _activeUniversityFilter = university;
     _activeCourseFilter = course;
     _activeTutorFilter = tutor;
     _applyFilters(); 
     notifyListeners(); 
  }

  void clearFiltersAndUpdate() {
     _activeUniversityFilter = '';
     _activeCourseFilter = '';
     _activeTutorFilter = '';
     _applyFilters(); 
     notifyListeners(); 
  }

  Future<void> clearFiltersAndReload() async {
    await loadOrderedSessions(loadFirstPage: true);
  }


  Future<void> sendTimeToBookMetric(int milliseconds) async {
     try {
       await _metricsService.sendTimeToBook(milliseconds);
     } catch (e) {
       if (kDebugMode) { print("Failed to send time to book metric: $e"); }
     }
   }

   Future<void> sendTutorProfileLoadTime(int milliseconds) async {
     try {
       await _metricsService.sendTutorProfileLoadTime(milliseconds);
     } catch (e) {
       if (kDebugMode) { print("Failed to send profile load time metric: $e");}
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
      _state = StudentHomeState.error; // Or handle differently
    }
    notifyListeners();
  }

  void resetNavigationState() {
    _navigationTarget = StudentHomeNavigationTarget.none;

  }
}