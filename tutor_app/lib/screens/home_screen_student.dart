import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import '../services/user_service.dart';
import 'tutor_reviews.dart';
import 'student_profile_screen.dart';
import 'write_review_screen.dart';

class HomeScreenStudent extends StatefulWidget {
  const HomeScreenStudent({super.key});
  
  @override
  _HomeScreenStudentState createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  late final Future<List<dynamic>> _tutors;
  final UserService _userService = UserService();
  final Stopwatch _loadTimer = Stopwatch();
  late DateTime _homeOpenedAt;

  @override
  void initState() {
    super.initState();
    _homeOpenedAt = DateTime.now();
    _tutors = fetchTutors();
  }

  Future<List<dynamic>> fetchTutors() async {
    _loadTimer.start();

    final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/tutors/'));

    _loadTimer.stop();
    _reportLoadTime(_loadTimer.elapsedMilliseconds);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tutors"];
    } else {
      throw Exception("Error al obtener la lista de tutores");
    }
  }

  void _reportLoadTime(int ms) async {
    final studentId = await _userService.getId();
    if (studentId == null) return;

    final log = {
      "student_id": studentId,
      "load_time_ms": ms,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/analytics/load-time'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log),
      );
    } catch (e) {
      debugPrint("❌ Excepción al reportar load time: $e");
    }
  }

  void _reportBookingTime(String tutorIdStr) async {
    final studentId = await _userService.getId();
    if (studentId == null) return;

    final tutorId = int.tryParse(tutorIdStr);
    if (tutorId == null) return;

    final duration = DateTime.now().difference(_homeOpenedAt);

    final log = {
      "student_id": studentId,
      "tutor_id": tutorId,
      "time_to_book_ms": duration.inMilliseconds,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/analytics/booking-time'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log),
      );
    } catch (e) {
      debugPrint("❌ Excepción al reportar booking time: $e");
    }
  }

  void _navigateToStudentProfile() async {
    final studentId = await _userService.getId();

    if (studentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se encontró el perfil del estudiante.")),
      );
    }
  }

  void _bookSessionAndNavigate(String tutorIdStr) async {
    final studentId = await _userService.getId();
    if (studentId == null) return;

    final tutorId = int.tryParse(tutorIdStr);
    if (tutorId == null) {
      debugPrint("❌ tutorId no es válido: $tutorIdStr");
      return;
    }

    final now = DateTime.now().toUtc();

    final body = {
      "tutor_id": tutorId,
      "student_id": studentId,
      "course_id": 1,
      "cost": 200.0,
      "date_time": now.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/create-tutoring-session/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final sessionId = jsonDecode(response.body)["session_id"];
        debugPrint("✅ Sesión creada con ID: $sessionId");
      } else {
        debugPrint("⚠️ Error al crear sesión: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al reservar la sesión.")),
        );
      }
    } catch (e) {
      debugPrint("❌ Excepción al reservar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al conectar con el servidor.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TutorApp",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF192650),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Filtrar",
            icon: const Icon(Icons.filter_list, color: Color(0xFF192650)),
            onPressed: () {},
          ),
          IconButton(
            tooltip: "Perfil",
            icon: const Icon(Icons.person, color: Color(0xFF192650)),
            onPressed: _navigateToStudentProfile,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _tutors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los tutores"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay tutores disponibles"));
          }

          final tutorsList = List<dynamic>.from(snapshot.data!);
          tutorsList.sort((a, b) {
            double ratingA = double.tryParse(a["average_rating"]?.toString() ?? "0.0") ?? 0.0;
            double ratingB = double.tryParse(b["average_rating"]?.toString() ?? "0.0") ?? 0.0;
            return ratingB.compareTo(ratingA);
          });

          return ListView.builder(
            itemCount: tutorsList.length,
            itemBuilder: (context, index) {
              final tutor = tutorsList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TutorProfile(tutorId: tutor["id"]),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF192650),
                              child: Text(
                                tutor["name"][0],
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                          title: Text(
                            tutor["name"],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            tutor["university"],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Subjects: ${tutor["subjects"].join(", ")}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _reportBookingTime(tutor["id"].toString());
                              _bookSessionAndNavigate(tutor["id"].toString());
                            },
                            icon: const Icon(Icons.book_online, size: 18),
                            label: const Text('Book'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF192650),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
