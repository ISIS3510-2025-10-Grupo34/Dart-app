import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tutor_app/services/review_service.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class StudentProfileController with ChangeNotifier {
  final AuthProvider _authProvider;
  final ReviewService _reviewService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StudentProfileController(
      {required AuthProvider authProvider,
      required ReviewService reviewService})
      : _authProvider = authProvider,
        _reviewService = reviewService {
    _updateStateFromAuthProvider();
    _authProvider.addListener(_updateStateFromAuthProvider);
  }

  bool _isLoadingPercentage = false;
  bool get isLoadingPercentage => _isLoadingPercentage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refreshProfile() async {
    await _authProvider.refreshCurrentUserProfile();
  }

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

  Future<bool> checkReviewPercentage() async {
    final studentId = _authProvider.currentUser?.id;
    if (studentId == null) {
      debugPrint("Cannot check review percentage: studentId is null.");
      return false;
    }

    if (_isLoadingPercentage) return false;

    _isLoadingPercentage = true;

    try {
      final percentage = await _reviewService.fetchReviewPercentage(studentId);
      debugPrint("Fetched review percentage: $percentage");
      return percentage < 50.0;
    } catch (e) {
      debugPrint("Failed to check review percentage: $e");
      return false;
    } finally {
      _isLoadingPercentage = false;
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
