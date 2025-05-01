import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../controllers/write_review_controller.dart';
import '../models/tutoring_session_model.dart';
import '../services/tutoring_session_service.dart';
import '../models/review_model.dart';

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
  late final TutoringSessionService _sessionService;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  String tutorName = '';
  String tutorImage = '';
  TutoringSession? session;
  bool _isSubmitting = false;
  bool _alreadyReviewed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<WriteReviewController>();
    _sessionService = context.read<TutoringSessionService>();

    _getTutorInfo();
    _getSessionInfo();
    _checkIfAlreadyReviewed();
  }

  Future<void> _getTutorInfo() async {
    try {
      final profile = await _controller.getTutorProfile(widget.tutorId);
      setState(() {
        tutorName = profile['name'] ?? 'Tutor Name';
        tutorImage = profile['photoUrl'] ?? '';
      });
    } catch (_) {
      setState(() {
        tutorName = 'Tutor Name';
        tutorImage = '';
      });
    }
  }

  Future<void> _getSessionInfo() async {
    try {
      session = await _sessionService.fetchTutoringSessionById(widget.sessionId);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _checkIfAlreadyReviewed() async {
    final review = Review(
      tutoringSessionId: widget.sessionId,
      tutorId: widget.tutorId,
      studentId: widget.studentId,
      rating: 0,
      comment: '',
    );
    final alreadySent = await _controller.reviewAlreadySent(review);
    if (mounted) {
      setState(() {
        _alreadyReviewed = alreadySent;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || _alreadyReviewed) return; // Evitar múltiples envíos

    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty) {
      _showSnack('Please write a review.', Colors.red);
      return;
    }

    if (_rating == 0.0) {
      _showSnack('Please select a rating.', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _alreadyReviewed = true; // Marcar como revisado inmediatamente
    });

    final review = Review(
      tutoringSessionId: widget.sessionId,
      tutorId: widget.tutorId,
      studentId: widget.studentId,
      rating: _rating,
      comment: reviewText,
    );

    final success = await _controller.submitReview(
      tutoringSessionId: review.tutoringSessionId!,
      tutorId: review.tutorId!,
      studentId: review.studentId!,
      rating: review.rating,
      comment: review.comment,
    );

    if (success) {
      _showSnack('¡Your review was sent successfully!', Colors.green);
    } else {
      _showSnack(
        "There's no connection. Your review was saved and will be sent automatically when you're back online.",
        Colors.red,
      );
    }

    _reviewController.clear();
    setState(() {
      _rating = 0.0;
      _isSubmitting = false;
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
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
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true, // Ajustar contenido al teclado
      body: SafeArea(
        child: _alreadyReviewed
            ? const Center(
                child: Text(
                  'You already submitted a review for this session.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Write a review',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF192650),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF192650),
                        backgroundImage: tutorImage.isNotEmpty
                            ? NetworkImage(tutorImage)
                            : null,
                        child: tutorImage.isEmpty
                            ? Text(
                                tutorName.isNotEmpty ? tutorName[0] : 'T',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tutorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (session != null)
                        Text(
                          'Session: ${session!.dateTime}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 15),
                      const Text('Tap to Rate:'),
                      const SizedBox(height: 5),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Color(0xFF192650),
                        ),
                        onRatingUpdate: (rating) =>
                            setState(() => _rating = rating),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        'Review',
                        'Write your review here...',
                        _reviewController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _alreadyReviewed ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _alreadyReviewed
                              ? Colors.grey
                              : const Color(0xFF192650),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          _alreadyReviewed ? 'Review Submitted' : 'Submit',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF192650),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
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