import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/sign_in_process_provider.dart';

enum SignInState {
  initial, // Default state
  validating, // When validation is in progress (though it's synchronous here)
  validationSuccessStudent, // Validation passed, navigate to Student sign in
  validationSuccessTutor, // Validation passed, navigate to Tutor sign in
  validationError // Validation failed
}

class SignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;

  SignInController(this._signInProcessProvider);

  SignInState _state = SignInState.initial;
  SignInState get state => _state;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  String? _validatedEmail;
  String? get validatedEmail => _validatedEmail;

  String? _validatedPassword;
  String? get validatedPassword => _validatedPassword;

  void validateAndProceed(
      String email, String password, String confirmPassword, String role) {
    _state = SignInState.validating;
    _emailError = null;
    _passwordError = null;

    bool isValid = true;
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _emailError = 'Enter a valid email';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    } else if (password != confirmPassword) {
      _passwordError = 'Passwords do not match';
      isValid = false;
    }

    if (isValid) {
      _validatedEmail = email;
      _validatedPassword = password;

      if (role == "student") {
        _state = SignInState.validationSuccessStudent;
        _signInProcessProvider.setCredentialsAndRole(
            _validatedEmail!, _validatedPassword!, role);
      } else if (role == "tutor") {
        _state = SignInState.validationSuccessTutor;
        _signInProcessProvider.setCredentialsAndRole(
            _validatedEmail!, _validatedPassword!, role);
      } else {
        _state = SignInState.validationError;
        _passwordError = "Invalid role selected.";
      }
    } else {
      _state = SignInState.validationError;
    }
    notifyListeners();
  }

  void resetStateAfterNavigation() {
    if (_state == SignInState.validationSuccessStudent ||
        _state == SignInState.validationSuccessTutor) {
      _state = SignInState.initial;
      _emailError = null;
      _passwordError = null;
      _validatedEmail = null;
      _validatedPassword = null;
      notifyListeners();
    }
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    if (_state == SignInState.validationError) {
      _state = SignInState.initial;
    }
    notifyListeners();
  }
}
