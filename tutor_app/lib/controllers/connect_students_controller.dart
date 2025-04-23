import 'dart:io';
import '../services/location_service.dart';
import '../services/local_cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectStudentsController {
  final LocationService _locationService = LocationService();
  final LocalCacheService _cacheService = LocalCacheService();

  Future<String> getNearestUniversity() async {
  final connectivity = await Connectivity().checkConnectivity();

  if (connectivity == ConnectivityResult.none) {
    return "Sin conexión a internet";
  }

  try {
    return await _locationService.getNearestUniversity();
  } catch (_) {
    return "Ubicación no disponible";
  }
}


  Future<bool> sendNotification({
    required String title,
    required String message,
    required String place,
    required String university,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    final data = {
      "title": title,
      "message": message,
      "place": place,
      "university": university,
    };

    if (connectivity == ConnectivityResult.none) {
      // Guardar localmente para envío posterior
      await _cacheService.cachePendingNotification(data);
      return false; // O true si quieres optimismo
    }

    try {
      return await _locationService.sendNotification(
        title: title,
        message: message,
        place: place,
        university: university,
      );
    } catch (_) {
      // Falló aún con conexión → guardar para reintentar luego
      await _cacheService.cachePendingNotification(data);
      return false;
    }
  }
}
