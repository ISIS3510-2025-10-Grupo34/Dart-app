import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutor_profile.dart'; // Import TutorProfile model

class TutorService {
  Future<List<TutorListItemModel>> fetchTutors() async {
    try {
      final apiUrl = '${EnvConfig.apiUrl}/api/tutors/';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        final List<dynamic> tutorDataList = decodedBody['tutors'] ?? [];

        List<TutorListItemModel> tutors = tutorDataList
            .map((tutorJson) {
              try {
                return TutorListItemModel.fromJson(tutorJson);
              } catch (e) {
                return null;
              }
            })
            .whereType<TutorListItemModel>()
            .toList();
        return tutors;
      } else {
        throw Exception(
            'Failed to load tutors (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to fetch tutors: ${e.toString()}');
    }
  }

  Future<TutorProfile> fetchTutorProfile(int tutorId) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/tutorprofile/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tutorId": tutorId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic>? profileData = responseData["data"];
        if (profileData != null) {
          return TutorProfile.fromJson(profileData);
        } else {
          throw Exception('Profile data not found in API response.');
        }
      } else {
        throw Exception(
            'Failed to load profile (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching tutor profile: $e");
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }
}
