import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/utils/network_utils.dart';
import '../controllers/filter_controller.dart';
import '../controllers/student_home_controller.dart';

class FilterModal extends StatefulWidget {
  final void Function(String university, String course, String professor) onFilter;

  const FilterModal({
    super.key,
    required this.onFilter,
  });

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
    final filterCtrl = Provider.of<FilterController>(context, listen: false);

    universityController = TextEditingController(text: filterCtrl.universityInput);
    courseController = TextEditingController(text: filterCtrl.courseInput);
    professorController = TextEditingController(text: filterCtrl.professorInput);
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
    final filterCtrl = Provider.of<FilterController>(context);
    final studentHomeCtrl = Provider.of<StudentHomeController>(context, listen: false);

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
              _buildUniversityDropdown(filterCtrl),
              const SizedBox(height: 12),
              _buildCourseDropdown(filterCtrl),
              const SizedBox(height: 12),
              _buildProfessorDropdown(filterCtrl),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final hasInternet = await NetworkUtils.hasInternetConnection();
                      if (!hasInternet) {
                        if (mounted) {
                          Navigator.pop(context); // cierra modal
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No internet connection. Cannot clear filters."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      // Limpieza visual
                      universityController.clear();
                      courseController.clear();
                      professorController.clear();

                      // Limpieza lógica
                      final filterCtrl = Provider.of<FilterController>(context, listen: false);
                      filterCtrl.clearInputs();

                      // Recarga sesiones sin filtros
                      final studentHomeCtrl = Provider.of<StudentHomeController>(context, listen: false);
                      await studentHomeCtrl.clearFiltersAndUpdate();

                      if (mounted) Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF171F45),
                      side: const BorderSide(color: Color(0xFF171F45)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text("Clear Filters"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      final hasInternet = await NetworkUtils.hasInternetConnection();
                      if (!hasInternet) {
                        if (mounted) {
                          Navigator.pop(context); // Cerrar el modal primero
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Unable to apply filters. No internet connection.",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      filterCtrl.universityInput = universityController.text;
                      filterCtrl.courseInput = courseController.text;
                      filterCtrl.professorInput = professorController.text;
                      widget.onFilter(
                        universityController.text,
                        courseController.text,
                        professorController.text,
                      );
                      Navigator.pop(context); // Solo si sí hay internet
                    },

                    child: const Text("Filter"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildUniversityDropdown(FilterController controller) {
  final List<String> universities = controller.universities;
  final String? selectedValue = controller.universityInput;

  return DropdownMenu<String>(
    controller: universityController,
    initialSelection: selectedValue,
    dropdownMenuEntries: universities.map<DropdownMenuEntry<String>>((String value) {
      return DropdownMenuEntry<String>(
        value: value,
        label: value,
      );
    }).toList(),
    onSelected: (String? value) {
      if (value != null) {
        universityController.text = value;
        controller.universityInput = value;
        controller.reloadCoursesForSelectedUniversity(); // Si has implementado esta función
      }
    },
    expandedInsets: EdgeInsets.zero,
    menuHeight: 300,
    hintText: 'Select University',
    inputDecorationTheme: InputDecorationTheme(
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
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  );
}

Widget _buildCourseDropdown(FilterController controller) {
  final List<String> courses = controller.courses;
  final String? selectedValue = controller.courseInput;

  return DropdownMenu<String>(
    controller: courseController,
    initialSelection: selectedValue,
    dropdownMenuEntries: courses.map<DropdownMenuEntry<String>>((String value) {
      return DropdownMenuEntry<String>(
        value: value,
        label: value,
      );
    }).toList(),
    onSelected: (String? value) {
      if (value != null) {
        courseController.text = value;
        controller.courseInput = value;
      }
    },
    expandedInsets: EdgeInsets.zero,
    menuHeight: 300,
    hintText: 'Select Course',
    inputDecorationTheme: InputDecorationTheme(
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
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  );
}

Widget _buildProfessorDropdown(FilterController controller) {
  final List<String> professors = controller.professors;
  final String? selectedValue = controller.professorInput;

  return DropdownMenu<String>(
    controller: professorController,
    initialSelection: selectedValue,
    dropdownMenuEntries: professors.map<DropdownMenuEntry<String>>((String value) {
      return DropdownMenuEntry<String>(
        value: value,
        label: value,
      );
    }).toList(),
    onSelected: (String? value) {
      if (value != null) {
        professorController.text = value;
        controller.professorInput = value;
      }
    },
    expandedInsets: EdgeInsets.zero,
    menuHeight: 300,
    hintText: 'Select Professor',
    inputDecorationTheme: InputDecorationTheme(
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
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  );
}
}
