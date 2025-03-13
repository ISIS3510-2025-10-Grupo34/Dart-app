import 'package:flutter/material.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _universities = [
    "Universidad de Los Andes",
    "Universidad Nacional",
    "Pontificia Universidad Javeriana",
    "Universidad del Rosario"
  ];

  List<String> _filteredUniversities = [];

  @override
  void initState() {
    super.initState();
    _filteredUniversities = _universities;
  }

  void _filterUniversities(String query) {
    setState(() {
      _filteredUniversities = _universities
          .where((uni) => uni.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TutorApp",style: TextStyle( fontSize: 24,fontWeight: FontWeight.w500,)),
        backgroundColor:  Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Add a new course!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color:  Color(0xFF192650)),
            ),
            SizedBox(height: 20),
            
            // Campo de Universidad con Autocompletado
            Text("University"),
            TextField(
              controller: _universityController,
              onChanged: _filterUniversities,
              decoration: InputDecoration(
                hintText: "Enter university",
                suffixIcon: _universityController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _universityController.clear();
                            _filteredUniversities = _universities;
                          });
                        },
                      )
                    : null,
              ),
            ),
            if (_universityController.text.isNotEmpty)
              Container(
                height: 100,
                child: ListView(
                  children: _filteredUniversities.map((uni) {
                    return ListTile(
                      title: Text(uni),
                      onTap: () {
                        setState(() {
                          _universityController.text = uni;
                          _filteredUniversities = _universities;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            
            SizedBox(height: 15),

            // Campo de Curso
            Text("Course name or code"),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(hintText: "Enter course name"),
            ),
            
            SizedBox(height: 15),

            // Campo de Precio
            Text("Price"),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Set the price"),
            ),

            SizedBox(height: 10),
            Text(
              "Hint: Tutors that use our price estimator increased their students in 20%.",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implementar funcionalidad del estimador de precios
              },
              child: Text("Use the estimator"),
              style: ElevatedButton.styleFrom(backgroundColor:  Color(0xFF192650)),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implementar acción de guardar curso
                },
                child: Text("Save"),
                style: ElevatedButton.styleFrom(backgroundColor:  Color(0xFF192650)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
