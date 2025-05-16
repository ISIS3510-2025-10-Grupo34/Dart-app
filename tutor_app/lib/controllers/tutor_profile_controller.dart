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
import '../models/similar_tutor_review_model.dart';

enum SessionCreationState {
  initial,
  validating,
  validationSuccess,
  validationError,
  creating,
  success,
  error
}


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

  bool _isFetchingSimilarReviews = false;
  bool get isFetchingSimilarReviews => _isFetchingSimilarReviews;

  String? _similarReviewsError;
  String? get similarReviewsError => _similarReviewsError;

  List<SimilarTutorInfo> _similarReviews = [];
  List<SimilarTutorInfo> get similarReviews => _similarReviews;

  SessionCreationState _creationState = SessionCreationState.initial;
  SessionCreationState get creationState => _creationState;

  String? _universityValidationError;
  String? _courseValidationError;
  String? _costValidationError;
  String? _dateTimeValidationError;
  String? _creationError;

  String? get universityValidationError => _universityValidationError;
  String? get courseValidationError => _courseValidationError;
  String? get costValidationError => _costValidationError;
  String? get dateTimeValidationError => _dateTimeValidationError;
  String? get creationError => _creationError;

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

  Future<void> fetchAndShowSimilarReviews() async {
    if (_user?.id == null) {
      _similarReviewsError = "Cannot fetch reviews: Tutor ID not found.";
      notifyListeners();
      return;
    }
    if (_isFetchingSimilarReviews) return; // Prevent concurrent calls

    _isFetchingSimilarReviews = true;
    _similarReviewsError = null;
    _similarReviews = []; // Clear previous results
    notifyListeners();

    try {
      final tutorId = int.parse(_user!.id!); // Assume ID is parsable int
      final response = await _tutorService.fetchSimilarTutorReviews(tutorId);
      _similarReviews = response.similarTutorReviews;
    } catch (e) {
      _similarReviewsError = "Failed to load similar reviews: ${e.toString()}";
      debugPrint(_similarReviewsError);
    } finally {
      _isFetchingSimilarReviews = false;
      notifyListeners();
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

  Future<void> validateAndCreateSession({
    required String universityName,
    required String courseName,
    required String costText,
    required DateTime? dateTime,
  }) async {
    _creationState = SessionCreationState.validating;
    _universityValidationError = null;
    _courseValidationError = null;
    _costValidationError = null;
    _dateTimeValidationError = null;
    _creationError = null;
    notifyListeners();

    bool isValid = true;

    if (!_universities.contains(universityName)) {
      _universityValidationError = 'Select a valid university from the list.';
      isValid = false;
    }

    final courseId = getCourseIdByName(courseName);
    if (courseId == null) {
      _courseValidationError = 'Select a valid course from the list.';
      isValid = false;
    }

    final parsedCost = double.tryParse(costText);
    if (parsedCost == null || parsedCost <= 0) {
      _costValidationError = 'Enter a valid positive number.';
      isValid = false;
    }

    if (dateTime == null || dateTime.isBefore(DateTime.now())) {
      _dateTimeValidationError = 'Choose a valid future date and time.';
      isValid = false;
    }

    if (!isValid) {
      _creationState = SessionCreationState.validationError;
      notifyListeners();
      return;
    }

    try {
      _creationState = SessionCreationState.creating;
      notifyListeners();

      final tutorId = int.tryParse(_user?.id ?? '');
      if (tutorId == null) throw Exception("No valid tutor ID.");

      await _sessionService.createTutoringSession(
        cost: parsedCost!.toInt(),
        dateTime: dateTime!.toIso8601String(),
        courseId: courseId!,
        tutorId: tutorId,
      );

      _creationState = SessionCreationState.success;
    } catch (e) {
      _creationError = e.toString();
      _creationState = SessionCreationState.error;
    } finally {
      notifyListeners();
    }
  }

  void resetSessionCreationState() {
    _creationState = SessionCreationState.initial;
    _universityValidationError = null;
    _courseValidationError = null;
    _costValidationError = null;
    _dateTimeValidationError = null;
    _creationError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_updateStateFromAuthProvider);
    super.dispose();
  }
}
