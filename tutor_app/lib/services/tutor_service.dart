import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tutor_app/models/time_insight.dart';
import '../utils/env_config.dart';
import '../models/tutor_list_item_model.dart';
import '../models/tutor_profile.dart';
import '../models/similar_tutor_review_model.dart';
import 'package:lru/lru.dart';
import 'local_database_service.dart';

class TutorService {
  final LruCache<int, SimilarTutorReviewsResponse> _similarReviewsCache =
      LruCache(10);
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<List<String>> fetchTutors() async {
    List<String> localTutors = await _dbService.getTutors(); // ← debe retornar List<String>
    if (localTutors.isNotEmpty) {
      return localTutors;
    }

    final apiUrl = '${EnvConfig.apiUrl}/api/info/tutors/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> tutorList = data['tutors'] as List<dynamic>? ?? [];
        List<String> fetchedTutors = List<String>.from(tutorList);

        if (fetchedTutors.isNotEmpty) {
          await _dbService.bulkInsertTutors(fetchedTutors); // ← inserta en cache local
        }
        print("Fetched tutors: $fetchedTutors");
        return List<String>.from(tutorList);
      } else {
        throw Exception(
            'Failed to load tutors (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw "Please check your connection";
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
      throw "Please check your connection";
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
        return null;
      }
    } catch (e) {
      print("Exception fetching insight: $e");
      return null;
    }
  }

  Future<SimilarTutorReviewsResponse> fetchSimilarTutorReviews(
      int tutorId) async {
    final cachedResponse = _similarReviewsCache[tutorId];
    if (cachedResponse != null) {
      return cachedResponse;
    }
    final String endpointPath = '/api/similar-tutors-reviews/$tutorId';
    final apiUrl = '${EnvConfig.apiUrl}$endpointPath';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        final networkResponse =
            SimilarTutorReviewsResponse.fromJson(decodedBody);
        _similarReviewsCache[tutorId] = networkResponse;
        return networkResponse;
      } else {
        throw Exception(
            'Failed to load similar reviews (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw "Please check your connection";
    }
  }
  
  Future<List<String>> fetchTutorNames() async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/info/tutors/');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> tutorList = data['tutors'] ?? [];

        return List<String>.from(tutorList);
      } else {
        throw Exception('Failed to load tutors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error fetching tutor names: $e");
    }
  }
}
