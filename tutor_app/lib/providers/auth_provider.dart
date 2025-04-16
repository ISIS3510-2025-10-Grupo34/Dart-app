import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
      String? profilePictureBase64;

      if (userRole == 'student') {
        fullUserInfo = await _userService.fetchStudentProfile(userId);
        _currentUser?.fromJsonStudent(fullUserInfo!);
        profilePictureBase64 = fullUserInfo?['profile_picture'];
      } else if (userRole == 'tutor') {
        fullUserInfo = await _userService.fetchTutorProfile(userId);
        _currentUser?.fromJsonTutorProfile(fullUserInfo!);
      } else {
        throw Exception("Unknown user role for profile fetch: $userRole");
      }

      String? finalProfilePath;
      if (profilePictureBase64 != null && profilePictureBase64.isNotEmpty) {
        try {
          String base64String = profilePictureBase64;
          if (base64String.contains(',')) {
            base64String = base64String.split(',')[1];
          }
          Uint8List imageBytes = base64Decode(base64String);

          final directory = await getApplicationDocumentsDirectory();

          final fileName = 'profile_image_$userId.png';
          final filePath = path.join(directory.path, fileName);

          final imageFile = File(filePath);
          await imageFile.writeAsBytes(imageBytes);

          finalProfilePath = filePath;
        } catch (e) {
          finalProfilePath = null;
        }
      }

      _currentUser?.profilePicturePath = finalProfilePath;

      _profileError = null;
    } catch (e) {
      _profileError = "Failed to load profile details: ${e.toString()}";
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

  Future<void> clearLocalProfilePicture() async {
    if (_currentUser?.profilePicturePath != null &&
        _currentUser!.profilePicturePath!.isNotEmpty) {
      try {
        final file = File(_currentUser!.profilePicturePath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint(
              "Deleted local profile picture: ${_currentUser!.profilePicturePath}");
        }
      } catch (e) {
        debugPrint("Error deleting local profile picture: $e");
      }
      _currentUser!.profilePicturePath = null;
    }
  }

  Future<void> logout() async {
    await clearLocalProfilePicture();
    _currentUser = null;

    _authState = AuthState.unauthenticated;
    notifyListeners();
  }
}
