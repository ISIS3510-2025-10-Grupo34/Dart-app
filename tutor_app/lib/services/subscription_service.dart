import 'dart:convert';
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
        print('Subscription successful: ${response.body}');
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
          print('Could not parse error response body: ${response.body}');
          errorMessage = "An unknown error occurred during subscription (Status ${response.statusCode}).";
        }
        throw Exception(errorMessage); 
      }
    } catch (e) {
      if (e is Exception && (e.toString().contains("Error Subscribing") || e.toString().contains("Student already subscribed"))) {
        rethrow;
      }
      print('Network or unexpected error in SubscriptionService.subscribeToCourse: $e');
      throw Exception('An error occurred while trying to subscribe. Please check your connection.');
    }
  }
}
