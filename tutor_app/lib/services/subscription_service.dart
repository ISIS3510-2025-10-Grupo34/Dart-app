import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart'; 

class SubscriptionService {

 Future<void> subscribeToCourse({
    required String studentId,
    required String course,
    required String university,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/subscribe/');

    try {
      final requestBody = jsonEncode({
        'student_id': studentId,
        'course': course,
        'university': university,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) { 
        return; 
      } else {
        String errorMessage = "Error Subscribing to the course."; 
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map && responseBody.containsKey('error')) {
            errorMessage = responseBody['error'];
          } else {
            errorMessage = "Error Subscribing (Status ${response.statusCode}): ${response.body}";
          }
        } catch (e) {
          errorMessage = "An unknown error occurred during subscription (Status ${response.statusCode}).";
        }
        throw Exception(errorMessage); 
      }
    } catch (e) {
      if (e is Exception && (e.toString().contains("Error Subscribing") || e.toString().contains("Student already subscribed"))) {
        rethrow;
      }
      throw Exception('An error occurred while trying to subscribe. Please check your connection.');
    }
  }

  Future<String> fetchCourseAverageRating({
    required String course,
    required String university,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/course_avg_rating/')
        .replace(queryParameters: {
      'course': course,
      'university': university,
    });

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["rating"] == "no reviews") {
          return "This course has no reviews yet.";
        } else {
          return "The average score for this course is: ${decoded["rating"]}";
        }
      }
      return "Failed to load course rating.";
    } on SocketException {
      return "Unable to fetch the average score due to no internet connection.";
    } catch (e) {
      return "Error fetching course rating.";
    }
  }
}
