import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/models/triage_session_model.dart';
import 'package:quickmed/data/repositories/triage_mock_repository.dart';

void main() {
  late TriageMockRepository repository;

  setUp(() {
    repository = TriageMockRepository();
  });

  group('Dashboard Médico - Cola de triaje', () {
    test('getTriageQueue devuelve al menos los 3 pacientes mock pre-cargados', () async {
      final queue = await repository.getTriageQueue();
      expect(queue.length, greaterThanOrEqualTo(3));
    });

    test('El primer paciente de la cola tiene PainLevel.severe (urgente primero)', () async {
      final queue = await repository.getTriageQueue();
      expect(queue.first.painLevel, PainLevel.severe);
    });

    test('El último paciente de la cola no tiene PainLevel.severe', () async {
      final queue = await repository.getTriageQueue();
      expect(queue.last.painLevel, isNot(PainLevel.severe));
    });

    test('Todos los pacientes con PainLevel.severe aparecen antes que los demás', () async {
      final queue = await repository.getTriageQueue();
      bool foundNonSevere = false;
      for (final session in queue) {
        if (session.painLevel != PainLevel.severe) {
          foundNonSevere = true;
        }
        // Si ya encontramos un no-urgente, no puede venir un urgente después
        if (foundNonSevere && session.painLevel == PainLevel.severe) {
          fail('Un paciente urgente apareció después de uno no urgente');
        }
      }
      expect(true, isTrue); // Llegó aquí sin fallo → orden correcto
    });

    test('Un nuevo paciente con PainLevel.severe aparece en la cola', () async {
      await repository.startSession('nuevo-urgente');
      await repository.savePainLevel('nuevo-urgente', PainLevel.severe);

      final queue = await repository.getTriageQueue();
      final found = queue.any(
          (s) => s.userId == 'nuevo-urgente' && s.painLevel == PainLevel.severe);
      expect(found, isTrue);
    });

    test('Un nuevo paciente con PainLevel.severe queda al inicio de la cola', () async {
      await repository.startSession('paciente-nuevo-urgente');
      await repository.savePainLevel('paciente-nuevo-urgente', PainLevel.severe);

      final queue = await repository.getTriageQueue();
      // Los primeros de la lista deben ser todos severe
      final firstNonSevereIndex =
          queue.indexWhere((s) => s.painLevel != PainLevel.severe);
      final newPatientIndex =
          queue.indexWhere((s) => s.userId == 'paciente-nuevo-urgente');

      expect(newPatientIndex, lessThan(firstNonSevereIndex));
    });

    test('Cada sesión mock tiene al menos un síntoma registrado', () async {
      final queue = await repository.getTriageQueue();
      for (final session in queue) {
        expect(session.selectedSymptoms, isNotEmpty,
            reason: 'El paciente ${session.userId} no tiene síntomas');
      }
    });
  });
}
