import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/screens/connect_students_screen.dart';
import 'tutor_reviews.dart';

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
    _tutors = fetchTutors();
  }

  Future<List<dynamic>> fetchTutors() async {
    final response = await http.get(Uri.parse("http://192.168.1.8:8000/api/tutors/"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tutors"];
    } else {
      throw Exception("Error al obtener la lista de tutores");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TutorApp",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF192650)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF192650)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectStudentsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF192650)), // Ícono de filtro agregado
            onPressed: () {
              // Implementar funcionalidad de filtrado aquí
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF192650)),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _tutors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error al cargar los tutores"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay tutores disponibles"));
          }

          final tutors = snapshot.data!;

          return ListView.builder(
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              double rating = double.tryParse(tutor["average_rating"]?.toString() ?? "0.0") ?? 0.0;

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
                              backgroundColor: Color(0xFF192650),
                              backgroundImage: tutor["profile_picture"].isNotEmpty
                                  ? MemoryImage(base64Decode(tutor["profile_picture"]))
                                  : null,
                              child: tutor["profile_picture"].isEmpty
                                  ? Text(
                                      tutor["name"][0],
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    )
                                  : null,
                            ),
                          ),
                          title: Text(
                            tutor["name"],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            tutor["university"],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Subjects: ${tutor["subjects"].join(", ")}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.book_online, size: 18),
                            label: Text('Book'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF192650),
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
