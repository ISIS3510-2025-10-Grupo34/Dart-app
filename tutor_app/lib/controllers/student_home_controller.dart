import 'package:flutter/foundation.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import '../models/tutor_list_item_model.dart';
import '../services/tutor_service.dart';

enum StudentHomeState { initial, loading, loaded, error }

enum StudentHomeNavigationTarget { none, profile, review, booking }

class StudentHomeController with ChangeNotifier {
  final TutorService _tutorService;
  final AuthProvider _authProvider;

  StudentHomeController({
    required TutorService tutorService,
    required AuthProvider authProvider,
  })  : _tutorService = tutorService,
        _authProvider = authProvider;

  StudentHomeState _state = StudentHomeState.initial;
  StudentHomeState get state => _state;

  List<TutorListItemModel> _tutors = [];
  List<TutorListItemModel> get tutors =>
      _tutors; // Unmodifiable view if needed: List.unmodifiable(_tutors)

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentHomeNavigationTarget _navigationTarget =
      StudentHomeNavigationTarget.none;
  StudentHomeNavigationTarget get navigationTarget => _navigationTarget;

  Future<void> loadTutors() async {
    if (_state == StudentHomeState.loading) return;

    _state = StudentHomeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tutors = await _tutorService.fetchTutors();
      _tutors.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      _state = StudentHomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudentHomeState.error;
    } finally {
      notifyListeners();
    }
  }

  void navigateToStudentProfile() {
    _navigationTarget = StudentHomeNavigationTarget.none;
    _errorMessage = null;

    final String? studentId = _authProvider.currentUser?.id;

    if (studentId != null && studentId.isNotEmpty) {
      _navigationTarget = StudentHomeNavigationTarget.profile;
    } else {
      _errorMessage = "Error: Student profile ID not found.";
      _state = StudentHomeState.error;
    }
    notifyListeners();
  }

  void resetNavigationState() {
    _navigationTarget = StudentHomeNavigationTarget.none;
  }
}
