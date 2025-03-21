import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _courses;

  @override
  void initState() {
    super.initState();
    _courses = _courseService.getCourses(); // Llamar a la API para obtener cursos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TutorApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.blue.shade900),
            onPressed: () {
              // Agregar funcionalidad de filtro aquí
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.blue.shade900),
            onPressed: () {
              // Navegar a la página de perfil
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load courses'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available'));
          }

          // Mostrar la lista de cursos dinámicamente
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final course = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.purple.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade900,
                          child: Text(course.tutorName[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(course.tutorName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(course.university),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.courseName,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(course.major,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 5),
                            Text('COP ${course.price.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica para reservar el curso
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text('Book'),
                          ),
                        ),
                      ),
                    ],
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
