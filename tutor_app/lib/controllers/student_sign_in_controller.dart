import 'package:flutter/foundation.dart';
import '../providers/sign_in_process_provider.dart';
import '../services/universities_service.dart';
import '../services/majors_service.dart';

enum StudentSignInState {
  initial,
  loading,
  success,
  error,
}

class StudentSignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;
  final UniversitiesService _universitiesService;
  final MajorsService _majorsService;

  StudentSignInController(this._signInProcessProvider,
      this._universitiesService, this._majorsService) {
    _loadUniversities();
    _loadMajors();
  }
  List<String> _universities = [];
  List<String> get universities => _universities;

  String? _selectedUniversity;
  String? get selectedUniversity => _selectedUniversity;

  bool _isLoadingUniversities = false;
  bool get isLoadingUniversities => _isLoadingUniversities;

  String? _universityApiError;
  String? get universityApiError => _universityApiError;

  List<String> _majors = [];
  List<String> get majors => _majors;

  String? _selectedMajor;
  String? get selectedMajor => _selectedMajor;

  bool _isLoadingMajors = false;
  bool get isLoadingMajors => _isLoadingMajors;

  String? _majorApiError;
  String? get majorApiError => _majorApiError;

  StudentSignInState _state = StudentSignInState.initial;
  StudentSignInState get state => _state;

  String? _nameError;
  String? get nameError => _nameError;

  String? _phoneError;
  String? get phoneError => _phoneError;

  String? _universityError;
  String? get universityError => _universityError;

  String? _majorError;
  String? get majorError => _majorError;

  String? _generalError;
  String? get generalError => _generalError;

  Future<void> _loadUniversities() async {
    _isLoadingUniversities = true;
    _universityApiError = null;
    notifyListeners();
    try {
      _universities = await _universitiesService.fetchUniversities();
    } catch (e) {
      _universityApiError = "Could not load universities: ${e.toString()}";
      debugPrint(_universityApiError);
    } finally {
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  void selectUniversity(String? value) {
    if (_selectedUniversity != value) {
      _selectedUniversity = value;
      _universityError = null; // Clear validation error on change
      notifyListeners();
    }
  }

  Future<void> _loadMajors() async {
    _isLoadingMajors = true;
    _majorApiError = null;
    notifyListeners();
    try {
      _majors = await _majorsService.fetchMajors();
    } catch (e) {
      _majorApiError = "Could not load majors: ${e.toString()}";
      debugPrint(_majorApiError);
    } finally {
      _isLoadingMajors = false;
      notifyListeners();
    }
  }

  void selectMajor(String? value) {
    if (_selectedMajor != value) {
      _selectedMajor = value;
      _majorError = null;
      notifyListeners();
    }
  }

  Future<void> submitStudentDetails({
    required String name,
    required String phoneNumber,
  }) async {
    _state = StudentSignInState.loading;
    _clearErrors();
    notifyListeners();

    bool isValid = true;
    if (name.trim().isEmpty) {
      _nameError = 'Name is required';
      isValid = false;
    }
    if (phoneNumber.trim().isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(phoneNumber.trim())) {
      _phoneError = 'Enter a valid phone number';
      isValid = false;
    }

    if (!isValid) {
      _state = StudentSignInState.error;
      notifyListeners();
      return;
    }

    try {
      final Map<String, String> studentData = {
        'name': name.trim(),
        'phone_number': phoneNumber.trim(),
        'university': _selectedUniversity!,
        'major': _selectedMajor!,
      };
      _signInProcessProvider.setStudentDetails(studentData);

      _state = StudentSignInState.success;
      notifyListeners();
    } catch (e) {
      _generalError = "Failed to save details: ${e.toString()}";
      _state = StudentSignInState.error;
      notifyListeners();
    }
  }

  void _clearErrors() {
    _nameError = null;
    _phoneError = null;
    _universityError = null;
    _majorError = null;
    _generalError = null;
  }

  void clearInputErrors() {
    if (_state == StudentSignInState.error) {
      _clearErrors();
      _state = StudentSignInState.initial; // Reset state if needed
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == StudentSignInState.success) {
      _state = StudentSignInState.initial;
      _clearErrors();
      notifyListeners();
    }
  }
}
