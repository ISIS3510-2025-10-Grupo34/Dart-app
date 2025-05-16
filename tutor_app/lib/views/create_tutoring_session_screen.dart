import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tutor_profile_controller.dart';
import 'package:intl/intl.dart';

class CreateTutoringSessionScreen extends StatefulWidget {
  const CreateTutoringSessionScreen({super.key});

  @override
  State<CreateTutoringSessionScreen> createState() => _CreateTutoringSessionScreenState();
}

class _CreateTutoringSessionScreenState extends State<CreateTutoringSessionScreen> {
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  String? _selectedCourse;
  String? _priceError;
  String? _dateTimeError;
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _universityController.dispose();
    _priceController.dispose();
    _dateTimeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TutorProfileController>(context);
    final universities = controller.universities;
    final courseNames = controller.courses.map((c) => c.course_name).toList();

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
              const Text("Create a tutoring session", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              _buildUniversityField(universities),
              const SizedBox(height: 16),
              _buildCourseDropdown(courseNames),
              const SizedBox(height: 16),
              _buildPriceField(controller),
              const SizedBox(height: 8),
              const Text(
                "Hint: Tutors that use our price estimator increased their students in 20%",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_universityController.text.trim().isNotEmpty && _selectedCourse != null)
                    ? () async {
                        try {
                          final controller = Provider.of<TutorProfileController>(context, listen: false);
                          final university = _universityController.text.trim();

                          final estimatedPrice = await controller.getEstimatedPrice(university);

                          setState(() {
                            _priceController.text = estimatedPrice.toString();
                            _priceError = null;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Estimated price set: $estimatedPrice COP")),
                          );
                        } catch (e) {
                          _showError("Failed to estimate price: $e");
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171F45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  foregroundColor: Colors.white, 
                  disabledForegroundColor: Colors.black45, 
                ),
                child: const Text("Use the estimator"),
              ),

              const SizedBox(height: 24),
              _buildDateTimeField(controller),
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

  Widget _buildUniversityField(List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("University", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            return options.where((option) => option.toLowerCase().contains(value.text.toLowerCase()));
          },
          onSelected: (value) async {
            _universityController.text = value;
            _selectedCourse = null;
            await _loadCourses(value);
            setState(() {});
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.text = _universityController.text;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (val) {
                _universityController.text = val;
              },
              decoration: InputDecoration(
                hintText: "Select University",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    _universityController.clear();
                    _selectedCourse = null;
                    Provider.of<TutorProfileController>(context, listen: false).clearCourses();
                    setState(() {});
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

  Widget _buildCourseDropdown(List<String> options) {
    final isUniversitySelected = _universityController.text.trim().isNotEmpty;

    final focusNode = FocusNode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Course", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: !isUniversitySelected,
          child: Opacity(
            opacity: isUniversitySelected ? 1.0 : 0.5,
            child: RawAutocomplete<String>(
              focusNode: focusNode,
              textEditingController: _courseController,
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) {
                  return options;
                }
                return options.where((option) => option.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (String value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: fieldFocusNode,
                  enabled: isUniversitySelected,
                  decoration: InputDecoration(
                    hintText: isUniversitySelected ? "Select Course" : "Select a university first",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        setState(() => _selectedCourse = null);
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 48,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(TutorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Price", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Set the price (COP/hour)",
            errorText: _priceError ?? controller.costValidationError,
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

  Widget _buildDateTimeField(TutorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date and time of availability", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        TextField(
          controller: _dateTimeController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Select date and time",
            errorText: _dateTimeError ?? controller.dateTimeValidationError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDateTime,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (selected.isBefore(DateTime.now())) {
      setState(() {
        _dateTimeError = "Cannot select a date and time in the past. Please select a future date and time.";
      });
      return;
    }

    setState(() {
      _selectedDateTime = selected;
      _dateTimeError = null;
      _dateTimeController.text = DateFormat("dd/MM/yyyy - HH:mm").format(selected);
    });
  }

  Future<void> _loadCourses(String university) async {
    try {
      final controller = Provider.of<TutorProfileController>(context, listen: false);
      await controller.fetchCoursesForUniversity(university);
      _courseController.clear();
      _selectedCourse = null;
      setState(() {});
    } catch (e) {
      _showError("Failed to load courses: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _handleSubmit() async {
    final controller = Provider.of<TutorProfileController>(context, listen: false);
    final university = _universityController.text.trim();
    final price = _priceController.text.trim();
    final course = _selectedCourse;
    final dateTime = _selectedDateTime;

    await controller.validateAndCreateSession(
      universityName: university,
      courseName: course ?? '',
      costText: price,
      dateTime: dateTime,
    );

    if (controller.creationState == SessionCreationState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tutoring session created successfully!")),
      );
      Navigator.pop(context);
    } else if (controller.creationState == SessionCreationState.error) {
      _showError(controller.creationError ?? "An unexpected error occurred.");
    }

    setState(() {
      _priceError = controller.costValidationError;
      _dateTimeError = controller.dateTimeValidationError;
    });
  }

}