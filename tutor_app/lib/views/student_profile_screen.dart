import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/student_profile_controller.dart';
import '../controllers/student_tutoring_sessions_controller.dart';
import '../models/user_model.dart';
import 'write_review_screen.dart';
import '../providers/auth_provider.dart';
import 'student_home_screen.dart';
import 'welcome_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser?.id != null) {
        Provider.of<StudentTutoringSessionsController>(context, listen: false)
            .fetchStudentSessions();
      }
    });
  }

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
              backgroundColor: const Color(0xFF171F45),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ))
        .toList();
  }

  Future<void> _logout(BuildContext context) async {
    final profileController =
        Provider.of<StudentProfileController>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<StudentProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("TutorApp",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const StudentHomeScreen()),
            );
          },
        ),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: buildProfileContent(context, profileController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileContent(
      BuildContext context, StudentProfileController controller) {
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

    ImageProvider? profileImageProvider;
    if (user.profilePicturePath != null &&
        user.profilePicturePath!.isNotEmpty) {
      try {
        profileImageProvider = FileImage(File(user.profilePicturePath!));
      } catch (e) {
        print("Error loading file image: $e");
        profileImageProvider = null;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
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
                  user.email ?? 'No Email Provided',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.university ?? 'No University',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  user.major ?? 'No Major',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
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
                children: _buildLearningStyleChips(user.learningStyles),
              ),
            ],
          ),
        ),
        const Text(
          'My Tutoring Sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<StudentTutoringSessionsController>(
            builder: (context, sessionController, child) {
              if (sessionController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (sessionController.errorMessage != null) {
                return Center(
                  child: Text('Error: ${sessionController.errorMessage}'),
                );
              }
              if (sessionController.sessions.isEmpty) {
                return const Center(child: Text('No tutoring sessions found.'));
              }

              return ListView.builder(
                itemCount: sessionController.sessions.length,
                itemBuilder: (context, index) {
                  final session = sessionController.sessions[index];
                  final studentId =
                      Provider.of<AuthProvider>(context, listen: false)
                          .currentUser
                          ?.id;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title:
                          Text('${session.course} with ${session.tutorName}'),
                      subtitle: Text(session.dateTime),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171F45),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Review'),
                        onPressed: () {
                          if (studentId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WriteReviewScreen(
                                  tutorId: session.tutorId,
                                  studentId: int.parse(studentId),
                                  sessionId: session.id,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Unable to find your student ID")),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
