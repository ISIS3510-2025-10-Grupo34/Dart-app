import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final UserService _userService;

  User? _currentUser;
  AuthState _authState = AuthState.unknown;
  bool _profileIsLoading = false;
  String? _profileError;

  AuthProvider({required UserService userService}) : _userService = userService;

  User? get currentUser => _currentUser;
  AuthState get authState => _authState;
  bool get profileIsLoading => _profileIsLoading;
  String? get profileError => _profileError;

  Future<void> loginSuccess(User minimalUser) async {
    _currentUser = minimalUser;
    _authState = AuthState.authenticated;
    _profileIsLoading = false;
    _profileError = null;
    notifyListeners();

    if (_currentUser?.id != null && _currentUser?.role != null) {
      await _fetchFullProfile(_currentUser!.id!, _currentUser!.role!);
    } else {
      _profileError =
          "Login partially successful, but failed to get user details.";
      notifyListeners();
    }
  }

  Future<void> _fetchFullProfile(String userId, String userRole) async {
    if (_profileIsLoading) return;

    _profileIsLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      Map<String, dynamic>? fullUserInfo;

      if (userRole == 'student') {
        fullUserInfo = await _userService.fetchStudentProfile(userId);
        _currentUser?.fromJsonStudent(fullUserInfo!);
      } else if (userRole == 'tutor') {
        fullUserInfo = await _userService.fetchStudentProfile(userId);
        _currentUser?.fromJsonTutor(fullUserInfo!);
      } else {
        throw Exception("Unknown user role for profile fetch: $userRole");
      }
      _profileError = null;
    } catch (e) {
      _profileError = e.toString();
    } finally {
      _profileIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUserProfile() async {
    if (_currentUser?.id != null && _currentUser?.role != null) {
      await _fetchFullProfile(_currentUser!.id!, _currentUser!.role!);
    } else {
      return;
    }
  }
}
