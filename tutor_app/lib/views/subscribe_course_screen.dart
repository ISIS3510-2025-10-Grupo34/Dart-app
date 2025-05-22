import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/subscribe_controller.dart'; // Actual path

class SubscribeCourseScreen extends StatefulWidget {
  const SubscribeCourseScreen({super.key});

  @override
  State<SubscribeCourseScreen> createState() => _SubscribeCourseScreenState();
}

class _SubscribeCourseScreenState extends State<SubscribeCourseScreen> {
  // TextEditingControllers for DropdownMenu, similar to FilterModal
  // These will be updated based on controller's state and user selections.
  late TextEditingController _universityController;
  late TextEditingController _courseController;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<SubscribeCourseController>(context, listen: false);

    // Initialize TextEditingControllers with current values from the main controller (if any)
    // or empty if nothing is pre-selected.
    _universityController = TextEditingController(text: controller.selectedUniversity ?? '');
    _courseController = TextEditingController(text: controller.selectedCourse ?? '');

    // The controller's constructor already calls loadUniversities.
    // If a refresh is needed upon screen entry under certain conditions,
    // you might call controller.resetControllerState() or controller.loadUniversities() here.
    // For now, relying on controller's initial load.
    // Example: if(controller.universities.isEmpty) controller.loadUniversities();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  // Helper to build DropdownMenu for Strings, similar to FilterModal's _buildUniversityDropdown
  Widget _buildDropdownMenu({
    required BuildContext context,
    required SubscribeCourseController controller,
    required TextEditingController textEditingController,
    required List<String> entries,
    required String? initialSelection,
    required String hintText,
    required bool isLoading,
    required String? apiError,
    required String? selectionError,
    required void Function(String?) onSelected,
    required bool enabled,
  }) {
    // Update TextEditingController if the controller's selected value changes externally
    // This ensures sync if the controller's state is reset or changed elsewhere.
    // Note: This can cause cursor jumps if not handled carefully during user input.
    // A more robust way might be to listen to controller changes for specific fields.
    // For now, we set it when the widget rebuilds based on `initialSelection`.
    if (textEditingController.text != (initialSelection ?? '')) {
         textEditingController.text = initialSelection ?? '';
    }


    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          controller: textEditingController, // Use the screen's TextEditingController
          initialSelection: initialSelection, // From the main controller
          dropdownMenuEntries: entries.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(
              value: value,
              label: value,
            );
          }).toList(),
          onSelected: onSelected, // This will call methods on the main controller
          expandedInsets: EdgeInsets.zero,
          menuHeight: 300,
          hintText: hintText,
          enabled: enabled && !isLoading, // Also disable if loading
          inputDecorationTheme: _dropdownInputDecorationTheme(context),
          menuStyle: _dropdownMenuStyle(),
        ),
        if (apiError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(apiError, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        if (selectionError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(selectionError, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }


  InputDecorationTheme _dropdownInputDecorationTheme(BuildContext context) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder( // Style for disabled state
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      hintStyle: TextStyle(color: Colors.grey[600])
    );
  }

  MenuStyle _dropdownMenuStyle() {
    return MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<SubscribeCourseController>(
      builder: (context, controller, child) {
        // This ensures that if the controller's selectedUniversity/Course changes
        // (e.g., due to resetSuccessState), the local TextEditingControllers are updated.
        // This is a common pattern when using TextEditingControllers with external state.
        // However, be cautious as direct manipulation in build can sometimes lead to issues.
        // A listener in initState might be more robust for syncing.
        if (_universityController.text != (controller.selectedUniversity ?? '')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) _universityController.text = controller.selectedUniversity ?? '';
          });
        }
        if (_courseController.text != (controller.selectedCourse ?? '')) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) _courseController.text = controller.selectedCourse ?? '';
           });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Subscribe to a Course"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: const Color(0xFFFDF7FF),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Display General Error/Success Messages for Subscription Action ---
                  if (controller.state == SubscribeCourseState.error && controller.subscriptionError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        controller.subscriptionError!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (controller.state == SubscribeCourseState.success && controller.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        controller.successMessage!,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // --- University Dropdown ---
                  const Text("Select University", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildDropdownMenu(
                    context: context,
                    controller: controller,
                    textEditingController: _universityController,
                    entries: controller.universities,
                    initialSelection: controller.selectedUniversity,
                    hintText: 'Choose a university',
                    isLoading: controller.isLoadingUniversities,
                    apiError: controller.universityApiError,
                    selectionError: controller.universitySelectionError,
                    onSelected: (String? universityName) {
                      controller.selectUniversity(universityName);
                      // When university changes, clear the course text field controller
                      _courseController.clear(); 
                    },
                    enabled: true, // Always enabled, loading handled inside
                  ),
                  const SizedBox(height: 20),

                  // --- Course Dropdown ---
                  const Text("Select Course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildDropdownMenu(
                    context: context,
                    controller: controller,
                    textEditingController: _courseController,
                    entries: controller.courses,
                    initialSelection: controller.selectedCourse,
                    hintText: 'Choose a course',
                    isLoading: controller.isLoadingCourses,
                    apiError: controller.courseApiError,
                    selectionError: controller.courseSelectionError,
                    onSelected: (String? courseName) {
                      controller.selectCourse(courseName);
                    },
                    // Enable only if a university is selected and courses are available or loading
                    enabled: controller.selectedUniversity != null && controller.selectedUniversity!.isNotEmpty,
                  ),
                  if (controller.selectedUniversity == null || controller.selectedUniversity!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text("Please select a university first to see courses.", style: TextStyle(color: Colors.grey[600])),
                    ),


                  const SizedBox(height: 30),

                  // --- Subscribe Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (controller.selectedUniversity != null &&
                                controller.selectedCourse != null &&
                                controller.state != SubscribeCourseState.subscribing)
                        ? () {
                            controller.submitSubscription();
                          }
                        : null,
                    child: controller.state == SubscribeCourseState.subscribing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Subscribe to Course'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}