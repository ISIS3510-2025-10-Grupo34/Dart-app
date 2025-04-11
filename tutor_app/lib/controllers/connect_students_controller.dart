import '../services/location_service.dart';

class ConnectStudentsController {
  final LocationService _locationService = LocationService();

  Future<String> getNearestUniversity() => _locationService.getNearestUniversity();

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String place,
    required String university,
  }) {
    return _locationService.sendNotification(
      title: title,
      message: message,
      place: place,
      university: university,
    );
  }
}
