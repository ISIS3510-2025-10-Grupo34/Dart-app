import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/env_config.dart';

class WriteReviewScreen extends StatefulWidget {
  final int tutorId;

  const WriteReviewScreen({super.key, required this.tutorId});

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  Future<Map<String, dynamic>>? _tutorProfileFuture;

  @override
  void initState() {
    super.initState();
    _tutorProfileFuture = fetchTutorProfile(widget.tutorId);
  }

  Future<Map<String, dynamic>> fetchTutorProfile(int tutorId) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/tutorprofile/?tutorId=$tutorId'),
        //Uri.parse("http://192.168.1.8:8000/api/tutorprofile/?tutorId=$tutorId"),
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

  Future<void> submitReview() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.8:8000/api/submit-review/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tutorId": widget.tutorId,
          "rating": _rating,
          "comment": _reviewController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully!')),
        );
        _reviewController.clear();
        setState(() {
          _rating = 0.0;
        });
      } else {
        print("Error al enviar reseña: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _tutorProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error al cargar los datos"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No se encontró la información del tutor"));
            }

            final tutorData = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Write a review',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF192650)),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF192650),
                  backgroundImage: tutorData['profile_picture'] != ""
                      ? NetworkImage(tutorData['profile_picture'])
                      : null,
                  child: tutorData['profile_picture'] == ""
                      ? Text(tutorData['name'][0], style: TextStyle(fontSize: 32, color: Colors.white))
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  tutorData['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  tutorData['university'] ?? 'N/A',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 15),
                Text('Tap to Rate:', style: TextStyle(fontSize: 14)),
                SizedBox(height: 5),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(Icons.star, color: Color(0xFF192650)),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                SizedBox(height: 20),
                _buildInputField('Review', 'Write your review here...', _reviewController, maxLines: 3),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitReview,
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF192650),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF192650))),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
