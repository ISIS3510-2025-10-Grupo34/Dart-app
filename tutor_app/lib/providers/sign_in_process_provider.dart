import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

enum RegistrationSubmissionState { idle, submitting, success, error }

class SignInProcessProvider with ChangeNotifier {
  final UserService _userService;

  SignInProcessProvider({required UserService userService})
      : _userService = userService;

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
    if (_submissionState == RegistrationSubmissionState.submitting) return;

    // Basic validation before submitting
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

    try {
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

      final bool success = await _userService.registerUser(
          userData, _profilePicturePath, _idPicturePath);

      if (success) {
        _submissionState = RegistrationSubmissionState.success;
      } else {
        throw Exception("Registration failed in service.");
      }
    } catch (e) {
      _submissionError = e.toString();
      _submissionState = RegistrationSubmissionState.error;
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
