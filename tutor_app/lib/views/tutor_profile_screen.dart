import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/models/review_model.dart';
import '../controllers/tutor_profile_controller.dart'; // Changed import
import '../models/user_model.dart';
import 'dart:math';
import 'welcome_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import FontAwesome
import 'package:url_launcher/url_launcher.dart';
import 'create_tutoring_session_screen.dart'; 

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});
  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  Widget _buildStarRating(double? rating, double? starSize) {
    if (rating == null) {
      return const Text('No rating yet', style: TextStyle(color: Colors.grey));
    }

    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    final pColor = const Color(0xFF192650);

    fullStars = max(0, fullStars);
    emptyStars = max(0, emptyStars);

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: pColor, size: starSize));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: pColor, size: starSize));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: pColor, size: starSize));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final profileController =
        Provider.of<TutorProfileController>(context, listen: false);
    try {
      await profileController.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during logout triggered from screen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tutor phone number not available.')),
        );
      }
      return;
    }

    String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!sanitizedNumber.startsWith('57') && sanitizedNumber.length == 10) {
      sanitizedNumber = '57$sanitizedNumber';
    } else if (!sanitizedNumber.startsWith('+') &&
        !sanitizedNumber.startsWith('57')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Cannot determine phone number format: $phoneNumber')),
        );
      }
      return;
    }

    final Uri whatsappUrl = Uri.parse("https://wa.me/$sanitizedNumber");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $whatsappUrl");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not open WhatsApp. Is it installed?')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening WhatsApp: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<TutorProfileController>();
    final bool hasPhoneNumber = profileController.user?.phoneNumber != null &&
        profileController.user!.phoneNumber!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tutor App'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: const Color(0xFF192650),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () => _logout(context),
              ),
            ),
          ),
        ],
      ),
      body: buildProfileContent(context, profileController),
    );
  }

  Widget buildProfileContent(
      BuildContext context, TutorProfileController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading profile: ${controller.errorMessage}'),
        ),
      );
    }

    final User? user = controller.user;

    if (user == null) {
      return const Center(
          child: Text('Profile data not available. Please try refreshing.'));
    }
    ImageProvider? profileImageProvider;
    if (user.profilePicturePath != null &&
        user.profilePicturePath!.isNotEmpty) {
      profileImageProvider = FileImage(File(user.profilePicturePath!));
    }
    const double iconButtonSize = 20.0;
    const double iconButtonPadding = 2.0;
    const double spacerWidth = iconButtonSize + iconButtonPadding;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImageProvider,
              child: profileImageProvider == null
                  ? Text(
                      user.name?.isNotEmpty == true
                          ? user.name![0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name ?? 'N/A', //
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user.university ?? 'No university', //
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              user.areaOfExpertise ?? 'No AoE', //
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.whatsapp),
                  color: Colors.grey[600],
                  iconSize: iconButtonSize,
                  padding: const EdgeInsets.only(right: iconButtonPadding),
                  constraints: const BoxConstraints(),
                  tooltip: 'Chat on WhatsApp',
                  onPressed: () => _launchWhatsApp(user.phoneNumber),
                ),
                Text(
                  user.phoneNumber!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: spacerWidth),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 24),
          Center(
            child: _buildStarRating(user.avgRating, 40),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Reviews',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewsList(controller.user?.reviews),

          const SizedBox(height: 16), // Bottom padding

          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTutoringSessionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192650),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                "Announce tutoring session",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // Bottom padding

        ],
      ),
    );
  }

  Widget _buildReviewsList(List<Review>? reviews) {
    if (reviews == null || reviews.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Text('No reviews yet.'),
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStarRating(review.rating.toDouble(), 16),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(review.comment),
        ),
      ),
    );
  }
}
