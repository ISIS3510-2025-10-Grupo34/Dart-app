import 'dart:convert';
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
    if (profilePicturePath != null) _currentUser.profilePicturePath = profilePicturePath;
    if (idPicturePath != null) _currentUser.idPicturePath = idPicturePath;
    if (password != null) _currentUser.password = password;
  }

  Future<void> storeToken(String token) async {
    try {
      await storage.write(key: 'auth_token', value: token);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (!decodedToken.containsKey('id') || !decodedToken.containsKey('email')) {
        throw Exception('Token missing required fields');
      }

      updateUserInfo(
        id: decodedToken["id"].toString(),
        email: decodedToken["email"],
      );
    } catch (e) {
      print('Error decoding/storing token: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('data') && data['data'].containsKey('token')) {
          await storeToken(data['data']['token']);
          return data['data'];
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
      return null;
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return null;
    }
  }

  Future<bool> registerUser(BuildContext context) async {
    try {
      final apiUrl = '${EnvConfig.apiUrl}/api/register/';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields.addAll({
        'name': _currentUser.name ?? '',
        'email': _currentUser.email ?? '',
        'phone_number': _currentUser.phoneNumber ?? '',
        'university': _currentUser.university ?? '',
        'major': _currentUser.major ?? '',
        'area_of_expertise': _currentUser.areaOfExpertise ?? '',
        'is_admin': _currentUser.isAdmin,
        'is_student': _currentUser.isStudent,
        'is_tutor': _currentUser.isTutor,
        'learning_styles': _currentUser.learningStyles ?? '',
        'password': _currentUser.password ?? '',
      });

      if (_currentUser.profilePicturePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', _currentUser.profilePicturePath!,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      if (_currentUser.idPicturePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'id_picture', _currentUser.idPicturePath!,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Register response: ${response.body}"); // Debugging

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
      return false;
    } catch (e) {
      print("Register error: $e");
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
      if (studentId == null || studentId.isEmpty) {
        throw Exception("Student ID is required");
      }

      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/studentprofile/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"studentId": int.tryParse(studentId) ?? 0}),
      );

      print("Profile response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic> userData = responseData["data"];

        updateUserInfo(
          name: userData["name"],
          university: userData["university"],
          major: userData["major"],
          learningStyles: userData["learning_styles"] is List
              ? userData["learning_styles"].join(', ')
              : userData["learning_styles"].toString(),
          profilePicturePath: userData["profile_picture"],
        );

        return userData;
      }

      throw Exception("Failed to load profile data");
    } catch (e) {
      print('Error fetching student profile: $e');
      throw Exception('Failed to load profile data: $e');
    }
  }
}
