import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnectStudentsScreen extends StatefulWidget {
  const ConnectStudentsScreen({super.key});

  @override
  _ConnectStudentsScreenState createState() => _ConnectStudentsScreenState();
}

class _ConnectStudentsScreenState extends State<ConnectStudentsScreen> {
  String nearestUniversity = "Unknown";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  // Coordenadas de las universidades
  final List<Map<String, dynamic>> universities = [
    {"name": "Universidad Nacional", "lat": 4.638193, "lng": -74.084046},
    {"name": "Universidad de los Andes", "lat": 4.602844, "lng": -74.065526},
    {"name": "Pontificia Universidad Javeriana", "lat": 4.627903, "lng": -74.064813},
    {"name": "Universidad del Rosario", "lat": 4.601046, "lng": -74.066379},
    {"name": "Universidad de la Sabana", "lat": 4.861578, "lng": -74.032536},
  ];

  @override
  void initState() {
    super.initState();
    _determineNearestUniversity();
  }

  Future<void> _determineNearestUniversity() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si la ubicación está habilitada
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        nearestUniversity = "Ubicación deshabilitada";
      });
      return;
    }

    // Solicitar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          nearestUniversity = "Permiso denegado";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        nearestUniversity = "Permiso permanentemente denegado";
      });
      return;
    }

    // Obtener ubicación actual
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calcular la universidad más cercana
    String closest = "No encontrado";
    double minDistance = double.infinity;

    for (var uni in universities) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        uni["lat"],
        uni["lng"],
      );

      if (distance < minDistance) {
        minDistance = distance;
        closest = uni["name"];
      }
    }

    setState(() {
      nearestUniversity = closest;
    });
  }

  Future<void> _sendNotification() async {
    const String apiUrl = "http://192.168.1.8:8000/api/send-notification/";

    final Map<String, dynamic> notificationData = {
      "title": _titleController.text,
      "message": _messageController.text,
      "place": _placeController.text,
      "university": nearestUniversity,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        _showDialog("Success", "Notification sent successfully.");
      } else {
        _showDialog("Error", "Failed to send notification.");
      }
    } catch (e) {
      _showDialog("Error", "An error occurred: $e");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TutorApp",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Connect with nearest students',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF192650)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Invite students to your sessions.\nTutorApp sends a notification based on your nearest university location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              'Nearest University: $nearestUniversity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildInputField('Title', _titleController),
            const SizedBox(height: 10),
            _buildInputField('Message', _messageController),
            const SizedBox(height: 10),
            _buildInputField('Place', _placeController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192650),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),

                ),
              ),
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF192650))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $label",
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
