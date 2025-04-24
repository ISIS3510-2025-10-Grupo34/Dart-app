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

  String nearestUniversity = "Loading...";
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadNearestUniversity();
  }

  Future<void> _loadNearestUniversity() async {
    String result = await _controller.getNearestUniversity();

    if (result == "Sin conexión a internet") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🌐 There's no internet connection."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (result == "Ubicación no disponible") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📍 Your location is disabled. Check permissions."),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {
      nearestUniversity = result;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final place = _placeController.text.trim();

    if (title.isEmpty || message.isEmpty || place.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Missing fields. Please complete all fields before sending."),
        ),
      );
      return;
    }

    final now = TimeOfDay.now();
    final selectedTimeInMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
    final nowInMinutes = now.hour * 60 + now.minute;

    if (selectedTimeInMinutes <= nowInMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚫 The deadline time must be in the future."),
        ),
      );
      return;
    }

    final deadline = DateTime.now()
        .copyWith(hour: _selectedTime!.hour, minute: _selectedTime!.minute);

    final success = await _controller.sendNotification(
      title: title,
      message: message,
      place: place,
      university: nearestUniversity,
      deadline: deadline.toIso8601String(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Notification sent successfully."
              : "There was an error sending the notification. It was saved locally for later sending.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _titleController.clear();
      _messageController.clear();
      _placeController.clear();
      setState(() {
        _selectedTime = null;
      });
    }
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
        title: const Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? "⏰ Deadline: ${_selectedTime!.format(context)}"
                        : "⏰ Select deadline time",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text("Pick Time", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
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
