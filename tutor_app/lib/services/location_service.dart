import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/university_model.dart';
import '../utils/env_config.dart';

class LocationService {
  Future<String> getNearestUniversity() async {
    try {
      final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/coordinates/'));

      if (response.statusCode != 200) {
        return "Error al obtener coordenadas";
      }

      final List<dynamic> universityData = jsonDecode(response.body)['universities'];
      List<University> universities = universityData.map((u) {
        return University(
          name: u['name'],
          lat: (u['lat'] as num).toDouble(),
          lng: (u['lng'] as num).toDouble(),
        );
      }).toList();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return "Ubicación deshabilitada";

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return "Permiso denegado";
      }
      if (permission == LocationPermission.deniedForever) {
        return "Permiso permanentemente denegado";
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String closest = "No encontrado";
      double minDistance = double.infinity;

      for (var uni in universities) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          uni.lat,
          uni.lng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          closest = uni.name;
        }
      }

      return closest;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String place,
    required String university,
  }) async {
    final String apiUrl = '${EnvConfig.apiUrl}/api/send-notification/';
    final Map<String, dynamic> data = {
      "title": title,
      "message": message,
      "place": place,
      "university": university,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
