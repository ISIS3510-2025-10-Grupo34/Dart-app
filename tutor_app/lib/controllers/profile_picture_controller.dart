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

  ProfilePictureController(this._signInProcessProvider);

  ProfilePictureState _state = ProfilePictureState.initial;
  ProfilePictureState get state => _state;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  File? get pickedImageFile =>
      _pickedFile != null ? File(_pickedFile!.path) : null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> pickImage() async {
    _state = ProfilePictureState.picking;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedFile = image;
        _state = ProfilePictureState.picked;
      } else {
        _state = (_pickedFile == null)
            ? ProfilePictureState.initial
            : ProfilePictureState.picked; // Revert state
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

      _signInProcessProvider.setProfilePicturePath(imagePath);

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
