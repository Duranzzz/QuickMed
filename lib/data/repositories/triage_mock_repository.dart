import '../models/symptom_model.dart';
import '../models/triage_session_model.dart';

class TriageMockRepository {
  // "Base de datos" en memoria de sesiones activas
  final Map<String, TriageSession> _sessions = {};

  TriageMockRepository() {
    _seedMockData();
  }

  /// Precarga sesiones de ejemplo para que el Dashboard no aparezca vacío.
  void _seedMockData() {
    final s1 = TriageSession(userId: 'paciente-001')
      ..selectedSymptoms.addAll([kAvailableSymptoms[0], kAvailableSymptoms[3]])
      ..painLevel = PainLevel.severe;   // ← Caso urgente (borde rojo)

    final s2 = TriageSession(userId: 'paciente-002')
      ..selectedSymptoms.addAll([kAvailableSymptoms[2]])
      ..painLevel = PainLevel.moderate;

    final s3 = TriageSession(userId: 'paciente-003')
      ..selectedSymptoms.addAll([kAvailableSymptoms[1], kAvailableSymptoms[4]])
      ..painLevel = PainLevel.mild;

    _sessions['paciente-001'] = s1;
    _sessions['paciente-002'] = s2;
    _sessions['paciente-003'] = s3;
  }

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

  /// Devuelve todas las sesiones ordenadas: urgentes primero (PainLevel.severe).
  Future<List<TriageSession>> getTriageQueue() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final all = _sessions.values.toList();
    all.sort((a, b) => b.painLevel.index.compareTo(a.painLevel.index));
    return all;
  }

  /// Persiste el nivel de dolor en la sesión activa del usuario.
  Future<void> savePainLevel(String userId, PainLevel level) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = _sessions[userId];
    if (session == null) throw Exception('No hay sesión de triaje activa.');
    session.painLevel = level;
  }
}
