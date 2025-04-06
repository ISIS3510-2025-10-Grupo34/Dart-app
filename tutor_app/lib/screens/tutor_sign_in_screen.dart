import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_picture_screen.dart';
import '../services/user_service.dart';

class TutorSignIn extends StatefulWidget {
  const TutorSignIn({super.key});

  @override
  _TutorSignInState createState() => _TutorSignInState();
}

class _TutorSignInState extends State<TutorSignIn> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaOfExpertiseController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final UserService _userService = UserService();

  final List<String> _universities = [
    'Universidad de los Andes',
    'Universidad Nacional de Colombia',
    'Pontificia Universidad Javeriana',
    'Universidad del Rosario',
    'Universidad Distrital Francisco José de Caldas',
    'Universidad de la Sabana',
    'Universidad de Bogotá Jorge Tadeo Lozano',
  ];

  String? _selectedUniversity;

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
                  "Tutor",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171F45),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "We would like to know more about you",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'First and last name',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUniversity,
                decoration: InputDecoration(
                  hintText: 'University',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _universities.map((String university) {
                  return DropdownMenuItem<String>(
                    value: university,
                    child: Text(university),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUniversity = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _areaOfExpertiseController,
                decoration: InputDecoration(
                  hintText: 'Area of expertise',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _userService.updateUserInfo(
                      name: _nameController.text,
                      phoneNumber: _phoneNumberController.text,
                      university: _selectedUniversity ?? '',
                      areaOfExpertise: _areaOfExpertiseController.text,
                      isTutor: "true",
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePictureScreen()),
                      (route) => false,
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
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaOfExpertiseController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
