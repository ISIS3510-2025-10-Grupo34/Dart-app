import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/services/metrics_service.dart';
import 'package:tutor_app/utils/network_utils.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutoring_session_model.dart';
import '../services/tutor_service.dart';
import '../services/tutoring_session_service.dart';
import '../services/universities_service.dart';
import '../services/course_service.dart';

enum StudentHomeState { initial, loading, loaded, error }

enum StudentHomeNavigationTarget { none, profile, review, booking }

class StudentHomeController with ChangeNotifier {
  final TutorService _tutorService;
  final AuthProvider _authProvider;
  final TutoringSessionService _sessionService;
  final MetricsService _metricsService;
  final UniversitiesService _universitiesService = UniversitiesService();
  final CourseService _coursesService = CourseService();

  StudentHomeController({
    required TutorService tutorService,
    required AuthProvider authProvider,
    required TutoringSessionService sessionService,
    required MetricsService metricsService,
  })  : _tutorService = tutorService,
        _authProvider = authProvider,
        _sessionService = sessionService,
        _metricsService = metricsService {
    loadOrderedSessions();
  }

  StudentHomeState _state = StudentHomeState.initial;
  StudentHomeState get state => _state;

  List<TutorListItemModel> _tutors = [];
  List<TutorListItemModel> get tutors => _tutors;

  List<TutoringSession> _sessions = [];
  List<TutoringSession> get sessions => _sessions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentHomeNavigationTarget _navigationTarget = StudentHomeNavigationTarget.none;
  StudentHomeNavigationTarget get navigationTarget => _navigationTarget;

  String _activeUniversityFilter = '';
  String _activeCourseFilter = '';
  String _activeTutorFilter = '';

  bool get isFilterActive =>
      _activeUniversityFilter.isNotEmpty ||
      _activeCourseFilter.isNotEmpty ||
      _activeTutorFilter.isNotEmpty;

  List<String> _universities = [];
  List<String> get universities => _universities;

  List<String> _courses = [];
  List<String> get courses => _courses;

  void _applyFilters() {
    List<TutoringSession> filtered = List.from(_sessions);

    if (_activeUniversityFilter.isNotEmpty) {
      filtered = filtered
          .where((session) => session.university
              .toLowerCase()
              .contains(_activeUniversityFilter.toLowerCase()))
          .toList();
    }
    if (_activeCourseFilter.isNotEmpty) {
      filtered = filtered
          .where((session) => session.course
              .toLowerCase()
              .contains(_activeCourseFilter.toLowerCase()))
          .toList();
    }
    if (_activeTutorFilter.isNotEmpty) {
      filtered = filtered
          .where((session) => session.tutorName
              .toLowerCase()
              .contains(_activeTutorFilter.toLowerCase()))
          .toList();
    }

    _sessions = filtered;
  }

  Future<void> loadOrderedSessions() async {
    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasInternet = await NetworkUtils.hasInternetConnection();
      if (!hasInternet) {
        throw Exception("Unable to load tutoring sessions. No internet connection.");
      }

      final fetchedSessions = await _sessionService.fetchTutoringSessionsInOrder();
      _sessions = fetchedSessions;
      _applyFilters();
      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadUniversitiesAndCourses(String universityName) async {
    try {
      _universities = await _universitiesService.fetchUniversities();
      _courses = await _coursesService.fetchCourses(universityName);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
      notifyListeners();
    }
  }

  Future<void> loadTutors() async {
    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawTutors = await _tutorService.fetchTutors(); 
      _tutors = rawTutors
          .map((json) => TutorListItemModel.fromJson(json))
          .toList();

      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadCoursesForUniversity(String universityName) async {
    try {
      _courses = (await _coursesService.fetchCoursesByUniversity(universityName)).cast<String>();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load courses: $e");
    }
  }

  void applyFiltersAndUpdate(String university, String course, String tutor) {
    _activeUniversityFilter = university;
    _activeCourseFilter = course;
    _activeTutorFilter = tutor;
    _applyFilters();
    notifyListeners();
  }

  Future<void> clearFiltersAndUpdate() async {
    _activeUniversityFilter = '';
    _activeCourseFilter = '';
    _activeTutorFilter = '';
    await loadOrderedSessions();
  }

  Future<void> sendTimeToBookMetric(int milliseconds) async {
    try {
      await _metricsService.sendTimeToBook(milliseconds);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send time to book metric: $e");
      }
    }
  }

  Future<void> sendTutorProfileLoadTime(int milliseconds) async {
    try {
      await _metricsService.sendTutorProfileLoadTime(milliseconds);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send profile load time metric: $e");
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