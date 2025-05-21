import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart'; 

class SubscriptionService {

  Future<void> subscribeToCourse({
    required String studentId,
    required String course,
    required String university,
  }) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/tutoring-sessions-ordered/');

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

      if (response.statusCode != 201) {
        throw Exception("Error Subscribing to the course: ${response.body}");
      }
    } catch (e) {
      print('Error in SubscriptionService.subscribeToCourse: $e');
      throw Exception('An error occurred while trying to subscribe: ${e.toString()}');
    }
  }
}
