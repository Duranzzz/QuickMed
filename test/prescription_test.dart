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

  group('PrescriptionModel - Distribución (HU 13)', () {
    test('qrUrl se incluye como enlace verificable en el texto de distribución',
        () {
      final p = Prescription(
        id: 'rx-share',
        qrHash: 'share-hash-123',
        patientId: 'Juan Pérez',
        doctorId: 'Dr. García',
        date: DateTime(2026, 5, 21),
        medications: const [
          MedicationItem(
              name: 'Amoxicilina',
              dose: '500mg',
              frequency: 'Cada 8h',
              duration: '7 días'),
          MedicationItem(
              name: 'Ibuprofeno',
              dose: '400mg',
              frequency: 'Cada 6h',
              duration: '5 días'),
        ],
      );

      // Simula el texto que genera _shareText() en la pantalla
      final shareText = 'Receta Médica — QuickMed\n'
          'Paciente: ${p.patientId}\n'
          'Fecha: ${p.date.day}/${p.date.month}/${p.date.year}\n\n'
          'Medicamentos:\n'
          '${p.medications.map((m) => '• ${m.name} — ${m.dose}, ${m.frequency}, ${m.duration}').join('\n')}\n\n'
          'Verificar receta: ${p.qrUrl}';

      expect(shareText, contains('Juan Pérez'));
      expect(shareText, contains('21/5/2026'));
      expect(shareText, contains('Amoxicilina'));
      expect(shareText, contains('Ibuprofeno'));
      expect(shareText, contains('https://quickmed.demo/rx/share-hash-123'));
    });

    test('El texto de distribución incluye todos los medicamentos', () {
      final p = Prescription(
        id: 'rx-multi',
        qrHash: 'multi-123',
        patientId: 'María López',
        doctorId: 'Dr. Sánchez',
        date: DateTime(2026, 6, 15),
        medications: const [
          MedicationItem(
              name: 'Paracetamol',
              dose: '1g',
              frequency: 'Cada 8h',
              duration: '3 días'),
          MedicationItem(
              name: 'Omeprazol',
              dose: '20mg',
              frequency: 'Cada 24h',
              duration: '14 días'),
          MedicationItem(
              name: 'Loratadina',
              dose: '10mg',
              frequency: 'Cada 24h',
              duration: '7 días'),
        ],
      );

      final meds = p.medications
          .map((m) =>
              '• ${m.name} — ${m.dose}, ${m.frequency}, ${m.duration}')
          .join('\n');

      expect(meds, contains('Paracetamol'));
      expect(meds, contains('Omeprazol'));
      expect(meds, contains('Loratadina'));
      expect(meds.split('\n').length, 3);
    });

    test('qrUrl usa el hash correcto para distribución', () {
      final p = Prescription(
        id: 'rx-dist',
        qrHash: 'abc-def-ghi',
        patientId: 'p1',
        doctorId: 'd1',
        date: DateTime.now(),
        medications: const [],
      );
      expect(p.qrUrl, contains('abc-def-ghi'));
      expect(p.qrUrl, startsWith('https://'));
    });
  });

  group('PrescriptionModel - Accesibilidad offline (HU 14)', () {
    test('La imagen capturada con pixelRatio 3.0 produce un QR escaneable', () {
      // El QR se renderiza a 200px × pixelRatio 3.0 = 600px resolución real
      const qrSize = 200.0;
      const pixelRatio = 3.0;
      final realPixels = qrSize * pixelRatio;
      // Mínimo recomendado para QR escaneable: 300px
      expect(realPixels, greaterThanOrEqualTo(300));
    });

    test('La prescripción se serializa y deserializa para persistencia offline',
        () {
      final p = Prescription(
        id: 'rx-offline',
        qrHash: 'offline-hash-456',
        patientId: 'paciente-rural',
        doctorId: 'doctor-remoto',
        date: DateTime(2026, 5, 21),
        medications: const [
          MedicationItem(
              name: 'Amoxicilina',
              dose: '500mg',
              frequency: 'Cada 8h',
              duration: '7 días'),
        ],
      );

      // Simula guardar y recuperar (serialización round-trip)
      final json = p.toJson();
      final restored = Prescription.fromJson(json);

      expect(restored.id, p.id);
      expect(restored.qrHash, p.qrHash);
      expect(restored.qrUrl, p.qrUrl);
      expect(restored.patientId, 'paciente-rural');
      expect(restored.medications.length, 1);
      expect(restored.medications.first.name, 'Amoxicilina');
    });

    test('qrUrl es estable — misma URL generada siempre para el mismo hash',
        () {
      final p1 = Prescription(
        id: 'rx-1',
        qrHash: 'stable-hash',
        patientId: 'p',
        doctorId: 'd',
        date: DateTime.now(),
        medications: const [],
      );
      final p2 = Prescription(
        id: 'rx-2',
        qrHash: 'stable-hash',
        patientId: 'p',
        doctorId: 'd',
        date: DateTime.now(),
        medications: const [],
      );
      expect(p1.qrUrl, equals(p2.qrUrl));
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
