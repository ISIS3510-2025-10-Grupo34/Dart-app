// lib/views/filter_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/filter_controller.dart';

class FilterModal extends StatelessWidget {
  final void Function(String university, String course, String professor) onFilter;

  const FilterModal({super.key, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FilterController>(context);

    final universityController = TextEditingController();
    final courseController = TextEditingController();
    final professorController = TextEditingController();

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
              _buildDropdown("University", universityController, controller.universities),
              const SizedBox(height: 12),
              _buildDropdown("Course", courseController, controller.courses),
              const SizedBox(height: 12),
              _buildDropdown("Professor", professorController, controller.professors),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () {
                    onFilter(
                      universityController.text,
                      courseController.text,
                      professorController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Filter", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(String label, TextEditingController controller, List<String> options) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return options.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (value) {
        controller.text = value;
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                textEditingController.clear();
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