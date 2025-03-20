import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'profile_picture_screen.dart';
import 'home_screen.dart';

class StudentLearningStylesScreen extends StatefulWidget {
  const StudentLearningStylesScreen({super.key});

  @override
  State<StudentLearningStylesScreen> createState() =>
      _LearningStylesScreenState();
}

class _LearningStylesScreenState extends State<StudentLearningStylesScreen> {
  // List of available learning styles
  final List<String> learningStyles = [
    'Visual',
    'Auditory',
    'Reading',
    'Writing',
    'Group',
    'Individual',
    'Practical',
    'Mock test'
  ];

  final Set<String> selectedStyles = {};
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to home screen when TutorApp text is tapped
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                  "Select your preferred learning styles.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 12.0, // gap between lines
                alignment: WrapAlignment.center,
                children: learningStyles.map((style) {
                  final isSelected = selectedStyles.contains(style);
                  return FilterChip(
                    label: Text(style),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedStyles.add(style);
                        } else {
                          selectedStyles.remove(style);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Color(0xFF29339b),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(flex: 1),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Save selected learning styles
                    final String selectedStylesString =
                        selectedStyles.join(',');
                    _userService.updateUserInfo(
                      learningStyles: selectedStylesString,
                    );
                    // Navigate to next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePictureScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
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
    );
  }
}
