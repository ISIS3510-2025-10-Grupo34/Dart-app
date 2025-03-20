import 'package:flutter/material.dart';

class ConnectStudentsScreen extends StatelessWidget {
  const ConnectStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("TutorApp",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,)),
        backgroundColor:  Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Connect with nearest students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:  Color(0xFF192650)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Invite students to your sessions.\nTutorApp users in a radio of 100mts will receive the message.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            _buildInputField('Title', ''),
            SizedBox(height: 10),
            _buildInputField('Message', ''),
            SizedBox(height: 10),
            _buildInputField('Place', ''),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Acción al presionar "Send"
                },
                child: Text('Send',style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF192650),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de entrada
  Widget _buildInputField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color:  Color(0xFF192650))),
        SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
