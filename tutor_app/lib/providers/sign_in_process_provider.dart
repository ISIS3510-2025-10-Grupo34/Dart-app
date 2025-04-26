import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../services/local_cache_service.dart';

enum RegistrationSubmissionState {
  idle,
  submitting,
  success,
  error,
  queuedOffline
}

class SignInProcessProvider with ChangeNotifier {
  final UserService _userService;
  final LocalCacheService _localCacheService;

  SignInProcessProvider(
      {required UserService userService,
      required LocalCacheService localCacheService})
      : _userService = userService,
        _localCacheService = localCacheService;

  String? _email;
  String? _password;
  String? _role;

  String? _name;
  String? _phoneNumber;
  String? _university;
  String? _major;
  String? _areaOfExpertise;

  String? _learningStyles;

  String? _profilePicturePath;
  String? _idPicturePath;

  RegistrationSubmissionState _submissionState =
      RegistrationSubmissionState.idle;
  RegistrationSubmissionState get submissionState => _submissionState;

  String? _submissionError;
  String? get submissionError => _submissionError;

  void setCredentialsAndRole(String email, String password, String role) {
    _email = email;
    _password = password;
    _role = role;
  }

  void setStudentDetails(Map<String, String> studentData) {
    _name = studentData['name'];
    _phoneNumber = studentData['phone_number'];
    _university = studentData['university'];
    _major = studentData['major'];
  }

  void setTutorDetails(Map<String, String> tutorData) {
    _name = tutorData['name'];
    _phoneNumber = tutorData['phone_number'];
    _university = tutorData['university'];
    _areaOfExpertise = tutorData['area_of_expertise'];
  }

  void setLearningStyles(String styles) {
    _learningStyles = styles;
  }

  void setProfilePicturePath(String? path) {
    _profilePicturePath = path;
    notifyListeners();
  }

  void setIdPicturePath(String? path) {
    _idPicturePath = path;
    notifyListeners();
  }

  Future<void> submitRegistration() async {
    if (_submissionState == RegistrationSubmissionState.submitting ||
        _submissionState == RegistrationSubmissionState.queuedOffline) return;

    if (_email == null || _password == null || _role == null || _name == null) {
      _submissionError = "Error: Missing essential registration information.";
      _submissionState = RegistrationSubmissionState.error;
      notifyListeners();
      return;
    }
    if (_idPicturePath == null) {
      _submissionError = "Error: Profile and ID pictures are required.";
      _submissionState = RegistrationSubmissionState.error;
      notifyListeners();
      return;
    }

    _submissionState = RegistrationSubmissionState.submitting;
    _submissionError = null;
    notifyListeners();

    Map<String, String> userData = {
      'name': _name!,
      'email': _email!,
      'phone_number': _phoneNumber ?? '',
      'university': _university ?? '',
      'password': _password!,
      'role': _role!,
      if (_role == 'student') 'major': _major ?? '',
      if (_role == 'student') 'learning_styles': _learningStyles ?? '',
      if (_role == 'tutor') 'area_of_expertise': _areaOfExpertise ?? '',
    };

    try {
      final bool success = await _userService.registerUser(
          userData, _profilePicturePath, _idPicturePath);

      if (success) {
        _submissionState = RegistrationSubmissionState.success;
      } else {
        throw Exception("Registration failed in service.");
      }
    } on SocketException catch (e) {
      debugPrint("Network error during registration: $e");
      _submissionError = "No internet connection. Registration queued.";
      _submissionState = RegistrationSubmissionState.queuedOffline;
      final registrationData = {
        'userData': userData,
        'profilePicturePath': _profilePicturePath,
        'idPicturePath': _idPicturePath,
        'timestamp': DateTime.now().toIso8601String(),
      };
      try {
        await _localCacheService.cachePendingRegistration(registrationData);
        debugPrint("Registration queued locally.");
      } catch (cacheError) {
        debugPrint("Failed to cache registration: $cacheError");
        _submissionError =
            "Network error, and failed to queue registration locally.";
        _submissionState =
            RegistrationSubmissionState.error; // Fallback to general error
      }
    } catch (e) {
      _submissionError = e.toString();
      _submissionState = RegistrationSubmissionState.error;
      throw "";
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _email = null;
    _password = null;
    _role = null;
    _name = null;
    _phoneNumber = null;
    _university = null;
    _major = null;
    _areaOfExpertise = null;
    _learningStyles = null;
    _profilePicturePath = null;
    _idPicturePath = null;
    _submissionState = RegistrationSubmissionState.idle;
    _submissionError = null;
    notifyListeners();
  }
}
