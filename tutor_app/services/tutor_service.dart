import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tutor_profile.dart';

class TutorService {
  static const String baseUrl = "http://192.168.1.8:8000/api/";  

  Future<TutorProfile> fetchTutorProfile(int tutorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutorprofile/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tutorId": tutorId}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)["data"];
      return TutorProfile.fromJson(jsonData);
    } else {
      throw Exception("Error al obtener el perfil del tutor");
    }
  }
}
