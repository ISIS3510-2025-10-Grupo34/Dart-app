import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/university_model.dart';
import '../utils/env_config.dart';

class LocationService {
  bool _isNotificationInProgress = false;
  Future<String> getNearestUniversity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    if (!hasInternet) return "Location not available";
    final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/coordinates/'));

    if (response.statusCode != 200) {
      return "Location not available";
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
    if (!serviceEnabled) return "Location not available";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return "Location not available";
    }
    if (permission == LocationPermission.deniedForever) {
      return "Location not available";
    }

    // Obtener ubicación
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calcular universidad más cercana
    String closest = "Not found";
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
    return "Location not available";
  }
}


  Future<bool> sendNotification({
  required String title,
  required String message,
  required String place,
  required String university,
}) async {
    if (_isNotificationInProgress) return false;
    _isNotificationInProgress = true;
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


    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
  finally {
      _isNotificationInProgress = false; 
    }
}

}
