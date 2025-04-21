import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tutor_profile_controller.dart';

class CreateTutoringSessionScreen extends StatefulWidget {
  const CreateTutoringSessionScreen({super.key});

  @override
  State<CreateTutoringSessionScreen> createState() => _CreateTutoringSessionScreenState();
}

class _CreateTutoringSessionScreenState extends State<CreateTutoringSessionScreen> {
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> universities = ['Universidad de Los Andes', 'Pontificia Universidad Javeriana'];
  final Map<String, List<String>> coursesByUniversity = {
    'Universidad de Los Andes': ['Programación', 'Álgebra Lineal'],
    'Pontificia Universidad Javeriana': ['Estadística', 'Cálculo'],
  };

  String? _priceError;

  List<String> get filteredCourses {
    final uni = _universityController.text;
    return coursesByUniversity[uni] ?? [];
  }

  @override
  void dispose() {
    _universityController.dispose();
    _courseController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TutorApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              const Text("¡Add a new course!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),

              _buildAutocompleteField("University", _universityController, universities),
              const SizedBox(height: 16),
              _buildAutocompleteField("Course", _courseController, filteredCourses),
              const SizedBox(height: 16),

              _buildPriceField(),

              const SizedBox(height: 8),
              const Text(
                "Hint: Tutors that use our price estimator increased their students in 20%.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // Lógica estimador
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171F45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Use the estimator"),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(String label, TextEditingController controller, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            return options.where((option) =>
                option.toLowerCase().contains(value.text.toLowerCase()));
          },
          onSelected: (value) {
            controller.text = value;
            setState(() {}); // Para refrescar la lista de cursos si cambia universidad
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (val) {
                controller.text = val;
                if (controller == _universityController) {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: "Select $label",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    controller.clear();
                    if (controller == _universityController) {
                      setState(() {}); // Reset cursos
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Price", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Set the price",
            errorText: _priceError,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _priceController.clear(),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  
  int _generateCourseId(String university, String course) {
    // ⚠️ Esta lógica debe adaptarse a cómo tu backend espera los IDs
    return university.hashCode ^ course.hashCode;
  }

  void _handleSubmit() async {
    setState(() => _priceError = null);

    final university = _universityController.text.trim();
    final course = _courseController.text.trim();
    final price = _priceController.text.trim();

    if (!universities.contains(university)) {
      _showError("Please select a valid university from the list.");
      return;
    }

    final validCourses = coursesByUniversity[university] ?? [];
    if (!validCourses.contains(course)) {
      _showError("Please select a valid course from the list.");
      return;
    }

    final parsedPrice = double.tryParse(price);
    if (parsedPrice == null) {
      setState(() {
        _priceError = "Please enter a valid number.";
      });
      return;
    }

    try {
      final controller = Provider.of<TutorProfileController>(context, listen: false);
      final courseId = _generateCourseId(university, course); // Simula ID único o lo mapea
      final dateTime = DateTime.now().toIso8601String(); // Aquí podrías usar DateTimePicker si lo deseas

      await controller.createTutoringSession(
        cost: parsedPrice.toInt(),
        dateTime: dateTime,
        courseId: courseId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tutoring session created successfully!")),
      );

      Navigator.pop(context); // Regresar después de guardar
    } catch (e) {
      _showError("Failed to create session: ${e.toString()}");
    }
  }

}
