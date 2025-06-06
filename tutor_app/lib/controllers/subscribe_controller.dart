import 'package:flutter/foundation.dart';   
import '../services/universities_service.dart'; 
import '../services/course_service.dart';       
import '../services/subscription_service.dart'; 
import '../providers/auth_provider.dart'; 
import '../providers/subscribe_process_provider.dart';   

enum SubscribeCourseState {
  initial,
  subscribing,
  success,
  error,
}

class SubscribeCourseController with ChangeNotifier {
  final AuthProvider _authProvider;
  final UniversitiesService _universitiesService;
  final CourseService _courseService;
  final SubscriptionService _subscriptionService;
  final SubscribeProgressProvider _subscribeProgressProvider;

  SubscribeCourseController(
    this._authProvider,
    this._universitiesService,
    this._courseService,
    this._subscriptionService,
    this._subscribeProgressProvider,
  ) {
    _initController();
  }

  Future<void> _initController() async {
    await _subscribeProgressProvider.init();
    await loadUniversities();

    _selectedUniversity = _subscribeProgressProvider.savedUniversity;
    _selectedCourse = _subscribeProgressProvider.savedCourse;

    if (_selectedUniversity != null) {
      _loadCourses(_selectedUniversity!);
    }

    notifyListeners();
  }

  SubscribeCourseState _state = SubscribeCourseState.initial;
  SubscribeCourseState get state => _state;

  // --- Universities ---
  List<String> _universities = [];
  List<String> get universities => _universities;

  String? _selectedUniversity;
  String? get selectedUniversity => _selectedUniversity;

  bool _isLoadingUniversities = false;
  bool get isLoadingUniversities => _isLoadingUniversities;

  String? _universityApiError;
  String? get universityApiError => _universityApiError;

  String? _universitySelectionError;
  String? get universitySelectionError => _universitySelectionError;

  // --- Courses ---
  List<String> _courses = [];
  List<String> get courses => _courses;

  String? _selectedCourse;
  String? get selectedCourse => _selectedCourse;

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;

  String? _courseApiError;
  String? get courseApiError => _courseApiError;

  String? _courseSelectionError;
  String? get courseSelectionError => _courseSelectionError;

  // --- Subscription ---
  bool _isSubscribing = false;
  bool get isSubscribing => _isSubscribing;

  String? _subscriptionError;
  String? get subscriptionError => _subscriptionError;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _courseRatingMessage;
  String? get courseRatingMessage => _courseRatingMessage;

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

  Future<void> _loadCourses(String universitiy) async {
    _isLoadingCourses = true;
    _courseApiError = null;
    notifyListeners();

    try {
      _courses = await _courseService.fetchCourses(universitiy);
    } catch (e) {
      _courseApiError = e.toString();
      debugPrint(_courseApiError);
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  void selectUniversity(String? value) {
    if (_selectedUniversity != value) {
      _selectedUniversity = value;
      _universitySelectionError = null;
      _selectedCourse = null;
      _courses = [];
      _courseApiError = null;
      _isLoadingCourses = false;
      notifyListeners();
      if (value != null && value.isNotEmpty) {
        _subscribeProgressProvider.saveUniversity(value);
        _loadCourses(value);
      }
    }
  }

  void selectCourse(String? value) async {
    if (_selectedCourse != value) {
      _selectedCourse = value;
      _courseSelectionError = null;
      if (value != null && value.isNotEmpty && _selectedUniversity != null) {
        _subscribeProgressProvider.saveCourse(value);

        // Obtener el promedio del curso
        _courseRatingMessage = "Loading rating...";
        notifyListeners();

        final rating = await _subscriptionService.fetchCourseAverageRating(
          course: value,
          university: _selectedUniversity!,
        );
        _courseRatingMessage = rating;
      } else {
        _courseRatingMessage = null;
      }
      notifyListeners();
    }
  }


  bool _validateSelections() {
    bool isValid = true;
    if (_selectedUniversity == null) {
      _universitySelectionError = 'Please select a university.';
      isValid = false;
    }
    if (_selectedCourse == null) {
      _courseSelectionError = 'Please select a course.';
      isValid = false;
    }
    return isValid;
  }

  void _clearSubscriptionMessagesAndErrors() {
    _universitySelectionError = null;
    _courseSelectionError = null;
    _subscriptionError = null;
    _successMessage = null;
  }

  Future<void> submitSubscription() async {
    _state = SubscribeCourseState.subscribing;
    _isSubscribing = true;
    _clearSubscriptionMessagesAndErrors(); 
    notifyListeners();

    bool isValid = _validateSelections(); 
    if (!isValid) {
      _state = SubscribeCourseState.error;
      _isSubscribing = false;
      notifyListeners();
      return;
    }

    try {
      final String? studentIdInt = _authProvider.currentUser?.id;

      if (studentIdInt == null) {
        _subscriptionError = "Student information not found. Please ensure you are logged in.";
        _state = SubscribeCourseState.error;
        _isSubscribing = false;
        notifyListeners();
        return;
      }
      final String studentIdString = studentIdInt.toString();

      await _subscriptionService.subscribeToCourse(
        studentId: studentIdString,
        course: _selectedCourse!,
        university: _selectedUniversity!,
      );

      _successMessage = 'Successfully subscribed to the course!';
      _state = SubscribeCourseState.success;

    } on Exception catch (e) {
      _subscriptionError = e.toString().replaceFirst("Exception: ", "");
      _state = SubscribeCourseState.error;
      debugPrint("Subscription failed: $e");
    } catch (e) {
      _subscriptionError = "An unexpected error occurred during subscription.";
      _state = SubscribeCourseState.error;
      debugPrint("Unexpected subscription error: $e");
    } finally {
      _isSubscribing = false;
      if (SubscribeCourseState.success == _state) {
        await _subscribeProgressProvider.clearSubscriptionProgress(); 
      }
      notifyListeners();
    }
  }

  void clearAllMessagesAndErrors() {
    _universityApiError = null;
    _courseApiError = null;
    _clearSubscriptionMessagesAndErrors();
     notifyListeners();
  }

  void resetControllerState() {
    _state = SubscribeCourseState.initial;
    _selectedUniversity = null;
    _selectedCourse = null;
    _universities = []; 
    _courses = [];
    _isLoadingUniversities = false;
    _isLoadingCourses = false;
    _isSubscribing = false;
    _clearSubscriptionMessagesAndErrors();
    _universityApiError = null;
    _courseApiError = null;
    loadUniversities(); 
  }

  void resetSuccessState() {
    if (_state == SubscribeCourseState.success) {
      _state = SubscribeCourseState.initial;
      _successMessage = null;
      _selectedCourse = null;
      _selectedUniversity = null; 
      _courses = [];              
      notifyListeners();
    }
  }
}