import 'package:flutter/material.dart';
import '../services/filter_service.dart';

class FilterController with ChangeNotifier {
  final FilterService _filterService;

  FilterController({required FilterService filterService})
      : _filterService = filterService;

  List<String> universities = [];
  List<String> courses = [];
  List<String> professors = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFilterOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await _filterService.fetchFilterData();
      universities = rawData.keys.toList();

      courses = [];
      professors = [];

      for (var uni in rawData.keys) {
        final uniCourses = rawData[uni]['courses'];
        for (var course in uniCourses.keys) {
          courses.add(course);
          professors.addAll(List<String>.from(uniCourses[course]['tutors_names']));
        }
      }

      professors = professors.toSet().toList(); // Eliminar duplicados
    } catch (e) {
      debugPrint("Error loading filters: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerFilterUsed(String filter) async {
    await _filterService.increaseFilterCount(filter);
  }
}
