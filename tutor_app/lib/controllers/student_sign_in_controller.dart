import 'package:flutter/foundation.dart';
import '../providers/sign_in_process_provider.dart';

enum StudentSignInState {
  initial,
  loading,
  success,
  error,
}

class StudentSignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;

  StudentSignInController(this._signInProcessProvider);

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

  Future<void> submitStudentDetails({
    required String name,
    required String phoneNumber,
    required String university,
    required String major,
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
    if (university.trim().isEmpty) {
      _universityError = 'University is required';
      isValid = false;
    }
    if (major.trim().isEmpty) {
      _majorError = 'Major is required';
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
        'university': university.trim(),
        'major': major.trim(),
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
