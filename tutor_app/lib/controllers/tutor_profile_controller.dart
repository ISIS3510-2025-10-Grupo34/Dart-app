import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../services/user_service.dart';
import '../services/tutoring_session_service.dart'; 

class TutorProfileController with ChangeNotifier {
  final AuthProvider _authProvider;
  final UserService _userService;
  final TutoringSessionService _sessionService; 

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  TutorProfileController({
    required AuthProvider authProvider,
    required UserService userService,
    required TutoringSessionService sessionService, 
  })  : _authProvider = authProvider,
        _userService = userService,
        _sessionService = sessionService {
    _updateStateFromAuthProvider();
    _authProvider.addListener(_updateStateFromAuthProvider);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  @override
  void dispose() {
    _authProvider.removeListener(_updateStateFromAuthProvider);
    super.dispose();
  }
}
