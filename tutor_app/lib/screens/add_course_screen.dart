import 'package:flutter/material.dart';
import 'tutor_estimate_price_screen.dart';

class AddCourseScreen extends StatefulWidget {
  final String? initialPrice; // Recibe el valor inicial

  const AddCourseScreen({super.key, this.initialPrice});

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

    // Si se recibe un valor inicial, lo mostramos directamente en el campo de precio
    if (widget.initialPrice != null) {
      _priceController.text = widget.initialPrice!;
    }

    _filteredUniversities = _universities;
  }

  void _filterUniversities(String query) {
    setState(() {
      _filteredUniversities = _universities
          .where((uni) => uni.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Función para navegar a la pantalla de estimación y recibir el valor
  Future<void> _navigateAndGetPrice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TutorEstimatePriceScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _priceController.text = result; // Mostrar el valor retornado
      });
    }
  }

  void _saveCourse() {
    String university = _universityController.text;
    String course = _courseController.text;
    String price = _priceController.text;

    if (university.isEmpty || course.isEmpty || price.isEmpty) {
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
          'TutorApp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Text(
              "¡Add a new course!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Universidad con Autocompletado
            const Text("University"),
            TextField(
              controller: _universityController,
              onChanged: _filterUniversities,
              decoration: InputDecoration(
                hintText: "Enter university",
                suffixIcon: _universityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
              SizedBox(
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
            const SizedBox(height: 15),

            // Campo de Curso
            const Text("Course name or code"),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                hintText: "Enter course name",
              ),
            ),
            const SizedBox(height: 15),

            // Campo de Precio
            const Text("Price"),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Set the price",
              ),
            ),
            const SizedBox(height: 10),

            // Nota sobre el estimador de precio
            const Text(
              "Hint: Tutors that use our price estimator increased their students in 20%.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Botón para abrir la pantalla de estimación
            ElevatedButton(
              onPressed: _navigateAndGetPrice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Use the estimator",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para guardar el curso
            Center(
              child: ElevatedButton(
                onPressed: _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
