import 'package:flutter/foundation.dart';
import '../models/tutor_profile.dart';
import '../services/tutor_service.dart';

enum ProfileState { initial, loading, loaded, error }

class TutorProfileController with ChangeNotifier {
  final TutorService _tutorService;

  TutorProfileController({required TutorService tutorService})
      : _tutorService = tutorService;

  ProfileState _state = ProfileState.initial;
  ProfileState get state => _state;

  TutorProfile? _tutorProfile;
  TutorProfile? get tutorProfile => _tutorProfile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(int tutorId) async {
    if (_state == ProfileState.loading) return;

    _state = ProfileState.loading;
    _errorMessage = null;
    _tutorProfile = null;
    notifyListeners();

    try {
      _tutorProfile = await _tutorService.fetchTutorProfile(tutorId);
      _state = ProfileState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.error;
    } finally {
      notifyListeners();
    }
  }
}
