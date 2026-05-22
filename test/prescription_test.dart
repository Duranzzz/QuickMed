import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/models/prescription_model.dart';
import 'package:quickmed/data/repositories/prescription_mock_repository.dart';

void main() {
  group('PrescriptionModel - Serialización', () {
    test('MedicationItem serializa y deserializa correctamente', () {
      const item = MedicationItem(
        name: 'Amoxicilina',
        dose: '500mg',
        frequency: 'Cada 8h',
        duration: '7 días',
      );
      final json = item.toJson();
      final restored = MedicationItem.fromJson(json);

      expect(restored.name, 'Amoxicilina');
      expect(restored.dose, '500mg');
      expect(restored.frequency, 'Cada 8h');
      expect(restored.duration, '7 días');
    });

    test('Prescription serializa y deserializa correctamente', () {
      final prescription = Prescription(
        id: 'rx-001',
        qrHash: 'abc123',
        patientId: 'paciente-001',
        doctorId: 'doctor-001',
        date: DateTime(2026, 5, 21),
        medications: const [
          MedicationItem(
              name: 'Ibuprofeno',
              dose: '400mg',
              frequency: 'Cada 6h',
              duration: '5 días'),
        ],
      );
      final json = prescription.toJson();
      final restored = Prescription.fromJson(json);

      expect(restored.id, 'rx-001');
      expect(restored.qrHash, 'abc123');
      expect(restored.patientId, 'paciente-001');
      expect(restored.medications.length, 1);
      expect(restored.medications.first.name, 'Ibuprofeno');
      expect(restored.status, PrescriptionStatus.active);
    });

    test('qrUrl contiene el hash correcto', () {
      final p = Prescription(
        id: 'rx-002',
        qrHash: 'xyz789',
        patientId: 'p1',
        doctorId: 'd1',
        date: DateTime.now(),
        medications: const [],
      );
      expect(p.qrUrl, 'https://quickmed.demo/rx/xyz789');
    });

    test('copyWith cambia solo el status', () {
      final p = Prescription(
        id: 'rx-003',
        qrHash: 'test',
        patientId: 'p1',
        doctorId: 'd1',
        date: DateTime.now(),
        medications: const [],
      );
      final dispensed = p.copyWith(status: PrescriptionStatus.dispensed);
      expect(dispensed.status, PrescriptionStatus.dispensed);
      expect(dispensed.id, p.id);
      expect(dispensed.qrHash, p.qrHash);
    });
  });

  group('PrescriptionMockRepository - CRUD', () {
    late PrescriptionMockRepository repo;

    setUp(() {
      repo = PrescriptionMockRepository();
    });

    test('Guarda y recupera una receta por qrHash', () async {
      final p = _createPrescription('hash-1', 'paciente-001');
      await repo.savePrescription(p);

      final found = await repo.getByQrHash('hash-1');
      expect(found, isNotNull);
      expect(found!.patientId, 'paciente-001');
    });

    test('getByQrHash retorna null si no existe', () async {
      final found = await repo.getByQrHash('inexistente');
      expect(found, isNull);
    });

    test('getByPatient devuelve recetas del paciente ordenadas', () async {
      await repo.savePrescription(
          _createPrescription('h1', 'paciente-001', DateTime(2026, 1, 1)));
      await repo.savePrescription(
          _createPrescription('h2', 'paciente-001', DateTime(2026, 5, 1)));
      await repo.savePrescription(
          _createPrescription('h3', 'otro-paciente'));

      final list = await repo.getByPatient('paciente-001');
      expect(list.length, 2);
      // La más reciente primero
      expect(list.first.qrHash, 'h2');
    });

    test('dispensePrescription cambia el status a dispensed', () async {
      await repo.savePrescription(_createPrescription('hash-disp', 'p1'));
      final success = await repo.dispensePrescription('hash-disp');
      expect(success, isTrue);

      final found = await repo.getByQrHash('hash-disp');
      expect(found!.status, PrescriptionStatus.dispensed);
    });

    test('dispensePrescription retorna false si no existe', () async {
      final success = await repo.dispensePrescription('fantasma');
      expect(success, isFalse);
    });
  });
}

Prescription _createPrescription(String hash, String patientId,
    [DateTime? date]) {
  return Prescription(
    id: 'rx-$hash',
    qrHash: hash,
    patientId: patientId,
    doctorId: 'doctor-test',
    date: date ?? DateTime.now(),
    medications: const [
      MedicationItem(
          name: 'TestMed', dose: '100mg', frequency: '1x', duration: '3d'),
    ],
  );
}
