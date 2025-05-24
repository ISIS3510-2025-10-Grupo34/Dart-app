import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_database_service.dart';
import 'review_service.dart';
import 'location_service.dart';
import 'local_cache_service.dart';
import '../services/user_service.dart';
import '../services/tutoring_session_service.dart';
import '../providers/sign_in_process_provider.dart';

class SyncService {
  final ReviewService _reviewService;
  final LocationService _locationService;
  final LocalCacheService _cacheService;
  final UserService _userService;
  final TutoringSessionService _tutoringSessionService;
  final SignInProcessProvider _signInProcessProvider;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final LocalDatabaseService _dbService;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(
      {required this.scaffoldMessengerKey,
      ReviewService? reviewService,
      LocationService? locationService,
      LocalCacheService? cacheService,
      UserService? userService,
      TutoringSessionService? tutoringSessionService,
      LocalDatabaseService? dbService,
      required SignInProcessProvider signInProcessProvider})
      : _reviewService = reviewService ?? ReviewService(),
        _locationService = locationService ?? LocationService(),
        _cacheService = cacheService ?? LocalCacheService(),
        _userService = userService ?? UserService(),
        _dbService = dbService ?? LocalDatabaseService(),
        _tutoringSessionService = tutoringSessionService ?? TutoringSessionService(),
        _signInProcessProvider = signInProcessProvider {
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
      final sentRegistrations = await _syncRegistrations();
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

      if (sentReviews > 0) {
        _showSnack('🔔 $sentReviews Review sent.', Colors.blue);
      }
      if (sentRegistrations > 0) {}
      if (sentNotifs > 0) {
        _showSnack('🔔 $sentNotifs Notification sent.', Colors.blue);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _syncReviews() async {
  final pendingReviews = await _dbService.getPendingReviews();
  int sentCount = 0;

  for (final review in pendingReviews) {
    debugPrint("🚀 Intentando enviar reseña para sessionId ${review.tutoringSessionId}...");
    bool sent = false;

    for (int attempt = 1; attempt <= 48 && !sent; attempt++) {
      try {
        final success = await _reviewService.submitReview(review);
        debugPrint("🔁 Intento $attempt - Resultado: $success");

        if (success) {
          await _dbService.removePendingReview(review);
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
      debugPrint("⚠️ Fallaron todos los intentos para sessionId ${review.tutoringSessionId}");
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

  Future<int> _syncRegistrations() async {
    final pendingRegistrations = await _cacheService.getPendingRegistrations();
    int sentCount = 0;
    if (pendingRegistrations.isEmpty) {
      debugPrint("SyncService: No pending registrations found.");
      return 0;
    }
    debugPrint(
        "SyncService: Found ${pendingRegistrations.length} pending registrations.");

    List<Map<String, dynamic>> registrationsToProcess =
        List.from(pendingRegistrations);

    for (final regData in registrationsToProcess) {
      final String? timestamp =
          regData['timestamp'] as String?; // Keep track for removal/update
      debugPrint(
          "SyncService: Attempting to sync registration with timestamp: $timestamp");

      try {
        final userData = regData['userData'] as Map<String, dynamic>?;
        final profilePath = regData['profilePicturePath'] as String?;
        final idPath = regData['idPicturePath'] as String?;
        if (userData == null || idPath == null || timestamp == null) {
          debugPrint(
              "SyncService: Skipping registration due to missing data (userData, idPath, or timestamp).");
          await _cacheService.removePendingRegistration(regData);
          continue;
        }
        final Map<String, String> stringUserData =
            userData.map((key, value) => MapEntry(key, value.toString()));

        bool success = await _userService.registerUser(
            stringUserData, profilePath, idPath);

        if (success) {
          debugPrint(
              "SyncService: Successfully submitted registration for timestamp: $timestamp");
          await _cacheService.removePendingRegistration(regData);
          _signInProcessProvider.setBackgroundSyncSuccess();
          sentCount++;
        } else {
          debugPrint(
              "SyncService: Failed to submit registration (server rejected?) for timestamp: $timestamp");
          await _cacheService.removePendingRegistration(regData);
          _signInProcessProvider.setBackgroundSyncError(
              "Failed to sync registration. Server rejected the request.");
        }
      } catch (e) {
        debugPrint(
            "SyncService: Error during sync attempt for timestamp $timestamp: $e");
        await _cacheService.removePendingRegistration(regData);
        _signInProcessProvider.setBackgroundSyncError(
            "Error syncing registration: ${e.toString()}");
      }
    }
    debugPrint(
        "SyncService: Finished processing registrations. Sent count: $sentCount");
    return sentCount;
  }

  Future<int> _syncTutoringSessions() async {
    final pendingSessions = await _cacheService.getPendingRegistrations();
    int sentCount = 0;

    for (final session in pendingSessions) {
      if (session.containsKey('userData')) {
        // Este no es una sesión de tutoría sino una cuenta, se ignora aquí
        continue;
      }

      final String? timestamp = session['timestamp'] as String?;
      final int? cost = session['cost'] as int?;
      final int? courseId = session['courseId'] as int?;
      final int? tutorId = session['tutorId'] as int?;
      final String? dateTime = session['dateTime'] as String?;

      if (timestamp == null || cost == null || courseId == null || tutorId == null || dateTime == null) {
        debugPrint("SyncService: Skipping tutoring session due to incomplete data.");
        await _cacheService.removePendingRegistration(session);
        continue;
      }

      debugPrint("SyncService: Attempting to sync tutoring session with timestamp: $timestamp");

      try {
        await _tutoringSessionService.createTutoringSession(
          cost: cost,
          dateTime: dateTime,
          courseId: courseId,
          tutorId: tutorId,
        );

        debugPrint("✅ Tutoring session submitted for timestamp: $timestamp");
        await _cacheService.removePendingRegistration(session);
        sentCount++;
      } catch (e) {
        debugPrint("❌ Failed to sync tutoring session [$timestamp]: $e");
      }
    }

    return sentCount;
  }

}
