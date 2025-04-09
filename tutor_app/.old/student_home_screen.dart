import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/student_home_controller.dart';
import '../models/tutor_list_item_model.dart';
import 'student_profile_screen.dart';
import '../.old/tutor_profile.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentHomeController>().loadTutors();
      _setupNavigationAndErrorListener();
    });
  }

  void _setupNavigationAndErrorListener() {
    final controller =
        Provider.of<StudentHomeController>(context, listen: false);

    controller.addListener(() {
      if (!mounted) return;

      final target = controller.navigationTarget;
      final state = controller.state;
      final errorMessage = controller.errorMessage;

      if (target == StudentHomeNavigationTarget.profile) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
        );
        controller.resetNavigationState();
      }
      // TODO: Add cases for other navigation targets (review, booking) if needed

      // Handle showing errors via SnackBar (e.g., if profile ID wasn't found)
      // Check that an error exists *and* we are not currently trying to navigate
      if (state == StudentHomeState.error &&
          errorMessage != null &&
          target == StudentHomeNavigationTarget.none) {
        // Check target is none to avoid showing error if navigation just succeeded/failed differently
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red, // Optional: style error snackbar
          ),
        );
        // Optional: Reset error message in controller after showing it? Depends on desired behavior.
        // controller.clearErrorMessage(); // You would need to add this method to the controller
      }
    });
  }

  // Removed fetchTutors, _tutors, UserService instance, and _navigateToStudentProfile

  @override
  Widget build(BuildContext context) {
    // Use Consumer to access controller state and rebuild when it changes
    return Consumer<StudentHomeController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("TutorApp",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF192650))),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Color(0xFF192650)),
                // Disable button while loading
                onPressed: controller.state == StudentHomeState.loading
                    ? null
                    : () {
                        // TODO: Implement filter action (might involve calling a controller method)
                        print("Filter Tapped");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Color(0xFF192650)),
                // Call controller method via context.read (action)
                // Disable button while loading
                onPressed: controller.state == StudentHomeState.loading
                    ? null
                    : () {
                        context
                            .read<StudentHomeController>()
                            .navigateToStudentProfile();
                      },
              ),
            ],
          ),
          // Delegate body building to a helper method based on state
          body: _buildBody(context, controller),
        );
      },
    );
  }

  // Helper function to build the body based on the controller's state
  Widget _buildBody(BuildContext context, StudentHomeController controller) {
    // Use the controller's state to decide what to show
    switch (controller.state) {
      case StudentHomeState.loading:
      case StudentHomeState.initial: // Treat initial state as loading
        return const Center(child: CircularProgressIndicator());

      case StudentHomeState.error:
        // Display error message and a retry button
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage ?? "An unknown error occurred.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      context.read<StudentHomeController>().loadTutors(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );

      case StudentHomeState.loaded:
        // Check if the list is empty after loading
        if (controller.tutors.isEmpty) {
          return const Center(
              child: Text("No tutors available at the moment."));
        }
        // Display the list of tutors
        return ListView.builder(
          itemCount: controller.tutors.length,
          itemBuilder: (context, index) {
            // Get the specific tutor model from the controller's list
            final TutorListItemModel tutor = controller.tutors[index];

            // --- Your Card UI structure ---
            // (Using the data from the 'tutor' model)
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            // Navigate to Tutor Profile/Reviews screen
                            // It's okay to navigate directly here for item-specific actions
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Ensure TutorReviews takes tutorId
                                builder: (context) =>
                                    TutorProfile(tutorId: tutor.id),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF192650),
                            backgroundImage: tutor.profilePicture.isNotEmpty
                                ? _safeDecodeBase64(tutor.profilePicture)
                                : null,
                            child: tutor.profilePicture.isEmpty &&
                                    tutor.name.isNotEmpty
                                ? Text(
                                    tutor.name[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )
                                : null,
                          ),
                        ),
                        title: Text(
                          tutor.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          tutor.university,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(tutor.averageRating.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Adjust padding if needed
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tutor.subjects.isNotEmpty)
                              Text(
                                "Subjects: ${tutor.subjects.join(", ")}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                            // Add other info if needed
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement booking logic
                            // Maybe call controller method: context.read<StudentHomeController>().bookTutor(tutor.id);
                            print("Book tutor: ${tutor.name}");
                          },
                          icon: const Icon(Icons.book_online, size: 18),
                          label: const Text('Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF192650),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  // Helper function to safely decode base64 images (moved from build)
  ImageProvider? _safeDecodeBase64(String base64String) {
    try {
      // Remove potential data URI prefix if present
      final String encoded = base64String.startsWith('data:')
          ? base64String.split(',').last
          : base64String;
      return MemoryImage(base64Decode(encoded));
    } catch (e) {
      print("Error decoding base64 image: $e");
      return null; // Return null or a placeholder AssetImage
    }
  }
}
