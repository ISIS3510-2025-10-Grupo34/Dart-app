import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/sign_in_process_provider.dart';

enum UniversityIdState {
  initial,
  picking,
  picked,
  registering,
  success,
  error,
}

class UniversityIdController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;
  final ImagePicker _picker = ImagePicker();

  UniversityIdController(this._signInProcessProvider);

  UniversityIdState _state = UniversityIdState.initial;
  UniversityIdState get state => _state;

  XFile? _idPickedFile;
  XFile? get idPickedFile => _idPickedFile;

  File? get idImageFile =>
      _idPickedFile != null ? File(_idPickedFile!.path) : null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> pickIdImage(BuildContext context) async {
    _state = UniversityIdState.picking;
    _errorMessage = null;
    notifyListeners();

    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              child: const Row(children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Camera')
              ]),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              child: const Row(children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Gallery')
              ]),
            ),
          ],
        ),
      );

      if (source == null) {
        _state = (_idPickedFile == null)
            ? UniversityIdState.initial
            : UniversityIdState.picked;
        notifyListeners();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        _idPickedFile = image;
        _state = UniversityIdState.picked;
      } else {
        _state = (_idPickedFile == null)
            ? UniversityIdState.initial
            : UniversityIdState.picked;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to pick ID image: ${e.toString()}";
      _state = UniversityIdState.error;
      notifyListeners();
    }
  }

  Future<void> completeRegistration() async {
    if (_idPickedFile == null) {
      _errorMessage = 'Please take or select a picture of your ID first.';
      _state = UniversityIdState.error;
      notifyListeners();
      return;
    }

    _state = UniversityIdState.registering;
    _errorMessage = null;
    notifyListeners();

    try {
      final String idPath = _idPickedFile!.path;
      _signInProcessProvider.setIdPicturePath(idPath);

      await _signInProcessProvider.submitRegistration();

      _state = UniversityIdState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Registration failed try again";
      _state = UniversityIdState.error;
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == UniversityIdState.success) {
      _state = UniversityIdState.initial;
      _errorMessage = null;
      _idPickedFile = null;
      _signInProcessProvider.reset();
      notifyListeners();
    } else if (_state == UniversityIdState.error) {
      _state = (_idPickedFile == null)
          ? UniversityIdState.initial
          : UniversityIdState.picked;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
