import 'dart:convert';
<<<<<<< HEAD
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/env_config.dart';

class UserService {
  /// Registers a user with optional profile and ID pictures.
  Future<bool> registerUser(
    Map<String, String> userData,
    String? profilePicturePath,
    String? idPicturePath,
  ) async {
    final apiUrl = '${EnvConfig.apiUrl}/api/register/';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    try {
      final role = userData['role'] ?? '';
      request.fields.addAll({
        'name': userData['name'] ?? '',
        'email': userData['email'] ?? '',
        'phone_number': userData['phone_number'] ?? '',
        'university': userData['university'] ?? '',
        'password': userData['password'] ?? '',
        'role': role,
      });

      if (role == 'student') {
        request.fields['major'] = userData['major'] ?? '';
        request.fields['learning_styles'] = userData['learning_styles'] ?? '';
      } else if (role == 'tutor') {
        request.fields['area_of_expertise'] =
            userData['area_of_expertise'] ?? '';
      }

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicturePath,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      if (idPicturePath != null && idPicturePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'id_picture',
          idPicturePath,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

=======
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../utils/env_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  final User _currentUser = User();

  final storage = const FlutterSecureStorage();

  User get currentUser => _currentUser;

  // Update user info based on form fields
  void updateUserInfo({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? university,
    String? major,
    String? areaOfExpertise,
    String? isAdmin,
    String? isStudent,
    String? isTutor,
    String? learningStyles,
    String? profilePicturePath,
    String? idPicturePath,
    String? password,
  }) {
    if (id != null) _currentUser.id = id;
    if (name != null) _currentUser.name = name;
    if (email != null) _currentUser.email = email;
    if (phoneNumber != null) _currentUser.phoneNumber = phoneNumber;
    if (university != null) _currentUser.university = university;
    if (major != null) _currentUser.major = major;
    if (areaOfExpertise != null) _currentUser.areaOfExpertise = areaOfExpertise;
    if (isAdmin != null) _currentUser.isAdmin = isAdmin;
    if (isStudent != null) _currentUser.isStudent = isStudent;
    if (isTutor != null) _currentUser.isTutor = isTutor;
    if (learningStyles != null) _currentUser.learningStyles = learningStyles;
    if (profilePicturePath != null) {
      _currentUser.profilePicturePath = profilePicturePath;
    }
    if (idPicturePath != null) _currentUser.idPicturePath = idPicturePath;
    if (password != null) _currentUser.password = password;
  }

  Future<void> storeToken(String token) async {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (!decodedToken.containsKey('id') ||
          !decodedToken.containsKey('email')) {
        throw Exception('Token missing required fields');
      }

      updateUserInfo(
          id: decodedToken["id"].toString(), email: decodedToken["email"]);
    } catch (e) {
      print('Error decoding token: $e');
      rethrow;
    }
  }

  // Login user implementation
  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Store the token
        await storeToken(data['data']['token']);

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  // Register user method
  Future<bool> registerUser(BuildContext context) async {
    try {
      final apiUrl = '${EnvConfig.apiUrl}/api/register/';

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add all user data fields
      request.fields['name'] = _currentUser.name ?? '';
      request.fields['email'] = _currentUser.email ?? '';
      request.fields['phone_number'] = _currentUser.phoneNumber ?? '';
      request.fields['university'] = _currentUser.university ?? '';
      request.fields['major'] = _currentUser.major ?? '';
      request.fields['area_of_expertise'] = _currentUser.areaOfExpertise ?? '';
      request.fields['is_admin'] = _currentUser.isAdmin;
      request.fields['is_student'] = _currentUser.isStudent;
      request.fields['is_tutor'] = _currentUser.isTutor;
      request.fields['learning_styles'] = _currentUser.learningStyles ?? '';
      request.fields['password'] = _currentUser.password ?? '';

      // Add profile picture if available
      if (_currentUser.profilePicturePath != null) {
        final profileFile = await http.MultipartFile.fromPath(
          'profile_picture',
          _currentUser.profilePicturePath!,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(profileFile);
      }

      // Add ID picture if available
      if (_currentUser.idPicturePath != null) {
        final idFile = await http.MultipartFile.fromPath(
          'id_picture',
          _currentUser.idPicturePath!,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(idFile);
      }

      // Send the request
>>>>>>> main
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
<<<<<<< HEAD
        String errorMessage =
            'Registration failed (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Registration process failed: ${e.toString()}');
    }
  }

  /// Fetches student profile by ID.
  Future<Map<String, dynamic>?> fetchStudentProfile(String studentId) async {
    final int parsedStudentId = int.tryParse(studentId) ?? 0;
    final apiUrl = '${EnvConfig.apiUrl}/api/studentprofile/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"studentId": parsedStudentId}),
=======
        // Show error message
        String errorMessage = 'Registration failed';
        try {
          final responseData = jsonDecode(response.body);
          // Django REST may return errors in different formats
          if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'];
          } else {
            // Check for field-specific errors
            final errors = [];
            responseData.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errors.add('$key: ${value.join(', ')}');
              } else if (value is String) {
                errors.add('$key: $value');
              }
            });
            if (errors.isNotEmpty) {
              errorMessage = errors.join('\n');
            }
          }
        } catch (_) {
          // If parsing fails, use response body
          errorMessage = 'Registration failed: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return false;
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
      return false;
    }
  }

  String? getId() {
    return _currentUser.id;
  }

  Future<Map<String, dynamic>> fetchStudentProfile(String? studentId) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/studentprofile/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "studentId": int.parse(studentId!),
        }),
>>>>>>> main
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
<<<<<<< HEAD
        return responseData["data"];
      } else {
        String errorMessage =
            'Failed to load student profile (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to load student profile data: ${e.toString()}');
    }
  }

  /// Fetches tutor profile by ID.
  Future<Map<String, dynamic>?> fetchTutorProfile(String tutorId) async {
    final int parsedTutorId = int.tryParse(tutorId) ?? 0;
    final apiUrl = '${EnvConfig.apiUrl}/api/tutorprofile/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tutorId": parsedTutorId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData["data"];
      } else {
        String errorMessage =
            'Failed to load tutor profile (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to load tutor profile data: ${e.toString()}');
=======
        final Map<String, dynamic> profileData = responseData["data"];
        if (profileData.containsKey('name'))
          updateUserInfo(name: profileData['name']);
        if (profileData.containsKey('university'))
          updateUserInfo(university: profileData['university']);
        if (profileData.containsKey('major'))
          updateUserInfo(major: profileData['major']);
        if (profileData.containsKey('learning_styles')) {
          var styles = profileData['learning_styles'];
          if (styles is List) {
            // Convert list to comma-separated string
            String stylesString =
                styles.map((item) => item.toString()).join(',');
            updateUserInfo(learningStyles: stylesString);
          } else if (styles is String) {
            // Use the string directly
            updateUserInfo(learningStyles: styles);
          } else {
            // Handle any other type by converting to string
            updateUserInfo(learningStyles: styles.toString());
          }
          if (profileData.containsKey('profile_picture')) {
            // The profile picture is already a base64 string, so we can use it directly
            updateUserInfo(profilePicturePath: profileData['profile_picture']);
          }
        }
        return profileData;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData["error"] ?? "Failed to load profile data");
      }
    } catch (e) {
      print('Error fetching student profile: $e');
      throw Exception('Failed to load profile data: $e');
>>>>>>> main
    }
  }
}
