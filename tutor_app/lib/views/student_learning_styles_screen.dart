import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/learning_styles_controller.dart';
import 'profile_picture_screen.dart';
import 'welcome_screen.dart';

class StudentLearningStylesScreen extends StatefulWidget {
  const StudentLearningStylesScreen({super.key});

  @override
  State<StudentLearningStylesScreen> createState() =>
      _LearningStylesScreenState();
}

class _LearningStylesScreenState extends State<StudentLearningStylesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller =
        Provider.of<LearningStylesController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return; // Safety check

      final state = controller.state;
      if (state == LearningStylesState.success) {
        // Navigate to next screen (Profile Picture Screen)
        Navigator.push(
          // Using push instead of pushAndRemoveUntil for this step
          context,
          MaterialPageRoute(builder: (context) => const ProfilePictureScreen()),
        );
        // Reset controller state after navigation is initiated
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to controller changes
    return Consumer<LearningStylesController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == LearningStylesState.loading;
        final errorMessage = (controller.state == LearningStylesState.error)
            ? controller.errorMessage
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Opacity(
              opacity: isLoading ? 0.7 : 1.0,
              child: AbsorbPointer(
                absorbing: isLoading,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "TutorApp",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      const Center(
                        child: Text(
                          "Select your preferred learning styles.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500, // Slightly bolder
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Read available styles from controller
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: controller.availableStyles.map((style) {
                          // Check selection status from controller
                          final isSelected =
                              controller.selectedStyles.contains(style);
                          return FilterChip(
                            label: Text(style),
                            selected: isSelected,
                            // Call controller method on selection change
                            onSelected: isLoading
                                ? null
                                : (bool selected) {
                                    controller.toggleStyle(style);
                                  },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF29339b),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                      const Spacer(flex: 1), // Ensure button stays low
                      // Display error message if any
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          // Disable button when loading, call controller method
                          onPressed: isLoading
                              ? null
                              : () {
                                  context
                                      .read<LearningStylesController>()
                                      .submitLearningStyles();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF171F45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          // Show loading indicator or text
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
                      const SizedBox(height: 32), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
