import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum LoginState { initial, loading, successStudent, successTutor, error }

class LoginController with ChangeNotifier {
  final AuthService _authService;
  final AuthProvider _authProvider;

  LoginState _state = LoginState.initial;
  LoginState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  LoginController(
      {required AuthService authService, required AuthProvider authProvider})
      : _authService = authService,
        _authProvider = authProvider;

  Future<void> login(String email, String password) async {
    if (_state == LoginState.loading) return;

    _state = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final Map<String, dynamic> userData = await _authService.loginUser(
        email.trim(),
        password.trim(),
      );

      final User loggedInUser = User();
      loggedInUser.fromLoginJson(userData);

      _authProvider.loginSuccess(loggedInUser);

      final String? role = loggedInUser.role;

      if (role == "student") {
        _state = LoginState.successStudent;
      } else if (role == "tutor") {
        _state = LoginState.successTutor;
      } else {
        throw Exception(
            "Login successful, but user role ('$role') is invalid.");
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoginState.error;
    } finally {
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == LoginState.successStudent ||
        _state == LoginState.successTutor) {
      _state = LoginState.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
