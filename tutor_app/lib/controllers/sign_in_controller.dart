import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/providers/sign_in_process_provider.dart';
import 'package:tutor_app/services/auth_service.dart';
import 'package:tutor_app/utils/env_config.dart';

enum SignInState {
  initial,
  validating,
  validationSuccessStudent,
  validationSuccessTutor,
  validationError
}

class SignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;
  final AuthService _authService;
  SignInController(this._signInProcessProvider, this._authService);

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

  DateTime? _startTime;

  void startTimingFromWelcome() {
    _startTime = DateTime.now();
  }

  Future<void> _sendTimeIfNeeded(String email) async {
    if (_startTime == null) return;

    final duration = DateTime.now().difference(_startTime!);
    final timeInSeconds = duration.inMilliseconds / 1000;

    final url = Uri.parse('${EnvConfig.apiUrl}/api/profile-creation-time/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "time": timeInSeconds,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to send time: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error sending profile creation time: $e");
    }
  }

  Future<void> validateAndProceed(String email, String password,
      String confirmPassword, String role) async {
    _state = SignInState.validating;
    _emailError = null;
    _passwordError = null;
    notifyListeners();

    bool isFormatValid = true;

    if (email.isEmpty) {
      _emailError = 'Email is required';
      isFormatValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _emailError = 'Enter a valid email';
      isFormatValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isFormatValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isFormatValid = false;
    } else if (password != confirmPassword) {
      _passwordError = 'Passwords do not match';
      isFormatValid = false;
    }

    if (!isFormatValid) {
      _state = SignInState.validationError;
      notifyListeners();
      return;
    }

    try {
      bool emailExists = await _authService.checkEmailExists(email);
      if (emailExists) {
        _emailError = 'This email is already registered.';
        _state = SignInState.validationError;
        notifyListeners();
        return;
      }

      _validatedEmail = email;
      _validatedPassword = password;

      if (role == "student") {
        _state = SignInState.validationSuccessStudent;
        _signInProcessProvider.setCredentialsAndRole(email, password, role);
      } else if (role == "tutor") {
        _state = SignInState.validationSuccessTutor;
        _signInProcessProvider.setCredentialsAndRole(email, password, role);
      } else {
        _state = SignInState.validationError;
        _passwordError = "Invalid role selected.";
      }

      // Enviar tiempo si todo fue exitoso
      if (_state == SignInState.validationSuccessStudent ||
          _state == SignInState.validationSuccessTutor) {
        await _sendTimeIfNeeded(email);
      }
    } catch (e) {
      _emailError = e.toString();
      _state = SignInState.validationError;
    } finally {
      if (_state == SignInState.validating) {
        _state = SignInState.validationError;
        _emailError ??= "An unexpected error occurred during validation.";
      }
      notifyListeners();
    }
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
