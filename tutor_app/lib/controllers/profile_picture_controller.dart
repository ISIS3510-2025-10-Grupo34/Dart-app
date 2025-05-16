import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/sign_in_process_provider.dart';

enum ProfilePictureState {
  initial,
  picking,
  picked,
  submitting,
  success,
  error,
}

class ProfilePictureController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;
  final ImagePicker _picker = ImagePicker();

  ProfilePictureController(this._signInProcessProvider) {
    _initializePickedFile();
  }

  ProfilePictureState _state = ProfilePictureState.initial;
  ProfilePictureState get state => _state;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  File? get pickedImageFile =>
      _pickedFile != null ? File(_pickedFile!.path) : null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _initializePickedFile() {
    final String? savedPath = _signInProcessProvider.savedProfilePicturePath;
    if (savedPath != null && savedPath.isNotEmpty) {
      if (File(savedPath).existsSync()) {
        _pickedFile = XFile(savedPath);
        _state = ProfilePictureState.picked;
      } else {
        debugPrint(
            "Saved profile picture path not found: $savedPath. Clearing from Hive.");
        _signInProcessProvider.setProfilePicturePath(null);
        _pickedFile = null;
        _state = ProfilePictureState.initial;
      }
    }
  }

  Future<void> pickImage() async {
    _state = ProfilePictureState.picking;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedFile = image;
        _state = ProfilePictureState.picked;
        await _signInProcessProvider.setProfilePicturePath(image.path);
      } else {
        _state = (_pickedFile == null)
            ? ProfilePictureState.initial
            : ProfilePictureState.picked;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to pick image: ${e.toString()}";
      _state = ProfilePictureState.error;
      notifyListeners();
    }
  }

  Future<void> submitProfilePicture() async {
    _state = ProfilePictureState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? imagePath = _pickedFile?.path;

      await _signInProcessProvider.setProfilePicturePath(imagePath);

      _state = ProfilePictureState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to save image selection: ${e.toString()}";
      _state = ProfilePictureState.error;
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == ProfilePictureState.success) {
      _state = (_pickedFile == null)
          ? ProfilePictureState.initial
          : ProfilePictureState.picked;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
