import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';  
import '../controllers/write_review_controller.dart';  
import 'student_profile_screen.dart';

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
  late final WriteReviewController _controller;  

  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<WriteReviewController>();
  }

  Future<void> _handleSubmit() async {
    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review.')),
      );
      return;
    }

    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating.')),
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
        const SnackBar(
          content: Text('¡Your review was sent succesfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️There's no connection. Your review was saved and will be sent automatically when you are back online."),
          backgroundColor: Colors.orange,
        ),
      );
    }

    _reviewController.clear();
    setState(() {
      _rating = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Write a review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF192650))),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF192650),
              child: Text('T', style: TextStyle(fontSize: 32, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            const Text('Tutor Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
