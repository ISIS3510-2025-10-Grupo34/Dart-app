import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import '../services/user_service.dart';
import 'tutor_reviews.dart';
import 'student_profile_screen.dart'; // Importar la pantalla de perfil del estudiante

class HomeScreenStudent extends StatefulWidget {
  const HomeScreenStudent({super.key});

  @override
  _HomeScreenStudentState createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  late Future<List<dynamic>> _tutors;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tutors = fetchTutors();
  }

  Future<List<dynamic>> fetchTutors() async {
    final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/tutors/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tutors"];
    } else {
      throw Exception("Error al obtener la lista de tutores");
    }
  }

  void _navigateToStudentProfile() async {
    String? studentId = _userService.getId();
    if (studentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentProfileScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se encontró el perfil del estudiante.")),
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
            icon: const Icon(Icons.filter_list, color: Color(0xFF192650)),
            onPressed: () {
              // Implementar funcionalidad de filtrado aquí
            },
          ),
          IconButton(
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
            return ratingB.compareTo(ratingA); // Ordenar de mayor a menor
          });

          return ListView.builder(
            itemCount: tutorsList.length,
            itemBuilder: (context, index) {
              final tutor = tutorsList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Card(
                  color: Colors.white,
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
                              backgroundImage: tutor["profile_picture"].isNotEmpty
                                  ? MemoryImage(base64Decode(tutor["profile_picture"]))
                                  : null,
                              child: tutor["profile_picture"].isEmpty
                                  ? Text(
                                      tutor["name"][0],
                                      style: const TextStyle(color: Colors.white, fontSize: 20),
                                    )
                                  : null,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Subjects: ${tutor["subjects"].join(", ")}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Lógica para reservar el tutor o curso
                              print("Reservar tutor: ${tutor["name"]}");
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
