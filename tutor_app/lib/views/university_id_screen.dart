import 'dart:io'; // Keep for File operations
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/university_id_controller.dart';
import 'login_screen.dart';
import 'welcome_screen.dart'; // Keep WelcomeScreen for potential error navigation if desired
import '../providers/sign_in_process_provider.dart';

class UniversityIDScreen extends StatefulWidget {
  const UniversityIDScreen({super.key});

  @override
  State<UniversityIDScreen> createState() => _UniversityIDScreenState();
}

class _UniversityIDScreenState extends State<UniversityIDScreen> {
  // Keep track if the queuing message has been shown to avoid duplicates
  bool _isQueuedMessageShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationAndStateListener(); // Renamed for clarity
    });
  }

  // Consolidate listener logic
  void _setupNavigationAndStateListener() {
    final signInProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    final controller =
        Provider.of<UniversityIdController>(context, listen: false);

    signInProvider.addListener(() {
      if (!mounted) return;

      final submissionState = signInProvider.submissionState;
      final submissionError = signInProvider.submissionError;

      // --- Handle states from SignInProcessProvider ---
      if (submissionState == RegistrationSubmissionState.success) {
        // Hide any persistent snackbar if shown
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registration successful! Please log in."),
              backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        // Reset both provider and controller states
        signInProvider.reset();
        controller
            .resetControllerState(); // Modified controller reset method needed
        _isQueuedMessageShown = false; // Reset flag
      } else if (submissionState == RegistrationSubmissionState.queuedOffline) {
        // Only show the persistent message once
        if (!_isQueuedMessageShown) {
          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar(); // Hide previous messages
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(submissionError ??
                  "No connection. Registration queued. Will send when online."),
              backgroundColor: Colors.orange,
              duration: const Duration(
                  days:
                      1), // Show indefinitely until success/error/manual dismissal
            ),
          );
          _isQueuedMessageShown = true;
          // No navigation, stay on screen. Button state handled in build method.
        }
      } else if (submissionState == RegistrationSubmissionState.error &&
          submissionError != null) {
        // Hide persistent queue message if it was shown
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Registration Failed: $submissionError. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        _isQueuedMessageShown = false; // Reset flag
        // Stay on the screen, reset controller to allow retry
        controller.resetControllerState(); // Let user retry picking/submitting
        // Keep signInProvider error state until user retries
      } else if (submissionState == RegistrationSubmissionState.idle) {
        // If state resets to idle (e.g., after error and retry prep), hide messages
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _isQueuedMessageShown = false;
      }

      // We trigger UI updates via the listener, build method will use provider state
      if (mounted) setState(() {});
    });

    // Listener for UniversityIdController (mainly for picking state updates)
    controller.addListener(() {
      if (!mounted) return;
      // Trigger rebuild if controller state changes (e.g., after picking image)
      setState(() {});
    });
  }

  Widget _buildIdImageDisplay(UniversityIdController controller) {
    final imageFile = controller.idImageFile;

    return Container(
      width: 329,
      height: 210,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade100,
      ),
      alignment: Alignment.center,
      child: imageFile == null
          ? Center(
              child: Icon(Icons.badge_outlined,
                  size: 60, color: Colors.grey.shade400))
          : Image.file(
              imageFile,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Text("Error loading image file")),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access both providers in the build method
    final controller = context.watch<UniversityIdController>();
    final signInProvider = context.watch<SignInProcessProvider>();

    final isPicking = controller.state == UniversityIdState.picking;
    final isSubmitting = signInProvider.submissionState ==
        RegistrationSubmissionState.submitting;
    final isQueued = signInProvider.submissionState ==
        RegistrationSubmissionState.queuedOffline;
    // Combined processing state for disabling interactions
    final isProcessing = isPicking || isSubmitting || isQueued;

    final bool hasPickedImage = controller.idPickedFile != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Opacity(
          // Dim slightly if submitting or queued, but not during picking
          opacity: (isSubmitting || isQueued) ? 0.7 : 1.0,
          child: AbsorbPointer(
            // Absorb pointers if picking, submitting, or queued
            absorbing: isProcessing,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    // Allow going back only if not processing
                    onTap: isProcessing
                        ? null
                        : () {
                            // If queued message is showing, hide it before popping
                            if (_isQueuedMessageShown) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              // Fallback if cannot pop (e.g., deep linked?)
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const WelcomeScreen()));
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
                  const Spacer(flex: 1),
                  const Center(
                    child: Text(
                      "Please provide a clear picture of your\nuniversity ID for verification.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: _buildIdImageDisplay(controller), // Use helper
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 211,
                      height: 48,
                      child: ElevatedButton.icon(
                        // Disable picking button if already submitting/queued
                        onPressed: isSubmitting || isQueued
                            ? null
                            : () => controller.pickIdImage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171F45),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.grey.shade400, // Indicate disabled state
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                            hasPickedImage ? Icons.edit : Icons.camera_alt),
                        label: Text(
                          hasPickedImage ? "Retake picture" : "Take picture",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- Status Indicator Area ---
                  // Shows spinner when submitting, message when queued
                  SizedBox(
                      height: isSubmitting || isQueued
                          ? 16
                          : 0), // Add space only when indicator shows
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator()),
                  if (isQueued)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0), // Adjust padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16, height: 16, // Smaller spinner for queue
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.orange.shade700)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Queued. Waiting for connection...",
                            style: TextStyle(
                                color: Colors.orange.shade800, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  if (controller.state == UniversityIdState.picking)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Center(
                          child: Text("Opening camera/gallery...",
                              style: TextStyle(color: Colors.grey))),
                    ),
                  // --- End Status Indicator Area ---

                  const Spacer(flex: 2),

                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        // Disable if no image OR if processing (picking, submitting, or queued)
                        onPressed: !hasPickedImage || isProcessing
                            ? null
                            // Trigger the controller's method which then calls the provider
                            : () => controller.completeRegistration(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171F45),
                          foregroundColor: Colors.white,
                          // Standard disabled color
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        // Show spinner ONLY when actively submitting, not when queued/picking
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : const Text(
                                "Create my account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up listeners if needed, although Provider handles this mostly
    // Hide snackbar if screen is disposed while queued message is showing
    if (_isQueuedMessageShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
    }
    super.dispose();
  }
}
