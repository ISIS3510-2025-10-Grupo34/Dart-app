import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_app/screens/write_review_screen.dart';

class TutorProfile extends StatefulWidget {
  final int tutorId;

  const TutorProfile({super.key, required this.tutorId});

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfile> {
  late Future<Map<String, dynamic>> _tutorProfile;

  @override
  void initState() {
    super.initState();
    _tutorProfile = fetchTutorProfile(widget.tutorId);
  }

  Future<Map<String, dynamic>> fetchTutorProfile(int tutorId) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.8:8000/api/tutorprofile/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tutorId": tutorId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData["data"] ?? {};
      } else {
        throw Exception("Error al obtener el perfil del tutor");
      }
    } catch (e) {
      return Future.error("No se pudo conectar con el servidor");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tutorProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No se encontraron datos del tutor"));
          }

          final tutor = snapshot.data!;
          final profilePicture = tutor["profile_picture"] ?? "";
          final ratings = (tutor["ratings"] as num?)?.toDouble() ?? 0.0;
          final subjects = List<String>.from(tutor["subjects"] ?? []);
          final reviews = List<Map<String, dynamic>>.from(tutor["reviews"] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (profilePicture.isNotEmpty)
                            ? NetworkImage(profilePicture)
                            : null,
                        backgroundColor: const Color(0xFF192650),
                        child: profilePicture.isEmpty
                            ? Text(
                                tutor["name"][0].toUpperCase(),
                                style: const TextStyle(fontSize: 32, color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tutor["name"] ?? "Sin nombre",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tutor["university"] ?? "Universidad no especificada",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: ratings,
                        itemBuilder: (context, index) => const Icon(Icons.star, color: Color(0xFF192650)),
                        itemCount: 5,
                        itemSize: 24.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.whatsapp, color: Color(0xFF192650)),
                    const SizedBox(width: 10),
                    Text(
                      tutor["whatsapp_contact"] ?? "No disponible",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                "Subjects:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subjects.map((subject) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.book, color: Colors.blue.shade900),
                          const SizedBox(width: 10),
                          Text(subject, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                  );
                }).toList(),
              ),
                const SizedBox(height: 20),
                const Text("Reviews:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Evita que interfiera con el scroll principal
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF192650),
                        ),
                        title: RatingBarIndicator(
                          rating: (review["rating"] as num?)?.toDouble() ?? 0.0,
                          itemBuilder: (context, index) => const Icon(Icons.star, color: Color(0xFF192650)),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        subtitle: Text(review["comment"] ?? "Sin comentario"),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewScreen(tutorId: widget.tutorId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF192650),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text("Write a review", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
