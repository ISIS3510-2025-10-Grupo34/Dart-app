import 'package:flutter/material.dart';
import 'tutor_estimate_price_screen.dart';

class AddCourseScreen extends StatefulWidget {
  final String? initialPrice;

  const AddCourseScreen({super.key, this.initialPrice});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _universities = [
    "Universidad de Los Andes",
    "Universidad Nacional",
    "Pontificia Universidad Javeriana",
    "Universidad del Rosario"
  ];

  String? _selectedUniversity;

  @override
  void initState() {
    super.initState();

    if (widget.initialPrice != null) {
      _priceController.text = widget.initialPrice!;
    }
  }

  Future<void> _navigateAndGetPrice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TutorEstimatePriceScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _priceController.text = result;
      });
    }
  }

  void _saveCourse() {
    String? university = _selectedUniversity;
    String course = _courseController.text;
    String price = _priceController.text;

    if (university == null || course.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Course '$course' at '$university' saved with price: $price COP"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TutorApp",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Add a new course!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF192650)),
            ),
            const SizedBox(height: 20),

            const Text("University"),
            DropdownButtonFormField<String>(
              value: _selectedUniversity,
              decoration: InputDecoration(
                hintText: 'Select university',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: _universities.map((String university) {
                return DropdownMenuItem<String>(
                  value: university,
                  child: Text(university),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUniversity = newValue;
                });
              },
            ),
            const SizedBox(height: 15),

            const Text("Course name or code"),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                hintText: "Enter course name",
              ),
            ),
            const SizedBox(height: 15),

            const Text("Price"),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Set the price",
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Hint: Tutors that use our price estimator increased their students in 20%.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _navigateAndGetPrice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF192650),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Use the estimator"),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF192650),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
