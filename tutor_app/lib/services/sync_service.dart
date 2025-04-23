import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/review_service.dart';
import '../services/location_service.dart';
import '../services/local_cache_service.dart';
import '../models/review_model.dart';

class SyncService {
  final ReviewService _reviewService;
  final LocationService _locationService;
  final LocalCacheService _cacheService;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SyncService({
    required this.scaffoldMessengerKey,
    ReviewService? reviewService,
    LocationService? locationService,
    LocalCacheService? cacheService,
  })  : _reviewService = reviewService ?? ReviewService(),
        _locationService = locationService ?? LocationService(),
        _cacheService = cacheService ?? LocalCacheService() {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
  debugPrint("🛰️ Subscribing to connectivity changes...");

  _connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
    debugPrint("🔌 Connectivity changed: $result");

    if (result != ConnectivityResult.none) {
      await syncPendingData();
    }
  });
}



  Future<void> syncPendingData() async {
  debugPrint("📡 Intentando sincronizar datos...");

  final hasInternet = await _hasInternetConnection();
  debugPrint("🌐 Internet activo: $hasInternet");

  if (!hasInternet) {
    debugPrint("🚫 Sin internet. Reintentando...");
    await _retryConnection();
    return;
  }

  final sentReviews = await _syncReviews();
  final sentNotifs = await _syncNotifications();

  debugPrint("✅ Reseñas enviadas: $sentReviews");
  debugPrint("✅ Notificaciones enviadas: $sentNotifs");

  if (sentReviews > 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('✅ $sentReviews reseña(s) pendiente(s) enviada(s) al recuperar conexión.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  if (sentNotifs > 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('🔔 $sentNotifs notificación(es) enviada(s) al recuperar conexión.'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}


  Future<void> _retryConnection() async {
    const interval = Duration(seconds: 10);
      await Future.delayed(interval);
      final isConnected = await _hasInternetConnection();

      if (isConnected) {
        await syncPendingData();
        return;
      }

     

    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('⚠️ No se pudo establecer conexión después de 6 intentos. Intenta enviar tu reseña más tarde.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<int> _syncReviews() async {
  final pendingReviews = await _cacheService.getPendingReviews();
  debugPrint("📦 Reseñas pendientes encontradas: ${pendingReviews.length}");
  int sentCount = 0;

  for (final review in pendingReviews) {
    debugPrint("🚀 Enviando reseña para sessionId ${review.tutoringSessionId}...");
    try {
      final success = await _reviewService.submitReview(review);
      debugPrint("📬 Resultado de envío: $success");

      if (success) {
        await _cacheService.removePendingReview(review); 
        sentCount++;
      }
    } catch (e) {
      debugPrint("❌ Error al enviar reseña: $e");
    }
  }

  return sentCount;
}


  Future<int> _syncNotifications() async {
    final pendingNotifications = await _cacheService.getPendingNotifications();
    int sentCount = 0;

    for (final notif in pendingNotifications) {
      try {
        final success = await _locationService.sendNotification(
          title: notif['title'],
          message: notif['message'],
          place: notif['place'],
          university: notif['university'],
        );
        if (success) sentCount++;
      } catch (_) {
        break;
      }
    }

    if (sentCount == pendingNotifications.length) {
      await _cacheService.clearPendingNotifications();
    }

    return sentCount;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
  
}
