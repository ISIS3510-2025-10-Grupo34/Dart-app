import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class UniversityIDScreen extends StatefulWidget {
  const UniversityIDScreen({Key? key}) : super(key: key);

  @override
  State<UniversityIDScreen> createState() => _UniversityIDScreenState();
}

class _UniversityIDScreenState extends State<UniversityIDScreen> {
  File? _idImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _idImageFile = File(photo.path);
        });
      }
    } catch (e) {
      // Handle any errors
      print("Error taking picture: $e");
    }
  }

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
                  "You have to take a picture of your university ID so we can verify your identity and university.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: Colors.grey.shade200,
                ),
                child: _idImageFile != null
                    ? Image.file(
                        _idImageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Text(
                          "ID preview will appear here",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Take picture",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _idImageFile != null
                      ? () {
                          // Complete account creation and navigate to home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      : null, // Disable button if no image taken
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Create my account",
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
