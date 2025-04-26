import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/models/review_model.dart';
import 'similar_reviews_dialog.dart';
import '../controllers/tutor_profile_controller.dart';
import '../models/user_model.dart';
import 'dart:math';
import 'welcome_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_tutoring_session_screen.dart';
import 'connect_students_screen.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  bool _didCheckRating = false;
  @override
  void initState() {
    super.initState();
    final controller =
        Provider.of<TutorProfileController>(context, listen: false);
    controller.fetchTimeToBookInsight();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRatingAndShowPopupIfNeeded();
    });
  }

  void _checkRatingAndShowPopupIfNeeded() {
    if (_didCheckRating || !mounted) return; // Only run once and if mounted

    final controller =
        Provider.of<TutorProfileController>(context, listen: false);
    final avgRating = controller.user?.avgRating;

    if (avgRating == null || avgRating < 4.0) {
      setState(() {
        _didCheckRating = true;
      }); // Mark as checked

      showDialog(
        context: context,
        barrierDismissible: false, // User must interact
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Rating Suggestion"),
            content: const Text(
                "Your average rating is below 4.0. Would you like to see examples of highly-rated reviews from similar tutors?"),
            actions: <Widget>[
              TextButton(
                child: const Text("No, Thanks"),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text("Yes, Show Me"),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close this dialog first
                  _fetchAndDisplaySimilarReviews(); // Fetch and show the next dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _didCheckRating = true;
      });
    }
  }

  Future<void> _fetchAndDisplaySimilarReviews() async {
    if (!mounted) return;
    final controller =
        Provider.of<TutorProfileController>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal while loading
      builder: (BuildContext loadingContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Loading reviews..."),
            ],
          ),
        );
      },
    );

    await controller.fetchAndShowSimilarReviews();

    if (!mounted) return;

    Navigator.of(context).pop();

    if (controller.similarReviewsError != null) {
      showDialog(
        context: context,
        builder: (BuildContext errorContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(controller.similarReviewsError!),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(errorContext).pop(),
              ),
            ],
          );
        },
      );
    } else {
      // Show the dialog with fetched reviews
      showDialog(
        context: context,
        builder: (BuildContext reviewDialogContext) {
          return SimilarReviewsDialog(
            similarReviews: controller.similarReviews,
          );
        },
      );
    }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tutor App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            )),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF192650)),
              tooltip: 'Connect Students',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ConnectStudentsScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: const Color(0xFF192650),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
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
        child: Text('Profile data not available. Please try refreshing.'),
      );
    }

    final message = '''Time it takes a student to book with you: 15 seconds. 
        Your average time is less than the average time to book, keep up the good work.''';

    ImageProvider? profileImageProvider;
    if (user.profilePicturePath != null &&
        user.profilePicturePath!.isNotEmpty) {
      profileImageProvider = FileImage(File(user.profilePicturePath!));
    }

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
              user.name ?? 'N/A',
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
              user.university ?? 'No university',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              user.areaOfExpertise ?? 'No AoE',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF192650),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
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
                  iconSize: 20.0,
                  padding: const EdgeInsets.only(right: 2.0),
                  constraints: const BoxConstraints(),
                  tooltip: 'Chat on WhatsApp',
                  onPressed: () => _launchWhatsApp(user.phoneNumber),
                ),
                Text(
                  user.phoneNumber!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 22.0),
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
                  MaterialPageRoute(
                      builder: (_) => const CreateTutoringSessionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192650),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(review.comment ?? 'No comment'),
        ),
      ),
    );
  }
}
