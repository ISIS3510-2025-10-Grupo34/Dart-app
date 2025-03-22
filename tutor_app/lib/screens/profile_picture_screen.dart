import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'university_id_screen.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Upload image to API
  Future<bool> _uploadImageToApi() async {
    if (_pickedFile == null) {
      return false;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // API endpoint URL
      var uri = Uri.parse('https://your-api-endpoint.com/upload');

      if (kIsWeb) {
        // Web implementation - send bytes
        final bytes = await _pickedFile!.readAsBytes();

        // Create multipart request
        var request = http.MultipartRequest('POST', uri);

        // Add headers if needed
        request.headers['Authorization'] = 'Bearer YOUR_API_TOKEN';

        // Add the file as multipart
        var multipartFile = http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: _pickedFile!.name,
        );

        request.files.add(multipartFile);

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Handle successful response
          final respStr = await response.stream.bytesToString();
          print('Upload success: $respStr');
          setState(() {
            _isUploading = false;
          });
          return true;
        } else {
          print('Upload failed: ${response.statusCode}');
          setState(() {
            _isUploading = false;
          });
          return false;
        }
      } else {
        // Mobile implementation - send file
        var file = File(_pickedFile!.path);
        var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
        var length = await file.length();

        // Create multipart request
        var request = http.MultipartRequest('POST', uri);

        // Add headers if needed
        request.headers['Authorization'] = 'Bearer YOUR_API_TOKEN';

        // Add the file as multipart
        var multipartFile = http.MultipartFile(
          'profile_picture',
          stream,
          length,
          filename: path.basename(file.path),
        );

        request.files.add(multipartFile);

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Handle successful response
          final respStr = await response.stream.bytesToString();
          print('Upload success: $respStr');
          setState(() {
            _isUploading = false;
          });
          return true;
        } else {
          print('Upload failed: ${response.statusCode}');
          setState(() {
            _isUploading = false;
          });
          return false;
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      setState(() {
        _isUploading = false;
      });
      return false;
    }
  }

  Widget _buildProfileImage() {
    if (_pickedFile == null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      );
    } else if (!kIsWeb) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(_pickedFile!.path)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    // Fallback
    else {
      return Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child:
              Text("Image loading...", style: TextStyle(color: Colors.white)),
        ),
      );
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
                  "You can upload a profile picture if you want",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: _buildProfileImage(),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171F45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      _pickedFile == null ? "Upload" : "Change Photo",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          "Uploading...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(flex: 1),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () async {
                          // If no image is picked, just proceed to next screen
                          if (_pickedFile == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UniversityIDScreen()),
                            );
                            return;
                          }

                          // Upload image to API
                          final uploadSuccess = await _uploadImageToApi();

                          if (uploadSuccess) {
                            // Update local storage with image path
                            if (!kIsWeb) {
                              _userService.updateUserInfo(
                                profilePicturePath: _pickedFile!.path,
                              );
                            } else {
                              _userService.updateUserInfo(
                                profilePicturePath: _pickedFile!.name,
                              );
                            }

                            // Navigate to next screen
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UniversityIDScreen()),
                              );
                            }
                          } else {
                            // Show error message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Failed to upload image. Please try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey,
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
