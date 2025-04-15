import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tutor_profile_controller.dart'; // Changed import
import '../models/user_model.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

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

  // Build content based on the controller's state
  Widget buildProfileContent(
      BuildContext context, TutorProfileController controller) {
    // Use state from the controller
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

    final User? user = controller.user; // Get user from controller

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
              user.university ?? 'No email', //
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              user.major ?? 'No email', //
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
