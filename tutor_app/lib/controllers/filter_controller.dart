import 'package:flutter/material.dart';
import '../services/universities_service.dart';
import '../services/course_service.dart';
import '../services/tutor_service.dart';
import '../services/filter_service.dart';

class FilterController with ChangeNotifier {
  final UniversitiesService _universitiesService;
  final CourseService _coursesService;
  final TutorService _tutorService;
  final FilterService _filterService;

  FilterController({
    required UniversitiesService universitiesService,
    required CourseService coursesService,
    required TutorService tutorService,
    required FilterService filterService,
  })  : _universitiesService = universitiesService,
        _coursesService = coursesService,
        _tutorService = tutorService,
        _filterService = filterService;

  List<String> universities = [];
  List<String> courses = [];
  List<String> professors = [];

  String universityInput = '';
  String courseInput = '';
  String professorInput = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFilterOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar universidades
      universities = await _universitiesService.fetchUniversities();

      // Cargar cursos según la universidad seleccionada
      if (universityInput.isNotEmpty) {
        courses = await _coursesService.fetchCourses(universityInput);
      } else {
        courses = [];
      }

      // Cargar tutores (ya es List<String>)
      professors = await _tutorService.fetchTutorNames();
    } catch (e) {
      debugPrint("Error loading filter options: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Recargar cursos si cambia la universidad
  Future<void> reloadCoursesForSelectedUniversity() async {
    if (universityInput.isEmpty) return;

    try {
      courses = await _coursesService.fetchCourses(universityInput);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading courses: $e");
    }
  }

  void clearInputs() {
    universityInput = '';
    courseInput = '';
    professorInput = '';
    notifyListeners();
  }

  Future<void> registerFilterUsed(String filter) async {
    await _filterService.increaseFilterCount(filter);
  }
}
