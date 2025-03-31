import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class UniversityIDScreen extends StatefulWidget {
  const UniversityIDScreen({super.key});

  @override
  State<UniversityIDScreen> createState() => _UniversityIDScreenState();
}

class _UniversityIDScreenState extends State<UniversityIDScreen> {
  XFile? _idPickedFile;
  Uint8List? _webIdImage;
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _takePicture() async {
    try {
      // Show dialog to choose image source
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final XFile? imageFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (imageFile != null) {
        setState(() {
          _idPickedFile = imageFile;
        });

        // For web, we need to read the bytes
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          setState(() {
            _webIdImage = bytes;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildIdImageDisplay() {
    return Container(
      width: 329,
      height: 210,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: _idPickedFile == null
          ? const SizedBox() // Empty container when no image
          : kIsWeb && _webIdImage != null
              ? Image.memory(
                  _webIdImage!,
                  fit: BoxFit.contain,
                )
              : !kIsWeb
                  ? Image.file(
                      File(_idPickedFile!.path),
                      fit: BoxFit.contain,
                    )
                  : const SizedBox(),
    );
  }

  Future<void> _completeRegistration(BuildContext context) async {
    if (_idPickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture of your ID first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _userService.updateUserInfo(
        idPicturePath: _idPickedFile!.path,
      );

      // Register user with API
      final success = await _userService.registerUser(context);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "TutorApp",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 1),
              const Center(
                child: Text(
                  "You have to take a picture of your\nuniversity ID so we can verify your\nidentity and university.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: _buildIdImageDisplay(),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 211,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Take picture",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _idPickedFile == null || _isLoading
                        ? null
                        : () => _completeRegistration(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create my account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
