import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/filter_controller.dart';
import '../controllers/student_home_controller.dart';
import '../utils/network_utils.dart';

class FilterModal extends StatefulWidget {
  final void Function(String university, String course, String professor) onFilter;

  const FilterModal({super.key, required this.onFilter});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late TextEditingController _universityController;
  late TextEditingController _courseController;
  late TextEditingController _professorController;

  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    final filterCtrl = Provider.of<FilterController>(context, listen: false);
    _universityController = TextEditingController(text: filterCtrl.universityInput);
    _courseController = TextEditingController(text: filterCtrl.courseInput);
    _professorController = TextEditingController(text: filterCtrl.professorInput);

    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final status = await NetworkUtils.hasInternetConnection();
    if (mounted) {
      setState(() {
        _hasInternet = status;
      });
    }
  }

  @override
  void dispose() {
    _universityController.dispose();
    _courseController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterCtrl = context.watch<FilterController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              if (!_hasInternet)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.red),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "No internet connection. Tutor filter is disabled and cannot be updated.",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: _checkConnectivity,
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                ),

              const Text("Select University", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildDropdown(
                context: context,
                controller: _universityController,
                entries: filterCtrl.universities,
                currentValue: filterCtrl.universityInput,
                hintText: 'Choose a university',
                onSelected: (value) async {
                  filterCtrl.universityInput = value ?? '';
                  _courseController.clear();
                  filterCtrl.courseInput = '';
                  await _checkConnectivity();
                  await filterCtrl.reloadCoursesForSelectedUniversity();
                },
                enabled: !filterCtrl.isLoading,
              ),

              const SizedBox(height: 20),
              const Text("Select Course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildDropdown(
                context: context,
                controller: _courseController,
                entries: filterCtrl.courses,
                currentValue: filterCtrl.courseInput,
                hintText: 'Choose a course',
                onSelected: (value) {
                  filterCtrl.courseInput = value ?? '';
                },
                enabled: filterCtrl.universityInput.isNotEmpty && !filterCtrl.isLoading,
              ),

              const SizedBox(height: 20),
              const Text("Select Professor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildDropdown(
                context: context,
                controller: _professorController,
                entries: filterCtrl.professors,
                currentValue: filterCtrl.professorInput,
                hintText: 'Choose a professor',
                onSelected: (value) {
                  filterCtrl.professorInput = value ?? '';
                },
                enabled: _hasInternet && filterCtrl.professors.isNotEmpty,
              ),

              if (!_hasInternet)
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, bottom: 20.0),
                  child: Text(
                    "Professor data could not be loaded because there is no internet connection.",
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final hasInternet = await NetworkUtils.hasInternetConnection();
                      if (!hasInternet && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No internet connection. Cannot clear filters."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      _universityController.clear();
                      _courseController.clear();
                      _professorController.clear();
                      filterCtrl.clearInputs();

                      await Provider.of<StudentHomeController>(context, listen: false).clearFiltersAndReload();

                      if (mounted) Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF171F45),
                      side: const BorderSide(color: Color(0xFF171F45)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text("Clear Filters"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final hasInternet = await NetworkUtils.hasInternetConnection();
                      if (!hasInternet && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Unable to apply filters. No internet connection."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final studentHomeCtrl = Provider.of<StudentHomeController>(context, listen: false);
                      await studentHomeCtrl.applyFilters(
                        university: _universityController.text.trim(),
                        course: _courseController.text.trim(),
                        tutorName: _professorController.text.trim(),
                      );

                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text("Filter"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDropdown({
    required BuildContext context,
    required TextEditingController controller,
    required List<String> entries,
    required String? currentValue,
    required String hintText,
    required void Function(String?) onSelected,
    required bool enabled,
  }) {
    if (controller.text != (currentValue ?? '')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.text = currentValue ?? '';
      });
    }

    return DropdownMenu<String>(
      controller: controller,
      initialSelection: currentValue,
      dropdownMenuEntries: entries.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
      onSelected: (value) {
        onSelected(value);
        if (value != null) {
          controller.text = value;
        } else {
          controller.clear();
        }
      },
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      hintText: entries.isEmpty ? 'No options available' : hintText,
      enabled: enabled && entries.isNotEmpty,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all<double>(3),
      ),
    );
  }
}
