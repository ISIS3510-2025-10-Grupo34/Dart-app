import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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

    // Aceptar múltiples códigos de éxito
    if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 202) {
      return true;
    }

    // Manejo de reseñas duplicadas si el backend retorna 409
    if (response.statusCode == 409) {
      debugPrint("⚠️ La reseña ya existe en el servidor (409 - conflicto).");
      return true; // Considerar como enviada
    }
    return false;
  } catch (e) {
    return false;
  }
}


  Future<double> fetchReviewPercentage(String studentId) async {
    final apiUrl = '${EnvConfig.apiUrl}/api/review-percentage/';
    final int? parsedStudentId = int.tryParse(studentId);

    if (parsedStudentId == null) {
      throw Exception('Invalid Student ID format');
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: parsedStudentId.toString(),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('percentage')) {
          final percentage = responseData['percentage'];
          if (percentage is num) {
            return percentage.toDouble();
          } else if (percentage is String) {
            return double.tryParse(percentage) ?? 0.0;
          }
        }

        throw Exception(
            'Percentage key not found or invalid format in API response');
      } else {
        String errorMessage =
            'Failed to load review percentage (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error fetching review percentage: ${e.toString()}');
    }
  }
}
