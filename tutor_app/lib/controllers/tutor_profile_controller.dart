import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../services/user_service.dart';
import '../services/tutoring_session_service.dart';
import '../services/tutor_service.dart';
import '../models/time_insight.dart';
import '../services/universities_service.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';

class TutorProfileController with ChangeNotifier {
  final AuthProvider _authProvider;
  final UserService _userService;
  final TutoringSessionService _sessionService;
  final UniversitiesService _universitiesService;
  final CourseService _courseService;
  final TutorService _tutorService;

  List<Course> _courses = [];
  List<Course> get courses => _courses;

  String? _courseError;
  String? get courseError => _courseError;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  TimeToBookInsight? _timeInsight;

  List<String> _universities = [];
  List<String> get universities => _universities;

  bool _isLoadingUniversities = false;
  bool get isLoadingUniversities => _isLoadingUniversities;

  String? _universityError;
  String? get universityError => _universityError;

  TutorProfileController({
    required AuthProvider authProvider,
    required UserService userService,
    required TutoringSessionService sessionService,
    required UniversitiesService universitiesService,
    required CourseService courseService,
    required TutorService tutorService,
  })  : _authProvider = authProvider,
        _userService = userService,
        _sessionService = sessionService,
        _universitiesService = universitiesService,
        _courseService = courseService,
        _tutorService = tutorService {
    _updateStateFromAuthProvider();
    _authProvider.addListener(_updateStateFromAuthProvider);
    _loadUniversities();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TimeToBookInsight? get timeInsight => _timeInsight;

  void _updateStateFromAuthProvider() {
    bool needsNotify = false;

    if (_user != _authProvider.currentUser) {
      _user = _authProvider.currentUser;
      needsNotify = true;
    }
    if (_isLoading != _authProvider.profileIsLoading) {
      _isLoading = _authProvider.profileIsLoading;
      needsNotify = true;
    }
    if (_errorMessage != _authProvider.profileError) {
      _errorMessage = _authProvider.profileError;
      needsNotify = true;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  Future<void> fetchTimeToBookInsight() async {
    try {
      _timeInsight = await _tutorService.fetchTimeToBookInsight();
      notifyListeners();
    } catch (e) {
      _timeInsight = TimeToBookInsight(
          message: 'Time it takes a student to book with you: 15 seconds. '
              'Your average time is less than the average time to book, keep up the good work.');
      notifyListeners();
    }
  }

  Future<void> _loadUniversities() async {
    _isLoadingUniversities = true;
    notifyListeners();

    try {
      _universities = await _universitiesService.fetchUniversities();
    } catch (e) {
      _universityError = "Failed to load universities: ${e.toString()}";
    } finally {
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  Future<void> fetchCoursesForUniversity(String university) async {
    try {
      _courses = await _courseService.fetchCoursesByUniversity(university);
      _courseError = null;
    } catch (e) {
      _courseError = "Error fetching courses: $e";
      _courses = [];
    } finally {
      notifyListeners();
    }
  }

  void clearCourses() {
    _courses = [];
    notifyListeners();
  }

  List<String> get courseNames => _courses.map((c) => c.course_name).toList();

  int? getCourseIdByName(String courseName) {
    try {
      return _courses
          .firstWhere((course) => course.course_name == courseName)
          .id;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createTutoringSession({
    required int cost,
    required String dateTime,
    required int courseId,
  }) async {
    if (_user == null || _user!.id == null) {
      throw Exception("No tutor ID available");
    }

    try {
      final tutorId = int.parse(_user!.id!);
      await _sessionService.createTutoringSession(
        cost: cost,
        dateTime: dateTime,
        courseId: courseId,
        tutorId: tutorId,
      );
    } catch (e) {
      throw Exception("Failed to create session: $e");
    }
  }

  Future<int> getEstimatedPrice(String universityName) async {
    if (_user == null || _user!.id == null) {
      throw Exception("No tutor ID available for price estimation");
    }

    try {
      final tutorId = int.parse(_user!.id!);
      final estimatedPrice = await _sessionService.getEstimatedPrice(
        tutorId: tutorId,
        courseUniversityName: universityName,
      );
      return estimatedPrice;
    } catch (e) {
      throw Exception("Failed to fetch estimated price: $e");
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_updateStateFromAuthProvider);
    super.dispose();
  }
}
