import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class StudentProfileController with ChangeNotifier {
  final AuthProvider _authProvider;
  final UserService _userService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StudentProfileController(
      {required AuthProvider authProvider, required UserService userService})
      : _authProvider = authProvider,
        _userService = userService {
    _updateStateFromAuthProvider();
    _authProvider.addListener(_updateStateFromAuthProvider);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _updateStateFromAuthProvider() {
    bool needsNotify = false;

    if (_user != _authProvider.currentUser) {
      //
      _user = _authProvider.currentUser; //
      needsNotify = true;
    }
    if (_isLoading != _authProvider.profileIsLoading) {
      //
      _isLoading = _authProvider.profileIsLoading; //
      needsNotify = true;
    }
    if (_errorMessage != _authProvider.profileError) {
      //
      _errorMessage = _authProvider.profileError; //
      needsNotify = true;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (e) {
      debugPrint("Error during logout via controller: $e");
      rethrow;
    } finally {}
  }

  @override
  void dispose() {
    _authProvider.removeListener(_updateStateFromAuthProvider);
    super.dispose();
  }
}
