import 'package:flutter/foundation.dart';
import 'package:tutor_app/services/area_of_expertise_service.dart';
import '../providers/sign_in_process_provider.dart';
import '../services/universities_service.dart';
import '../services/area_of_expertise_service.dart';

enum TutorSignInState {
  initial,
  loading,
  success,
  error,
}

class TutorSignInController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;
  final UniversitiesService _universitiesService;
  final AreaOfExpertiseService _areaOfExpertiseService;

  TutorSignInController(this._signInProcessProvider, this._universitiesService,
      this._areaOfExpertiseService) {
    _loadUniversities();
    _loadAreaOfExpertise();
  }

  TutorSignInState _state = TutorSignInState.initial;
  TutorSignInState get state => _state;

  List<String> _universities = [];
  List<String> get universities => _universities;

  String? _selectedUniversity;
  String? get selectedUniversity => _selectedUniversity;

  bool _isLoadingUniversities = false;
  bool get isLoadingUniversities => _isLoadingUniversities;

  String? _universityApiError;
  String? get universityApiError => _universityApiError;

  List<String> _aoe = [];
  List<String> get aoe => _aoe;

  String? _selectedAOE;
  String? get selectedAOE => _selectedAOE;

  bool _isLoadingAOE = false;
  bool get isLoadingAOE => _isLoadingAOE;

  String? _expertiseApiError;
  String? get expertiseApiError => _expertiseApiError;

  String? _nameError;
  String? get nameError => _nameError;

  String? _phoneError;
  String? get phoneError => _phoneError;

  String? _universityError;
  String? get universityError => _universityError;

  String? _expertiseError;
  String? get expertiseError => _expertiseError;

  String? _generalError;
  String? get generalError => _generalError;

  Future<void> _loadUniversities() async {
    _isLoadingUniversities = true;
    _universityApiError = null;
    notifyListeners();
    try {
      _universities = await _universitiesService.fetchUniversities();
    } catch (e) {
      _universityApiError = "Could not load universities: ${e.toString()}";
      debugPrint(_universityApiError);
    } finally {
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  void selectUniversity(String? value) {
    if (_selectedUniversity != value) {
      _selectedUniversity = value;
      _universityError = null;
      notifyListeners();
    }
  }

  Future<void> _loadAreaOfExpertise() async {
    _isLoadingAOE = true;
    _universityApiError = null;
    notifyListeners();
    try {
      _aoe = await _areaOfExpertiseService.fetchAreaOfExpertise();
    } catch (e) {
      _universityApiError = "Could not load area_of_expertise: ${e.toString()}";
      debugPrint(_universityApiError);
    } finally {
      _isLoadingAOE = false;
      notifyListeners();
    }
  }

  void selectAOE(String? value) {
    if (_selectedAOE != value) {
      _selectedAOE = value;
      _expertiseError = null;
      notifyListeners();
    }
  }

  Future<void> submitTutorDetails({
    required String name,
    required String phoneNumber,
  }) async {
    _state = TutorSignInState.loading;
    _clearErrors();
    notifyListeners();

    bool isValid = true;
    if (name.trim().isEmpty) {
      _nameError = 'Name is required';
      isValid = false;
    }
    if (phoneNumber.trim().isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(phoneNumber.trim())) {
      _phoneError = 'Enter a valid phone number';
      isValid = false;
    }

    if (_selectedUniversity == null || _selectedUniversity!.isEmpty) {
      _universityError = 'Please select a university';
      isValid = false;
    }
    if (_selectedAOE == null || _selectedAOE!.isEmpty) {
      _expertiseError = 'Please select a area of expertise';
      isValid = false;
    }

    if (!isValid) {
      _state = TutorSignInState.error;
      notifyListeners();
      return;
    }

    try {
      final Map<String, String> tutorData = {
        'name': name.trim(),
        'phone_number': phoneNumber.trim(),
        'university': _selectedUniversity!,
        'area_of_expertise': _selectedAOE!,
      };
      _signInProcessProvider.setTutorDetails(tutorData);

      _state = TutorSignInState.success;
      notifyListeners();
    } catch (e) {
      _generalError = "Failed to save details: ${e.toString()}";
      _state = TutorSignInState.error;
      notifyListeners();
    }
  }

  void _clearErrors() {
    _nameError = null;
    _phoneError = null;
    _universityError = null;
    _expertiseError = null;
    _generalError = null;
  }

  void clearInputErrors() {
    if (_state == TutorSignInState.error) {
      _clearErrors();
      _state = TutorSignInState.initial;
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == TutorSignInState.success) {
      _state = TutorSignInState.initial;
      _clearErrors();
      notifyListeners();
    }
  }
}
