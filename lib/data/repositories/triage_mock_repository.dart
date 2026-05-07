import '../models/symptom_model.dart';
import '../models/triage_session_model.dart';

class TriageMockRepository {
  // "Base de datos" en memoria de sesiones activas
  final Map<String, TriageSession> _sessions = {};

  /// Inicia (o reinicia) una sesión de triaje para el usuario dado.
  Future<TriageSession> startSession(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = TriageSession(userId: userId);
    _sessions[userId] = session;
    return session;
  }

  /// Devuelve la sesión activa del usuario, o null si no tiene.
  TriageSession? getSession(String userId) => _sessions[userId];

  /// Guarda los síntomas seleccionados en la sesión del usuario.
  Future<void> saveSymptoms(String userId, List<Symptom> symptoms) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = _sessions[userId];
    if (session == null) throw Exception('No hay sesión de triaje activa.');
    session.selectedSymptoms
      ..clear()
      ..addAll(symptoms);
  }

  /// Devuelve todas las sesiones (para el Dashboard del médico).
  Future<List<TriageSession>> getAllSessions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _sessions.values.toList();
  }
}
