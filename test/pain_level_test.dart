import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/models/triage_session_model.dart';
import 'package:quickmed/data/repositories/triage_mock_repository.dart';

void main() {
  late TriageMockRepository repository;
  const testUserId = 'user-pain-test';

  setUp(() async {
    repository = TriageMockRepository();
    await repository.startSession(testUserId);
  });

  group('TriageMockRepository - Nivel de Dolor', () {
    test('Por defecto la sesión inicia con PainLevel.none', () {
      final session = repository.getSession(testUserId);
      expect(session!.painLevel, PainLevel.none);
    });

    test('Guarda correctamente PainLevel.mild (Verde)', () async {
      await repository.savePainLevel(testUserId, PainLevel.mild);
      final session = repository.getSession(testUserId);
      expect(session!.painLevel, PainLevel.mild);
    });

    test('Guarda correctamente PainLevel.moderate (Amarillo)', () async {
      await repository.savePainLevel(testUserId, PainLevel.moderate);
      final session = repository.getSession(testUserId);
      expect(session!.painLevel, PainLevel.moderate);
    });

    test('Guarda correctamente PainLevel.severe (Rojo)', () async {
      await repository.savePainLevel(testUserId, PainLevel.severe);
      final session = repository.getSession(testUserId);
      expect(session!.painLevel, PainLevel.severe);
    });

    test('Sobreescribe el nivel de dolor al llamar savePainLevel de nuevo', () async {
      await repository.savePainLevel(testUserId, PainLevel.mild);
      await repository.savePainLevel(testUserId, PainLevel.severe);
      final session = repository.getSession(testUserId);
      expect(session!.painLevel, PainLevel.severe);
    });

    test('Lanza excepción al guardar dolor sin sesión activa', () async {
      String? errorMsg;
      try {
        await repository.savePainLevel('usuario-inexistente', PainLevel.severe);
      } catch (e) {
        errorMsg = e.toString();
      }
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('No hay sesión de triaje activa'));
    });

    test('PainLevel.severe queda en la sesión para que el médico lo detecte', () async {
      await repository.savePainLevel(testUserId, PainLevel.severe);
      final sessions = await repository.getTriageQueue();
      final session = sessions.firstWhere((s) => s.userId == testUserId);
      expect(session.painLevel, PainLevel.severe);
    });
  });
}
