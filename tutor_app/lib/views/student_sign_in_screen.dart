import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/student_sign_in_controller.dart';
import 'student_learning_styles_screen.dart';

class StudentSignInScreen extends StatefulWidget {
  const StudentSignInScreen({super.key});

  @override
  _StudentSignInState createState() => _StudentSignInState();
}

class _StudentSignInState extends State<StudentSignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // Removed UserService instance

  @override
  void initState() {
    super.initState();
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
          (route) => false, // Remove all previous routes
        );
        // Reset controller state after navigation is initiated
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get controller state and rebuild on changes
    return Consumer<StudentSignInController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == StudentSignInState.loading;
        final nameError = (controller.state == StudentSignInState.error)
            ? controller.nameError
            : null;
        final phoneError = (controller.state == StudentSignInState.error)
            ? controller.phoneError
            : null;
        final universityError = (controller.state == StudentSignInState.error)
            ? controller.universityError
            : null;
        final majorError = (controller.state == StudentSignInState.error)
            ? controller.majorError
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
                            // Consider navigation behavior - maybe pop or go to welcome?
                            // For now, just pop if possible
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            // Or navigate specifically:
                            // Navigator.of(context).pushAndRemoveUntil(
                            //   MaterialPageRoute(builder: (context) => const WelcomeScreen()), // Assuming WelcomeScreen exists
                            //   (route) => false,
                            // );
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
                        TextField(
                          controller: _universityController,
                          enabled: !isLoading,
                          onChanged: (_) => controller.clearInputErrors(),
                          decoration: InputDecoration(
                            hintText: 'University',
                            errorText: universityError, // Read from controller
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
                          controller: _majorController,
                          enabled: !isLoading,
                          onChanged: (_) => controller.clearInputErrors(),
                          decoration: InputDecoration(
                            hintText: 'Major',
                            errorText: majorError, // Read from controller
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
                            // Disable button when loading, call controller on press
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<StudentSignInController>()
                                        .submitStudentDetails(
                                          name: _nameController.text,
                                          phoneNumber:
                                              _phoneNumberController.text,
                                          university:
                                              _universityController.text,
                                          major: _majorController.text,
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
    _universityController.dispose();
    _majorController.dispose();
    _phoneNumberController.dispose();
    // Note: The controller itself is managed by Provider
    super.dispose();
  }
}
