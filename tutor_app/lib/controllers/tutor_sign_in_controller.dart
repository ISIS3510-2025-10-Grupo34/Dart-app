import 'package:flutter/foundation.dart';
import '../providers/sign_in_process_provider.dart';

enum TutorSignInState {
  initial,
  loading,
  success,
  error,
}

class TutorSignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;

  TutorSignInController(this._signInProcessProvider);

  TutorSignInState _state = TutorSignInState.initial;
  TutorSignInState get state => _state;

  String? _nameError;
  String? get nameError => _nameError;

  String? _phoneError;
  String? get phoneError => _phoneError;

  String? _universityError;
  String? get universityError => _universityError;

  String? _expertiseError;
  String? get expertiseError => _expertiseError;

  String? _generalError;
  String? get generalError => _generalError;

  Future<void> submitTutorDetails({
    required String name,
    required String phoneNumber,
    required String university,
    required String areaOfExpertise,
  }) async {
    _state = TutorSignInState.loading;
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
    if (areaOfExpertise.trim().isEmpty) {
      _expertiseError = 'Area of expertise is required';
      isValid = false;
    }

    if (!isValid) {
      _state = TutorSignInState.error;
      notifyListeners();
      return;
    }

    try {
      final Map<String, String> tutorData = {
        'name': name.trim(),
        'phone_number': phoneNumber.trim(),
        'university': university.trim(),
        'area_of_expertise': areaOfExpertise.trim(),
      };
      _signInProcessProvider.setTutorDetails(tutorData);

      _state = TutorSignInState.success;
      notifyListeners();
    } catch (e) {
      _generalError = "Failed to save details: ${e.toString()}";
      _state = TutorSignInState.error;
      notifyListeners();
    }
  }

  void _clearErrors() {
    _nameError = null;
    _phoneError = null;
    _universityError = null;
    _expertiseError = null;
    _generalError = null;
  }

  void clearInputErrors() {
    if (_state == TutorSignInState.error) {
      _clearErrors();
      _state = TutorSignInState.initial;
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == TutorSignInState.success) {
      _state = TutorSignInState.initial;
      _clearErrors();
      notifyListeners();
    }
  }
}
