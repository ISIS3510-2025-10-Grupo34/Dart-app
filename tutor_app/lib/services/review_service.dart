import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/env_config.dart';

class ReviewService {
  Future<bool> submitReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/submit-review/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(review.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
