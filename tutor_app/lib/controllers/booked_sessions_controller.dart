import 'package:flutter/foundation.dart';
import 'package:tutor_app/models/tutoring_session_model.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/services/tutoring_session_service.dart';
import 'package:tutor_app/services/local_cache_service.dart';

class BookedSessionsController extends ChangeNotifier {
  final TutoringSessionService sessionService;
  final AuthProvider authProvider;
  final LocalCacheService cacheService;

  bool _isLoading = false;
  List<TutoringSession> _sessions = [];

  BookedSessionsController({
    required this.sessionService,
    required this.authProvider,
    required this.cacheService,
  });

  List<TutoringSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = authProvider.currentUser;
      if (currentUser?.id == null) {
        debugPrint("[BookedSessionsController] Usuario actual sin ID.");
        _sessions = [];
      } else {
        final tutorId = int.tryParse(currentUser!.id!);
        if (tutorId == null) {
          debugPrint("[BookedSessionsController] ID de tutor inválido.");
          _sessions = [];
        } else {
          final allSessions = await sessionService.fetchTutoringSessions();
          debugPrint("[BookedSessionsController] Sesiones obtenidas: ${allSessions.length}");

          _sessions = allSessions
              .where((s) => s.tutorId == tutorId && s.student != null)
              .toList();

          debugPrint("[BookedSessionsController] Sesiones filtradas: ${_sessions.length}");

          // Cachearlas localmente
          await cacheService.cacheTutoringSessions(_sessions);
        }
      }
    } catch (e) {
      debugPrint("[BookedSessionsController] Error cargando sesiones desde API: $e");

      _sessions = await cacheService.getCachedTutoringSessions();
      debugPrint("[BookedSessionsController] Sesiones desde caché: ${_sessions.length}");
    }

    _isLoading = false;
    notifyListeners();
  }
}
