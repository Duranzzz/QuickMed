import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/models/symptom_model.dart';
import 'package:quickmed/data/repositories/triage_mock_repository.dart';

void main() {
  late TriageMockRepository repository;
  const testUserId = 'user-test-123';

  setUp(() async {
    repository = TriageMockRepository();
    await repository.startSession(testUserId);
  });

  group('TriageMockRepository - Sesión', () {
    test('Inicia sesión y la devuelve sin síntomas', () {
      final session = repository.getSession(testUserId);
      expect(session, isNotNull);
      expect(session!.userId, testUserId);
      expect(session.selectedSymptoms, isEmpty);
    });

    test('Devuelve null para un usuario sin sesión activa', () {
      final session = repository.getSession('otro-usuario');
      expect(session, isNull);
    });
  });

  group('TriageMockRepository - Síntomas', () {
    test('Guarda la lista de síntomas seleccionados', () async {
      final symptoms = [
        kAvailableSymptoms[0], // Cabeza
        kAvailableSymptoms[2], // Huesos
      ];
      await repository.saveSymptoms(testUserId, symptoms);

      final session = repository.getSession(testUserId);
      expect(session!.selectedSymptoms.length, 2);
      expect(session.selectedSymptoms.map((s) => s.id),
          containsAll(['head', 'bones']));
    });

    test('Sobreescribe síntomas anteriores al guardar de nuevo', () async {
      await repository.saveSymptoms(testUserId, [kAvailableSymptoms[0]]);
      await repository.saveSymptoms(testUserId, [kAvailableSymptoms[1]]);

      final session = repository.getSession(testUserId);
      expect(session!.selectedSymptoms.length, 1);
      expect(session.selectedSymptoms.first.id, 'stomach');
    });

    test('El catálogo tiene los síntomas esperados (incluyendo Otro)', () {
      expect(kAvailableSymptoms.length, 6);
      expect(kAvailableSymptoms.last.id, 'other');
    });

    test('Cada síntoma tiene label de una sola palabra', () {
      for (final symptom in kAvailableSymptoms) {
        expect(symptom.label.split(' ').length, 1,
            reason: '${symptom.label} tiene más de una palabra');
      }
    });

    test('Lanza excepción al guardar síntomas sin sesión activa', () async {
      String? errorMsg;
      try {
        await repository.saveSymptoms('usuario-sin-sesion', [kAvailableSymptoms[0]]);
      } catch (e) {
        errorMsg = e.toString();
      }
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('No hay sesión de triaje activa'));
    });
  });

  group('TriageMockRepository - getTriageQueue', () {
    test('Devuelve las sesiones registradas', () async {
      // Crear otra sesión
      await repository.startSession('otro-usuario');
      final sessions = await repository.getTriageQueue();
      expect(sessions.length, greaterThanOrEqualTo(2));
    });
  });
}
