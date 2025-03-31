import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/user_service.dart';
import 'home_screen_student.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch the student profile data
      final profileData =
          await _userService.fetchStudentProfile(_userService.getId());

      setState(() {
        _profileData = profileData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () {
            // Navigate to home screen when app title is tapped
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenStudent()),
              (route) =>
                  false, // This will remove all previous routes from the stack
            );
          },
          child: const Text(
            "TutorApp",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              // Navigate to home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreenStudent()),
                (route) =>
                    false, // This will remove all previous routes from the stack
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    // Parse learning styles from comma-separated string if available
    List<String> learningStyles = [];
    if (_profileData.containsKey('learning_styles')) {
      var styles = _profileData['learning_styles'];
      if (styles is String) {
        learningStyles = styles.split(',');
      } else if (styles is List) {
        learningStyles = styles.map((e) => e.toString()).toList();
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF192650),
              backgroundImage: _profileData.containsKey('profile_picture') &&
                      _profileData['profile_picture'] != null &&
                      _profileData['profile_picture'].isNotEmpty
                  ? MemoryImage(base64Decode(_profileData['profile_picture']))
                  : null,
              child: !_profileData.containsKey('profile_picture') ||
                      _profileData['profile_picture'] == null ||
                      _profileData['profile_picture'].isEmpty
                  ? Text(
                      (_profileData['name'] ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),

            // User Name
            const SizedBox(height: 16),
            Text(
              _profileData['name'] ?? "Beck Andrews",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192650),
              ),
            ),

            // University
            const SizedBox(height: 8),
            Text(
              _profileData['university'] ?? "uni",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),

            // Major
            const SizedBox(height: 4),
            Text(
              _profileData['major'] ?? "Major",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),

            // Learning Styles Section
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Learning styles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF192650),
                ),
              ),
            ),

            // Learning Style Chips
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: learningStyles.isEmpty
                    ? [
                        _buildStyleChip("Auditory"),
                        _buildStyleChip("Individual"),
                      ]
                    : learningStyles
                        .map((style) => _buildStyleChip(style))
                        .toList(),
              ),
            ),

            // Additional sections can be added here
            const SizedBox(height: 40),

            // Action buttons
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile or another action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192650),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFF29339b),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}
