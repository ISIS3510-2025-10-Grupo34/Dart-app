import 'package:flutter/foundation.dart';
import 'package:tutor_app/models/tutoring_session_model.dart';
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/services/tutoring_session_service.dart';
import 'package:tutor_app/services/user_service.dart';

class BookedSessionsController extends ChangeNotifier {
  final TutoringSessionService sessionService;
  final UserService userService;
  final AuthProvider authProvider;

  bool _isLoading = false;
  List<TutoringSession> _sessions = [];
  final Map<String, String> _studentLearningStyles = {}; // 👈 bien declarado como final y correcto

  BookedSessionsController({
    required this.sessionService,
    required this.userService,
    required this.authProvider,
  });

  List<TutoringSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  String getLearningStyle(String? studentId) {
    if (studentId == null) return "No asignado";
    return _studentLearningStyles[studentId] ?? "Cargando...";
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = authProvider.currentUser;
      if (currentUser?.id == null) {
        debugPrint("[BookedSessionsController] Usuario actual sin ID.");
        _sessions = [];
        _studentLearningStyles.clear();
      } else {
        final tutorId = int.tryParse(currentUser!.id!);
        if (tutorId == null) {
          debugPrint("[BookedSessionsController] ID de tutor inválido.");
          _sessions = [];
          _studentLearningStyles.clear();
        } else {
          final allSessions = await sessionService.fetchTutoringSessions();
          debugPrint("[BookedSessionsController] Sesiones obtenidas: ${allSessions.length}");

          _sessions = allSessions
              .where((s) => s.tutorId == tutorId && s.student != null)
              .toList();

          debugPrint("[BookedSessionsController] Sesiones filtradas: ${_sessions.length}");

          _studentLearningStyles.clear(); 

          final studentIds = _sessions
          .map((s) => s.student)
          .whereType<String>() // ✅ Filtra solo los que son String realmente
          .where((id) => id.isNotEmpty)
          .toSet();

          for (final studentId in studentIds) {
            try {
              final profile = await userService.fetchStudentProfile(studentId);
              final learningStyle = profile?['learning_styles']?.toString() ?? "No definido";
              _studentLearningStyles[studentId] = learningStyle;
            } catch (e) {
              debugPrint("❌ Error al cargar perfil de $studentId: $e");
              _studentLearningStyles[studentId] = "Desconocido";
            }
          }
          debugPrint("[BookedSessionsController] Estilos cargados: ${_studentLearningStyles.length}");
        }
      }
    } catch (e) {
      debugPrint("[BookedSessionsController] Error cargando sesiones: $e");
      _sessions = [];
      _studentLearningStyles.clear();
    }

    _isLoading = false;
    notifyListeners();
  }
}
