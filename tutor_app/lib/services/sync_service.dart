import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'review_service.dart';
import 'location_service.dart';
import 'local_cache_service.dart';
import '../models/review_model.dart';

class SyncService {
  final ReviewService _reviewService;
  final LocationService _locationService;
  final LocalCacheService _cacheService;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;

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
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      debugPrint("📡 Cambio de conectividad detectado: $result");
      if (result != ConnectivityResult.none && !_isSyncing) {
        await syncPendingData();
      }
    });
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      if (!await _hasInternetConnection()) {
        debugPrint("🚫 Sin conexión real a internet.");
        await _retryConnection();
        return;
      }

      final sentReviews = await _syncReviews();
      final now = DateTime.now();
      final pendingNotifs = await _cacheService.getPendingNotificationsRaw();

      final validNotifs = pendingNotifs.where((notif) {
        final deadlineStr = notif['deadline'];
        if (deadlineStr == null) return false;

        try {
          final deadline = DateTime.parse(deadlineStr);
          return deadline.isAfter(now);
        } catch (_) {
          return false;
        }
      }).toList();

      final sentNotifs = await _cacheService.syncNotificationsWithService(
        _locationService,
        notificationsToSend: validNotifs,
      );

      if (sentReviews > 0)
        _showSnack('🔔 $sentReviews Review sent.', Colors.blue);
      if (sentNotifs > 0)
        _showSnack('🔔 $sentNotifs Notification sent.', Colors.blue);
    } catch (e) {
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _syncReviews() async {
    final pendingReviews = await _cacheService.getPendingReviews();
    int sentCount = 0;
    for (final review in pendingReviews) {
      debugPrint(
          "🚀 Intentando enviar reseña para sessionId ${review.tutoringSessionId}...");
      bool sent = false;
      for (int attempt = 1; attempt <= 48 && !sent; attempt++) {
        try {
          final success = await _reviewService.submitReview(review);
          debugPrint("🔁 Intento $attempt - Resultado: $success");

          if (success) {
            await _cacheService.removePendingReview(review);
            sentCount++;
            sent = true;
          } else {
            await Future.delayed(Duration(seconds: 3 * attempt));
          }
        } catch (e) {
          debugPrint("❌ Error en intento $attempt: $e");
          await Future.delayed(Duration(seconds: 3 * attempt));
        }
      }

      if (!sent) {
        debugPrint(
            "⚠️ Fallaron todos los intentos para sessionId ${review.tutoringSessionId}");
      }
    }

    return sentCount;
  }

  Future<void> _retryConnection({int maxAttempts = 6}) async {
    for (int i = 1; i <= maxAttempts; i++) {
      if (await _hasInternetConnection()) {
        await syncPendingData();
        return;
      }
      await Future.delayed(Duration(seconds: 5 * i));
    }
    _showSnack('⚠️ Couldn’t establish connection.', Colors.red);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final res = await InternetAddress.lookup('google.com');
      return res.isNotEmpty && res[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showSnack(String msg, Color color) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
