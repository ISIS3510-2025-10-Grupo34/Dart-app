import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';
import 'tutor_reviews.dart';
import 'connect_students_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _tutors;

  @override
  void initState() {
    super.initState();
    _tutors = fetchTutors(); // ✅ Inicializar con todos los tutores
  }

  // ✅ FUNCION PARA OBTENER TODOS LOS TUTORES
  Future<List<dynamic>> fetchTutors() async {
    final response = await http.get(Uri.parse('${EnvConfig.apiUrl}/api/tutors/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tutors"];
    } else {
      throw Exception("Error al obtener la lista de tutores");
    }
  }

  // ✅ FUNCION PARA OBTENER TUTORES FILTRADOS
  Future<List<dynamic>> fetchFilteredTutors({
    String? university,
    String? course,
    String? tutor,
  }) async {
    String url = '${EnvConfig.apiUrl}/api/tutors/filter/?';

    if (university != null && university.isNotEmpty) {
      url += 'university=$university&';
    }
    if (course != null && course.isNotEmpty) {
      url += 'course=$course&';
    }
    if (tutor != null && tutor.isNotEmpty) {
      url += 'tutor=$tutor&';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tutors"];
    } else {
      throw Exception("Error al obtener la lista de tutores filtrados");
    }
  }

  // ✅ MODAL PARA FILTRAR TUTORES
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return FilterBottomSheet(
          onApplyFilters: (String university, String course, String tutor) {
            setState(() {
              _tutors = fetchFilteredTutors(
                university: university,
                course: course,
                tutor: tutor,
              );
            });
          },
        );
      },
    );
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
            icon: const Icon(Icons.notifications, color: Color(0xFF192650)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectStudentsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF192650)),
            onPressed: _showFilterModal,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF192650)),
            onPressed: () {},
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

          // ✅ Ordenar por calificación (de mayor a menor)
          tutorsList.sort((a, b) {
            double ratingA = double.tryParse(a["ratings"]?.toString() ?? "0.0") ?? 0.0;
            double ratingB = double.tryParse(b["ratings"]?.toString() ?? "0.0") ?? 0.0;
            return ratingB.compareTo(ratingA);
          });

          return ListView.builder(
            itemCount: tutorsList.length,
            itemBuilder: (context, index) {
              final tutor = tutorsList[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
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

// ✅ FILTRO ACTUALIZADO CON BOTÓN "APPLY FILTER"
class FilterBottomSheet extends StatefulWidget {
  final Function(String university, String course, String tutor) onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _universityController = TextEditingController();
  final _courseController = TextEditingController();
  final _professorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: _universityController, decoration: InputDecoration(labelText: 'University')),
          const SizedBox(height: 12),
          TextField(controller: _courseController, decoration: InputDecoration(labelText: 'Course')),
          const SizedBox(height: 12),
          TextField(controller: _professorController, decoration: InputDecoration(labelText: 'Tutor')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                _universityController.text,
                _courseController.text,
                _professorController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filter'),
          ),
        ],
      ),
    );
  }
}
