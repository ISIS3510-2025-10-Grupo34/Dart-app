// lib/views/filter_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/filter_controller.dart';
import '../controllers/student_home_controller.dart';

class FilterModal extends StatefulWidget {
  final void Function(String university, String course, String professor) onFilter;

  const FilterModal({super.key, required this.onFilter});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late TextEditingController universityController;
  late TextEditingController courseController;
  late TextEditingController professorController;

  @override
  void initState() {
    super.initState();
    final filter = Provider.of<FilterController>(context, listen: false);

    universityController = TextEditingController(text: filter.universityInput);
    courseController = TextEditingController(text: filter.courseInput);
    professorController = TextEditingController(text: filter.professorInput);
  }

  @override
  void dispose() {
    universityController.dispose();
    courseController.dispose();
    professorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FilterController>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.7,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFFDF7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown("University", universityController, controller.universities,
                  (val) => controller.universityInput = val),
              const SizedBox(height: 12),
              _buildDropdown("Course", courseController, controller.courses,
                  (val) => controller.courseInput = val),
              const SizedBox(height: 12),
              _buildDropdown("Professor", professorController, controller.professors,
                  (val) => controller.professorInput = val),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      controller.clearInputs();
                      universityController.clear();
                      courseController.clear();
                      professorController.clear();

                      await Provider.of<StudentHomeController>(context, listen: false)
                          .clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Clear Filters"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      controller.universityInput = universityController.text;
                      controller.courseInput = courseController.text;
                      controller.professorInput = professorController.text;

                      widget.onFilter(
                        universityController.text,
                        courseController.text,
                        professorController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Filter", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(
    String label,
    TextEditingController externalController,
    List<String> options,
    void Function(String) onSelectedCallback,
  ) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return options.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (value) {
        externalController.text = value;
        onSelectedCallback(value);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text = externalController.text;

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) {
            externalController.text = value;
            onSelectedCallback(value);
          },
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                textEditingController.clear();
                externalController.clear();
                onSelectedCallback('');
              },
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF171F45)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
