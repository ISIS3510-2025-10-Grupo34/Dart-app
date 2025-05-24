import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../services/local_cache_service.dart';
import '../misc/constants.dart';
import 'package:hive/hive.dart';

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
  late Box _signUpProgressBox;

  SignInProcessProvider({
    required UserService userService,
    required LocalCacheService localCacheService,
  })  : _userService = userService,
        _localCacheService = localCacheService {
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    _signUpProgressBox = await Hive.openBox(HiveKeys.signUpProgressBox);
  }

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

  String? get savedEmail =>
      _signUpProgressBox.get(HiveKeys.email, defaultValue: _email);
  String? get savedPassword =>
      _signUpProgressBox.get(HiveKeys.password, defaultValue: _password);
  String? get savedRole =>
      _signUpProgressBox.get(HiveKeys.role, defaultValue: _role);
  String? get savedName =>
      _signUpProgressBox.get(HiveKeys.name, defaultValue: _name);
  String? get savedPhoneNumber =>
      _signUpProgressBox.get(HiveKeys.phoneNumber, defaultValue: _phoneNumber);
  String? get savedUniversity =>
      _signUpProgressBox.get(HiveKeys.university, defaultValue: _university);
  String? get savedMajor =>
      _signUpProgressBox.get(HiveKeys.major, defaultValue: _major);
  String? get savedAreaOfExpertise => _signUpProgressBox
      .get(HiveKeys.areaOfExpertise, defaultValue: _areaOfExpertise);
  String? get savedLearningStyles => _signUpProgressBox
      .get(HiveKeys.learningStyles, defaultValue: _learningStyles);
  String? get savedProfilePicturePath => _signUpProgressBox
      .get(HiveKeys.profilePicturePath, defaultValue: _profilePicturePath);

  Future<void> setCredentialsAndRole(
      String email, String password, String role) async {
    _email = email;
    _password = password;
    _role = role;
    await _signUpProgressBox.put(HiveKeys.email, email);
    await _signUpProgressBox.put(HiveKeys.password, password);
    await _signUpProgressBox.put(HiveKeys.role, role);
    notifyListeners();
  }

  Future<void> setStudentDetails(Map<String, String> studentData) async {
    _name = studentData['name'];
    _phoneNumber = studentData['phone_number'];
    _university = studentData['university'];
    _major = studentData['major'];
    await _signUpProgressBox.put(HiveKeys.name, _name);
    await _signUpProgressBox.put(HiveKeys.phoneNumber, _phoneNumber);
    await _signUpProgressBox.put(HiveKeys.university, _university);
    await _signUpProgressBox.put(HiveKeys.major, _major);
    notifyListeners();
  }

  Future<void> setTutorDetails(Map<String, String> tutorData) async {
    _name = tutorData['name'];
    _phoneNumber = tutorData['phone_number'];
    _university = tutorData['university'];
    _areaOfExpertise = tutorData['area_of_expertise'];
    await _signUpProgressBox.put(HiveKeys.name, _name);
    await _signUpProgressBox.put(HiveKeys.phoneNumber, _phoneNumber);
    await _signUpProgressBox.put(HiveKeys.university, _university);
    await _signUpProgressBox.put(HiveKeys.areaOfExpertise, _areaOfExpertise);
    notifyListeners();
  }

  Future<void> setLearningStyles(String styles) async {
    _learningStyles = styles;
    await _signUpProgressBox.put(HiveKeys.learningStyles, styles);
    notifyListeners();
  }

  Future<void> setProfilePicturePath(String? path) async {
    _profilePicturePath = path;
    if (path != null) {
      await _signUpProgressBox.put(HiveKeys.profilePicturePath, path);
    } else {
      await _signUpProgressBox.delete(HiveKeys.profilePicturePath);
    }
    notifyListeners();
  }

  void setIdPicturePath(String? path) {
    _idPicturePath = path;
    notifyListeners();
  }

  Future<void> loadSignUpProgress() async {
    if (!_signUpProgressBox.isOpen) {
      _signUpProgressBox = await Hive.openBox(HiveKeys.signUpProgressBox);
    }
    _email = _signUpProgressBox.get(HiveKeys.email, defaultValue: _email);
    _password =
        _signUpProgressBox.get(HiveKeys.password, defaultValue: _password);
    _role = _signUpProgressBox.get(HiveKeys.role, defaultValue: _role);
    _name = _signUpProgressBox.get(HiveKeys.name, defaultValue: _name);
    _phoneNumber = _signUpProgressBox.get(HiveKeys.phoneNumber,
        defaultValue: _phoneNumber);
    _university =
        _signUpProgressBox.get(HiveKeys.university, defaultValue: _university);
    _major = _signUpProgressBox.get(HiveKeys.major, defaultValue: _major);
    _areaOfExpertise = _signUpProgressBox.get(HiveKeys.areaOfExpertise,
        defaultValue: _areaOfExpertise);
    _learningStyles = _signUpProgressBox.get(HiveKeys.learningStyles,
        defaultValue: _learningStyles);
    _profilePicturePath = _signUpProgressBox.get(HiveKeys.profilePicturePath,
        defaultValue: _profilePicturePath);
  }

  Future<void> clearSignUpProgress() async {
    await _signUpProgressBox.clear();
    _email = null;
    _password = null;
    _role = null;
    _name = null;
    _profilePicturePath = null;
    _idPicturePath = null;
    debugPrint("Cleared sign-up progress from Hive.");
    notifyListeners();
  }

  Future<void> submitRegistration() async {
    if (_submissionState == RegistrationSubmissionState.submitting ||
        _submissionState == RegistrationSubmissionState.queuedOffline) {
      return;
    }

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
        await clearSignUpProgress();
      } else {
        _submissionError =
            "Registration failed. The server rejected the request.";
        _submissionState = RegistrationSubmissionState.error;
        debugPrint(
            "SignInProcessProvider: Initial registration failed (server rejected).");
      }
    } on SocketException catch (e) {
      debugPrint(
          "SignInProcessProvider: Network error during initial registration: $e");
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
        debugPrint("SignInProcessProvider: Registration queued locally.");
      } catch (cacheError) {
        debugPrint(
            "SignInProcessProvider: Failed to cache registration: $cacheError");
        _submissionError =
            "Network error, and failed to queue registration locally.";
        _submissionState = RegistrationSubmissionState.error;
      }
    } catch (e) {
      debugPrint(
          "SignInProcessProvider: Unexpected error during initial registration: $e");
      _submissionError = "An unexpected error occurred: ${e.toString()}";
      _submissionState = RegistrationSubmissionState.error;
    } finally {
      notifyListeners();
    }
  }

  void setBackgroundSyncSuccess() {
    if (_submissionState == RegistrationSubmissionState.queuedOffline ||
        _submissionState == RegistrationSubmissionState.submitting) {
      debugPrint(
          "SignInProcessProvider: Background sync successful. Updating state.");
      _submissionState = RegistrationSubmissionState.success;
      _submissionError = null;
      clearSignUpProgress();
      notifyListeners();
    } else {
      debugPrint(
          "SignInProcessProvider: Background sync successful, but current state is $_submissionState. Not updating state.");
    }
  }

  void setBackgroundSyncError(String error) {
    debugPrint("SignInProcessProvider: Background sync error. Updating state.");
    _submissionState = RegistrationSubmissionState.error;
    _submissionError = error;
    notifyListeners();
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

  bool get hasSavedProgress => _signUpProgressBox.isNotEmpty;
}
