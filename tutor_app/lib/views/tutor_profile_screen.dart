import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tutor_profile_controller.dart'; // Changed import
import '../models/user_model.dart';
import 'dart:math';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  Widget _buildStarRating(double? rating) {
    if (rating == null) {
      return const Text('No rating yet', style: TextStyle(color: Colors.grey));
    }

    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    final pColor = const Color(0xFF192650);
    // Ensure values are non-negative
    fullStars = max(0, fullStars);
    emptyStars = max(0, emptyStars);

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: pColor, size: 40));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: pColor, size: 40));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: pColor, size: 40));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<TutorProfileController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tutor App'),
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
          const SizedBox(height: 24),
          Center(
            child: _buildStarRating(user.avgRating),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
