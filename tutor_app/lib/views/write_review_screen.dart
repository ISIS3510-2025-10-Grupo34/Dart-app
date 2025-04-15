import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../controllers/write_review_controller.dart';

class WriteReviewScreen extends StatefulWidget {
  final int tutorId;
  final int studentId;
  final int sessionId;

  const WriteReviewScreen({
    super.key,
    required this.tutorId,
    required this.studentId,
    required this.sessionId,
  });

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final WriteReviewController _controller = WriteReviewController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  Future<Map<String, dynamic>>? _tutorProfileFuture;

  @override
  void initState() {
    super.initState();
    _tutorProfileFuture = _controller.getTutorProfile(widget.tutorId);
  }

  Future<void> _handleSubmit() async {
    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe una reseña antes de enviar.')),
      );
      return;
    }

    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una calificación.')),
      );
      return;
    }

    final success = await _controller.submitReview(
      tutoringSessionId: widget.sessionId,
      tutorId: widget.tutorId,
      studentId: widget.studentId,
      rating: _rating,
      comment: reviewText,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reseña enviada exitosamente!')),
      );
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar la reseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _tutorProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Error al cargar los datos del tutor"));
            }

            final tutorData = snapshot.data!;
            final String name = tutorData['name'] ?? 'Sin nombre';
            final String university = tutorData['university'] ?? 'Universidad no disponible';
            final String profilePicture = tutorData['profile_picture'] ?? "";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Write a review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF192650))),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF192650),
                  backgroundImage: profilePicture.isNotEmpty ? NetworkImage(profilePicture) : null,
                  child: profilePicture.isEmpty
                      ? Text(name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(fontSize: 32, color: Colors.white))
                      : null,
                ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(university, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 15),
                const Text('Tap to Rate:', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 5),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Color(0xFF192650)),
                  onRatingUpdate: (rating) => setState(() => _rating = rating),
                ),
                const SizedBox(height: 20),
                _buildInputField('Review', 'Write your review here...', _reviewController, maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192650),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF192650))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
