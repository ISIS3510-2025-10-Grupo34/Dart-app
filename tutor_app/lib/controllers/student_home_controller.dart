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
import 'package:lru/lru.dart';

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
    checkInternetStatus();
    loadInitialSessions();
  }

  StudentHomeState _state = StudentHomeState.initial;
  StudentHomeState get state => _state;

  List<TutoringSession> _sessions = [];
  List<TutoringSession> get sessions => _sessions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentHomeNavigationTarget _navigationTarget = StudentHomeNavigationTarget.none;
  StudentHomeNavigationTarget get navigationTarget => _navigationTarget;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _universityFilter;
  String? _courseFilter;
  String? _tutorNameFilter;

  String? get universityFilter => _universityFilter;
  String? get courseFilter => _courseFilter;
  String? get tutorNameFilter => _tutorNameFilter;

  bool _hasNextPage = true;
  bool get hasNextPage => _hasNextPage;

  final LruCache<int, List<TutoringSession>> _pageCache = LruCache(2);
  int? _lastPageCached;

  // --- Universities ---
  List<String> _universities = [];
  List<String> get universities => _universities;
  bool _isLoadingUniversities = false;
  bool get isLoadingUniversities => _isLoadingUniversities;

  String? _universityApiError;
  String? get universityApiError => _universityApiError;

  // --- Courses ---
  List<String> _courses = [];
  List<String> get courses => _courses;

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;

  String? _courseApiError;
  String? get courseApiError => _courseApiError;

  // --- Tutors ---
  List<String> _tutors = [];
  List<String> get tutors => _tutors;

  bool _isLoadingTutors = false;
  bool get isLoadingTutors => _isLoadingTutors;

  String? _tutorApiError;
  String? get tutorApiError => _tutorApiError;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  bool hasPageInCache(int page) => _pageCache.containsKey(page);

  Future<void> checkInternetStatus() async {
    _hasInternet = await NetworkUtils.hasInternetConnection();
    notifyListeners();
  }

  /// Inicializa o recarga la página 1
  Future<void> loadInitialSessions({
    String? university,
    String? course,
    String? tutorName,
  }) async {
    _currentPage = 1;
    _universityFilter = university;
    _courseFilter = course;
    _tutorNameFilter = tutorName;
    await _loadSessions();
  }

  /// Carga la siguiente página (si hay más)
  Future<void> loadNextPage() async {
    if (_hasNextPage) {
      _currentPage += 1;
      await _loadSessions();
    }
  }

  Future<void> reloadCurrentPage() async {
    await _loadSessions();
  }

  /// Carga la página anterior (manteniendo filtros actuales)
  Future<void> loadPreviousPage() async {
    if (_currentPage > 1) {
      _currentPage -= 1;
      await _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    _isLoading = true;
    _errorMessage = null;
    await checkInternetStatus();
    notifyListeners();

    // Verificar si ya tenemos la página cacheada
    final cachedSessions = _pageCache[_currentPage];
    if (cachedSessions != null) {
      _sessions = cachedSessions;
      _hasNextPage = cachedSessions.isNotEmpty;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final fetchedSessions = await _sessionService.fetchPaginatedSessions(
        page: _currentPage,
        universityFilter: _universityFilter,
        courseFilter: _courseFilter,
        tutorNameFilter: _tutorNameFilter,
      );

      _sessions = fetchedSessions;
      _hasNextPage = fetchedSessions.isNotEmpty;

      // Guardar en cache
      _pageCache[_currentPage] = fetchedSessions;
      _lastPageCached = _currentPage;

    } catch (e) {
      _errorMessage = e.toString();
      _sessions = [];
      _hasNextPage = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPageCache() {
    _pageCache.clear();
  }

  Future<void> clearFiltersAndReload() async {
    _universityFilter = null;
    _courseFilter = null;
    _tutorNameFilter = null;
    clearPageCache();
    await loadInitialSessions(); // también debe ser Future
  }


  Future<void> loadUniversities() async {
    _isLoadingUniversities = true;
    _universityApiError = null;
    notifyListeners();

    try {
      _universities = await _universitiesService.fetchUniversities();
      if (_universities.isEmpty) {
        _universityApiError = "No universities found.";
      }
    } catch (e) {
      _universityApiError = "Failed to load universities: ${e.toString()}";
      debugPrint(_universityApiError);
    } finally {
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  Future<void> loadTutors() async {
    _isLoadingTutors = true;
    _tutorApiError = null;
    notifyListeners();

    try {
      _tutors = await _tutorService.fetchTutorNames();
      if (_tutors.isEmpty) {
        _tutorApiError = "No tutors found.";
      }
    } catch (e) {
      _tutorApiError = "Failed to load tutors: ${e.toString()}";
      debugPrint(_tutorApiError);
    } finally {
      _isLoadingTutors = false;
      notifyListeners();
    }
  }

  Future<void> loadCoursesForUniversity(String universityName) async {
    _isLoadingCourses = true;
    _courseApiError = null;
    notifyListeners();

    try {
      _courses = await _coursesService.fetchCourses(universityName);
    } catch (e) {
      _courseApiError = "Failed to load courses: ${e.toString()}";
      debugPrint(_courseApiError);
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    required String university,
    required String course,
    required String tutorName,
  }) async {
    _universityFilter = university;
    _courseFilter = course;
    _tutorNameFilter = tutorName;
    _currentPage = 1; 
    clearPageCache();
    await _loadSessions();
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