import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tutor_app/.old/write_review_screen.dart';
import '../models/tutor_profile.dart';
import '../controllers/tutor_profile_controller.dart';

class TutorProfileScreen extends StatefulWidget {
  final int tutorId;

  const TutorProfileScreen({super.key, required this.tutorId});

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorProfileController>().loadProfile(widget.tutorId);
    });
  }

  // Removed _tutorProfile future and fetchTutorProfile method

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get controller state and rebuild
    return Consumer<TutorProfileController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Tutor Profile", // Updated title
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            // Optional: Add back button automatically if pushed onto stack
            // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          ),
          // Delegate body building based on controller state
          body: _buildBody(context, controller),
        );
      },
    );
  }

  // Helper to build body based on state
  Widget _buildBody(BuildContext context, TutorProfileController controller) {
    switch (controller.state) {
      case ProfileState.loading:
      case ProfileState.initial:
        return const Center(child: CircularProgressIndicator());

      case ProfileState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage ?? "Failed to load profile.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  // Pass tutorId again for retry
                  onPressed: () => context
                      .read<TutorProfileController>()
                      .loadProfile(widget.tutorId),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );

      case ProfileState.loaded:
        // Ensure profile data is not null before accessing
        final tutorProfile = controller.tutorProfile;
        if (tutorProfile == null) {
          return const Center(child: Text("Tutor data not found."));
        }

        // --- Your existing UI structure, now using the tutorProfile model ---
        return SingleChildScrollView(
          // Add scroll view for potentially long content
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      // Use NetworkImage as per original code for this screen
                      backgroundImage: (tutorProfile.profilePicture.isNotEmpty)
                          ? NetworkImage(
                              tutorProfile.profilePicture) // Assuming URL
                          : null,
                      backgroundColor: const Color(0xFF192650),
                      child: tutorProfile.profilePicture.isEmpty &&
                              tutorProfile.name.isNotEmpty
                          ? Text(
                              tutorProfile.name[0].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 32, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tutorProfile.name, // Use model data
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      tutorProfile.university, // Use model data
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: tutorProfile.ratings, // Use model data
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Color(0xFF192650)),
                      itemCount: 5,
                      itemSize: 24.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // WhatsApp Contact
              if (tutorProfile
                  .whatsappContact.isNotEmpty) // Only show if available
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF192650)),
                    const SizedBox(width: 10),
                    Text(
                      tutorProfile.whatsappContact, // Use model data
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Subjects
              const Text(
                "Subjects:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (tutorProfile.subjects.isEmpty)
                const Text("No subjects listed.",
                    style: TextStyle(fontSize: 16, color: Colors.grey))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tutorProfile.subjects.map((subject) {
                    // Use model data
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.book_outlined,
                              color: Colors.blue.shade900,
                              size: 20), // Changed Icon slightly
                          const SizedBox(width: 10),
                          Expanded(
                              // Allow subject text to wrap
                              child: Text(subject,
                                  style: const TextStyle(fontSize: 16))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              // Reviews Section Title
              const Text("Reviews:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Reviews List (using Review model from tutor_profile.dart)
              if (tutorProfile.reviews.isEmpty)
                const Text("No reviews yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey))
              else
                ListView.builder(
                  shrinkWrap: true, // Important inside SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                  itemCount: tutorProfile.reviews.length, // Use model data
                  itemBuilder: (context, index) {
                    final Review review =
                        tutorProfile.reviews[index]; // Use typed Review model
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF192650),
                        child: Text(
                          review.initials, // Use initials from model
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: RatingBarIndicator(
                        rating: review.rating, // Use rating from model
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFF192650)),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      subtitle: Text(review.comment), // Use comment from model
                    );
                  },
                ),
              const SizedBox(height: 20),
              // Write Review Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigation can stay here for this direct action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WriteReviewScreen(tutorId: widget.tutorId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192650),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    foregroundColor: Colors.white, // Set text color
                  ),
                  child: const Text("Write a review"),
                ),
              ),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        );
    }
  }
}
