import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../utils/env_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/home_screen.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  final User _currentUser = User();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User get currentUser => _currentUser;

  // Update user info based on form fields
  void updateUserInfo({
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

  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final apiUrl = '${EnvConfig.apiUrl}/api/login/';

      // Prepare login payload
      Map<String, dynamic> payload = {
        'email': email.trim(),
        'password': password,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('id')) {
          _currentUser.id = responseData['id'] ?? _currentUser.id;
          _currentUser.email = responseData['email'] ?? _currentUser.email;
        }
        final token = responseData['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

        return true;
      } else {
        // Handle login failure
        return false;
      }
    } catch (e) {
      // Handle network or other errors
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
      if (_currentUser.profilePicturePath != null && !kIsWeb) {
        final profileFile = await http.MultipartFile.fromPath(
          'profile_picture',
          _currentUser.profilePicturePath!,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(profileFile);
      }

      // Add ID picture if available
      if (_currentUser.idPicturePath != null && !kIsWeb) {
        final idFile = await http.MultipartFile.fromPath(
          'id_picture',
          _currentUser.idPicturePath!,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(idFile);
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
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
}
