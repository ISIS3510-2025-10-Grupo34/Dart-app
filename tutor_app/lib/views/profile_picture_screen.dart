import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_picture_controller.dart';
import 'university_id_screen.dart';
import 'welcome_screen.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller =
        Provider.of<ProfilePictureController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return;

      final state = controller.state;
      if (state == ProfilePictureState.success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UniversityIDScreen()),
        );
        controller.resetStateAfterNavigation();
      } else if (state == ProfilePictureState.error &&
          controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Widget _buildProfileImage(ProfilePictureController controller) {
    final imageFile = controller.pickedImageFile;

    if (imageFile == null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(imageFile),
            fit: BoxFit.cover,
          ),
        ),
        child: controller.state == ProfilePictureState.picking
            ? const CircularProgressIndicator()
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to controller changes
    return Consumer<ProfilePictureController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == ProfilePictureState.submitting ||
            controller.state == ProfilePictureState.picking;
        final bool hasPickedImage = controller.pickedFile != null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Opacity(
              opacity:
                  isLoading && controller.state != ProfilePictureState.picking
                      ? 0.7
                      : 1.0, // Dim slightly when submitting
              child: AbsorbPointer(
                absorbing: isLoading &&
                    controller.state !=
                        ProfilePictureState.picking, // Absorb when submitting
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                // Navigate to welcome screen? Or just pop?
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomeScreen()),
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
                          "You can upload a profile picture if you want",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child:
                            _buildProfileImage(controller), // Pass controller
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            // Call controller method to pick image
                            onPressed:
                                isLoading ? null : () => controller.pickImage(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.photo_library),
                            // Read label based on controller state
                            label: Text(
                              !hasPickedImage ? "Upload" : "Change Photo",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (controller.state == ProfilePictureState.submitting)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                Text(
                                  "Saving...",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (controller.state == ProfilePictureState.picking)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(
                            child: Text(
                              "Opening gallery...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      const Spacer(flex: 1),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          // Disable button when loading, call controller method
                          onPressed: isLoading
                              ? null
                              : () => controller.submitProfilePicture(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF171F45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            disabledBackgroundColor:
                                const Color(0xFF171F45).withOpacity(0.6),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
