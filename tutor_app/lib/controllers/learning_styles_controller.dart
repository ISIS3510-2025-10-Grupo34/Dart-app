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

  LearningStylesController(this._signInProcessProvider);

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

  // Set to hold the selected styles - managed by the controller
  final Set<String> _selectedStyles = {};
  Set<String> get selectedStyles => Set.unmodifiable(_selectedStyles);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Method to toggle selection
  void toggleStyle(String style) {
    if (_selectedStyles.contains(style)) {
      _selectedStyles.remove(style);
    } else {
      _selectedStyles.add(style);
    }
    // Clear error if user starts selecting again after an error
    if (_state == LearningStylesState.error && _selectedStyles.isNotEmpty) {
      _state = LearningStylesState.initial;
      _errorMessage = null;
    }
    notifyListeners(); // Update UI
  }

  // Method to submit selected styles
  Future<void> submitLearningStyles() async {
    _state = LearningStylesState.loading;
    _errorMessage = null;
    notifyListeners();

    // Validation: Ensure at least one style is selected
    if (_selectedStyles.isEmpty) {
      _errorMessage = 'Please select at least one learning style.';
      _state = LearningStylesState.error;
      notifyListeners();
      return;
    }

    try {
      // Convert set to comma-separated string
      final String selectedStylesString = _selectedStyles.join(',');

      _signInProcessProvider.setLearningStyles(selectedStylesString);

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
