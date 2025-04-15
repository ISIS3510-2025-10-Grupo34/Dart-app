import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/student_profile_controller.dart'; // Changed import
import '../models/user_model.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  // Helper function to build learning style chips (no change needed)
  List<Widget> _buildLearningStyleChips(String? learningStylesString) {
    if (learningStylesString == null || learningStylesString.isEmpty) {
      return [const Text('Not specified')];
    }
    final styles = learningStylesString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return styles
        .map((style) => Chip(
              label: Text(style),
              backgroundColor: const Color(0xFF29339b),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Consume the StudentProfileController
    // Use context.watch to rebuild when the controller notifies listeners
    final profileController =
        context.watch<StudentProfileController>(); // Changed provider

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
      BuildContext context, StudentProfileController controller) {
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
          Text(
            'Learning Styles',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,

            children: _buildLearningStyleChips(user.learningStyles), //
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
