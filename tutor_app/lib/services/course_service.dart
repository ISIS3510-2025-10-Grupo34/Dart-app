import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../utils/env_config.dart';

class CourseService {
  // Definir la URL base
  final String baseUrl = '${EnvConfig.apiUrl}/api/courses/';

  // Obtener todos los cursos
  Future<List<Course>> getCourses({int? tutorId, String? university, String? major}) async {
    // Construir la URL con parámetros opcionales
    String url = baseUrl;
    List<String> queryParams = [];

    if (tutorId != null) queryParams.add('tutor_id=$tutorId');
    if (university != null) queryParams.add('university=$university');
    if (major != null) queryParams.add('major=$major');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convertir la respuesta JSON en una lista de objetos Course
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }
}
