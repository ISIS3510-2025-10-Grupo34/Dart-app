import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/university_id_controller.dart';
import 'login_screen.dart';

class UniversityIDScreen extends StatefulWidget {
  const UniversityIDScreen({super.key});

  @override
  State<UniversityIDScreen> createState() => _UniversityIDScreenState();
}

class _UniversityIDScreenState extends State<UniversityIDScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller =
        Provider.of<UniversityIdController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return;

      final state = controller.state;
      if (state == UniversityIdState.success) {
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
        controller.resetStateAfterNavigation();
      } else if (state == UniversityIdState.error &&
          controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        controller.resetStateAfterNavigation();
      }
    });
  }

  // Helper to build image display, simplified for mobile only
  Widget _buildIdImageDisplay(UniversityIdController controller) {
    final imageFile = controller.idImageFile; // Use the getter for File

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
                  size: 60, color: Colors.grey.shade400)) // Placeholder
          // Directly use Image.file since kIsWeb check is removed
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
    return Consumer<UniversityIdController>(
      builder: (context, controller, child) {
        final isProcessing =
            controller.state == UniversityIdState.registering ||
                controller.state == UniversityIdState.picking;
        final bool hasPickedImage = controller.idPickedFile != null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Opacity(
              opacity:
                  isProcessing && controller.state != UniversityIdState.picking
                      ? 0.7
                      : 1.0,
              child: AbsorbPointer(
                absorbing: isProcessing &&
                    controller.state != UniversityIdState.picking,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: isProcessing
                            ? null
                            : () {
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
                            onPressed: isProcessing
                                ? null
                                : () => controller.pickIdImage(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(
                                hasPickedImage ? Icons.edit : Icons.camera_alt),
                            label: Text(
                              hasPickedImage
                                  ? "Retake picture"
                                  : "Take picture",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      if (controller.state == UniversityIdState.picking)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child:
                              Center(child: Text("Opening camera/gallery...")),
                        ),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: !hasPickedImage || isProcessing
                                ? null
                                : () => controller.completeRegistration(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: controller.state ==
                                    UniversityIdState.registering
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
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
      },
    );
  }
}
