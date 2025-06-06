import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/env_config.dart';

class UserService {
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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMessage =
            'Registration failed (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
          return false;
        } catch (_) {}
        return false;
      }
    } catch (e) {
      throw "Please check your connection";
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
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final rawData = responseData["data"];
          if (rawData is Map) {
            return rawData.map((key, value) => MapEntry(key.toString(), value));
          } else {
            return {};
          }

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
      throw "Please check your connection";
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
      throw "Please check your connection";
    }
  }
}
