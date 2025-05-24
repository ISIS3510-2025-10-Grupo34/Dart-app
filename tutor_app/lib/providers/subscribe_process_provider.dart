import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../misc/constants.dart';

class SubscribeProgressProvider with ChangeNotifier {
  late Box _subscribeBox;

  String? _selectedUniversity;
  String? _selectedCourse;

  String? get savedUniversity => _subscribeBox.get(HiveKeys.selectedUniversity);
  String? get savedCourse => _subscribeBox.get(HiveKeys.selectedCourse);

  Future<void> init() async {
    _subscribeBox = await Hive.openBox(HiveKeys.subscribeProgressBox);
  }

  Future<void> saveUniversity(String university) async {
    _selectedUniversity = university;
    await _subscribeBox.put(HiveKeys.selectedUniversity, university);
    notifyListeners();
  }

  Future<void> saveCourse(String course) async {
    _selectedCourse = course;
    await _subscribeBox.put(HiveKeys.selectedCourse, course);
    notifyListeners();
  }

  Future<void> clearSubscriptionProgress() async {
    await _subscribeBox.clear();
    _selectedUniversity = null;
    _selectedCourse = null;
    notifyListeners();
  }
}
