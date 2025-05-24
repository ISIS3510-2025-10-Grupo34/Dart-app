import 'package:flutter/foundation.dart';
import '../providers/sign_in_process_provider.dart';

enum LearningStylesState {
  initial,
  loading,
  success,
  error,
}

class LearningStylesController with ChangeNotifier {
  final SignInProcessProvider _signInProcessProvider;

  LearningStylesController(this._signInProcessProvider) {
    _initializeSelectedStyles();
  }

  LearningStylesState _state = LearningStylesState.initial;
  LearningStylesState get state => _state;

  final List<String> _availableStyles = const [
    'Visual',
    'Auditory',
    'Reading',
    'Writing',
    'Group',
    'Individual',
    'Practical',
    'Mock test'
  ];
  List<String> get availableStyles => List.unmodifiable(_availableStyles);

  final Set<String> _selectedStyles = {};
  Set<String> get selectedStyles => Set.unmodifiable(_selectedStyles);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _initializeSelectedStyles() {
    final String? savedStylesString =
        _signInProcessProvider.savedLearningStyles;
    if (savedStylesString != null && savedStylesString.isNotEmpty) {
      final List<String> savedStylesList = savedStylesString.split(',');
      _selectedStyles.clear();
      _selectedStyles.addAll(savedStylesList);
    }
  }

  void toggleStyle(String style) {
    if (_selectedStyles.contains(style)) {
      _selectedStyles.remove(style);
    } else {
      _selectedStyles.add(style);
    }
    if (_state == LearningStylesState.error && _selectedStyles.isNotEmpty) {
      _state = LearningStylesState.initial;
      _errorMessage = null;
    }
    notifyListeners(); // Update UI
  }

  Future<void> submitLearningStyles() async {
    _state = LearningStylesState.loading;
    _errorMessage = null;
    notifyListeners();

    if (_selectedStyles.isEmpty) {
      _errorMessage = 'Please select at least one learning style.';
      _state = LearningStylesState.error;
      notifyListeners();
      return;
    }

    try {
      final String selectedStylesString = _selectedStyles.join(',');

      await _signInProcessProvider.setLearningStyles(selectedStylesString);

      _state = LearningStylesState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to save learning styles: ${e.toString()}";
      _state = LearningStylesState.error;
      notifyListeners();
    }
  }

  void resetStateAfterNavigation() {
    if (_state == LearningStylesState.success) {
      _state = LearningStylesState.initial;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
