import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/student_sign_in_controller.dart';
import 'student_learning_styles_screen.dart';
import '../providers/sign_in_process_provider.dart';

class StudentSignInScreen extends StatefulWidget {
  const StudentSignInScreen({super.key});

  @override
  _StudentSignInState createState() => _StudentSignInState();
}

class _StudentSignInState extends State<StudentSignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _universityMenuController =
      TextEditingController();
  final TextEditingController _majorMenuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    signInProcessProvider.loadSignUpProgress().then((_) {
      _nameController.text = signInProcessProvider.savedName ?? '';
      _phoneNumberController.text =
          signInProcessProvider.savedPhoneNumber ?? '';
      _majorMenuController.text = signInProcessProvider.savedMajor ?? '';
      _universityMenuController.text =
          signInProcessProvider.savedUniversity ?? '';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller =
        Provider.of<StudentSignInController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return; // Safety check

      final state = controller.state;
      if (state == StudentSignInState.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const StudentLearningStylesScreen()),
          (route) => false,
        );
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentSignInController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == StudentSignInState.loading;
        final nameError = (controller.state == StudentSignInState.error)
            ? controller.nameError
            : null;
        final phoneError = (controller.state == StudentSignInState.error)
            ? controller.phoneError
            : null;
        final generalError = (controller.state == StudentSignInState.error)
            ? controller.generalError
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Opacity(
              opacity: isLoading ? 0.7 : 1.0, // Dim UI while loading
              child: AbsorbPointer(
                absorbing: isLoading, // Prevent interaction while loading
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    // Added SingleChildScrollView
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            "TutorApp",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Adjusted spacing
                        const Center(
                          child: Text(
                            "Student",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF171F45),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "We would like to know more about you",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          onChanged: (_) => controller.clearInputErrors(),
                          decoration: InputDecoration(
                            hintText: 'First and last name',
                            errorText: nameError, // Read from controller
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneNumberController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.phone, // Use phone type
                          onChanged: (_) => controller.clearInputErrors(),
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            errorText: phoneError, // Read from controller
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUniversityDropdown(controller),
                        if (controller.universityError != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              controller.universityError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildMajorDropdown(controller),
                        if (controller.majorError != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              controller.majorError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16), // Spacing before error
                        // Display general error message if any
                        if (generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              generalError,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 8), // Spacing after error
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<StudentSignInController>()
                                        .submitStudentDetails(
                                          name: _nameController.text,
                                          phoneNumber:
                                              _phoneNumberController.text,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            // Show loading indicator based on controller state
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3)
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40), // Adjusted spacing
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _universityMenuController.dispose();
    _majorMenuController.dispose();
    super.dispose();
  }

  Widget _buildUniversityDropdown(dynamic controller) {
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    if (signInProcessProvider.savedUniversity != null) {
      controller.selectUniversity(signInProcessProvider.savedUniversity);
    }
    final List<String> universities = controller.universities;
    final String? selectedValue = controller.selectedUniversity;
    final Function(String?) onSelectedUpdate = controller.selectUniversity;

    return DropdownMenu<String>(
      controller: _universityMenuController,
      initialSelection: selectedValue,
      dropdownMenuEntries:
          universities.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onSelected: (String? value) {
        onSelectedUpdate(value);
      },
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      hintText: 'Select University',
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    );
  }

  Widget _buildMajorDropdown(dynamic controller) {
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    if (signInProcessProvider.savedMajor != null) {
      controller.selectMajor(signInProcessProvider.savedMajor);
    }
    final List<String> majors = controller.majors;
    final String? selectedValue = controller.selectedMajor;
    final bool isLoading = controller.isLoadingMajors;
    final Function(String?) onSelectedUpdate = controller.selectMajor;
    final String? apiError = controller.majorApiError;
    final bool isEnabled =
        controller.selectedUniversity != null && !isLoading && apiError == null;

    if (apiError != null && controller.selectedUniversity != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Could not load majors: $apiError", // Show specific error
          style: const TextStyle(color: Colors.red, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (isLoading && controller.selectedUniversity != null) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }
    return DropdownMenu<String>(
      controller: _majorMenuController,
      initialSelection: selectedValue,
      dropdownMenuEntries:
          majors.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onSelected: (String? value) {
        onSelectedUpdate(value);
      },
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      hintText: 'Select Major',
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    );
  }
}
