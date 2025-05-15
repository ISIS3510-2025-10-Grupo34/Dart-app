import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tutor_app/models/time_insight.dart';
import '../utils/env_config.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutor_profile.dart';
import '../models/similar_tutor_review_model.dart';
import 'local_database_service.dart';

class TutorService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<List<TutorListItemModel>> fetchTutors() async {
    try {
      final apiUrl = '${EnvConfig.apiUrl}/api/info/tutors/';
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

        List<Map<String, dynamic>> tutorsToInsert = tutorDataList.map((tutor) {
          return {
            'id': tutor['id'],
            'name': tutor['name'],
            'phone_number': tutor['phone_number'],
            'role': tutor['role'],
            'profile_picture': tutor['profile_picture_url'],
            'id_profile_picture': tutor['id_picture_url'],
            'average_rating': tutor['avg_rating'],
            'university_id': tutor['university_id'],
            'major_id': tutor['major_id'],
            'area_of_expertise_id': tutor['area_of_expertise_id'],
          };
        }).toList();

        await _dbService.bulkInsertTutors(tutorsToInsert);

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

  Future<TimeToBookInsight?> fetchTimeToBookInsight() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.apiUrl}/api/time-to-book-insight/'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TimeToBookInsight.fromJson(data);
      } else {
        print(
            "Error fetching insight: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception fetching insight: $e");
      return null;
    }
  }

  Future<SimilarTutorReviewsResponse> fetchSimilarTutorReviews(
      int tutorId) async {
    final String endpointPath = '/api/similar-tutors-reviews/$tutorId';
    final apiUrl = '${EnvConfig.apiUrl}$endpointPath';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        return SimilarTutorReviewsResponse.fromJson(decodedBody);
      } else {
        throw Exception(
            'Failed to load similar reviews (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to fetch similar reviews: ${e.toString()}');
    }
  }
}
