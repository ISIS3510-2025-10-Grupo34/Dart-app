import 'package:flutter/material.dart';
import '../controllers/connect_students_controller.dart';

class ConnectStudentsScreen extends StatefulWidget {
  const ConnectStudentsScreen({super.key});

  @override
  State<ConnectStudentsScreen> createState() => _ConnectStudentsScreenState();
}

class _ConnectStudentsScreenState extends State<ConnectStudentsScreen> {
  final ConnectStudentsController _controller = ConnectStudentsController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  String nearestUniversity = "Cargando...";

  @override
  void initState() {
    super.initState();
    _loadNearestUniversity();
  }

  Future<void> _loadNearestUniversity() async {
    String result = await _controller.getNearestUniversity();
    setState(() {
      nearestUniversity = result;
    });
  }

  Future<void> _handleSendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final place = _placeController.text.trim();

    if (title.isEmpty || message.isEmpty || place.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        "Campos incompletos. Por favor completa el título, mensaje y lugar antes de enviar."),
      ));
      return;
    }

    final success = await _controller.sendNotification(
      title: title,
      message: message,
      place: place,
      university: nearestUniversity,
    );

    _showDialog(
      success ? "Éxito" : "Error",
      success ? "Notificación enviada correctamente." : "Hubo un error al enviar la notificación.",
    );

    if (success) {
      _titleController.clear();
      _messageController.clear();
      _placeController.clear();
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF192650))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $label",
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TutorApp",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Connect with nearest students',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF192650)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Invite students to your sessions.\nTutorApp sends a notification based on your nearest university location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              'Nearest University: $nearestUniversity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildInputField('Title', _titleController),
            const SizedBox(height: 10),
            _buildInputField('Message', _messageController),
            const SizedBox(height: 10),
            _buildInputField('Place', _placeController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192650),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
