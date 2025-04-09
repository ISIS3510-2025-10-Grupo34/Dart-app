import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/env_config.dart';

class WriteReviewController {
  Future<Map<String, dynamic>> fetchTutorProfile(int tutorId) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/tutorprofile/?tutorId=$tutorId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tutorId": tutorId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData["data"] ?? {};
      } else {
        throw Exception("Error al obtener el perfil del tutor");
      }
    } catch (e) {
      throw Exception("No se pudo conectar con el servidor");
    }
  }

  /// Envía una reseña al servidor
  Future<bool> submitReview(int tutorId, double rating, String comment) async {
    final review = Review(rating, comment);

    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/submit-review/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tutorId": tutorId,
          ...review.toJson(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
