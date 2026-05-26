import '../models/prescription_model.dart';

/// Repositorio mock para recetas médicas.
/// Almacena en memoria. En producción sería una API REST + base de datos.
class PrescriptionMockRepository {
  /// Singleton compartido para la demo (doctor y paciente usan la misma instancia).
  static final PrescriptionMockRepository shared = PrescriptionMockRepository();

  /// "Base de datos" en memoria indexada por qrHash para búsqueda rápida.
  final Map<String, Prescription> _prescriptions = {};

  /// Guarda una nueva receta.
  Future<void> savePrescription(Prescription prescription) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _prescriptions[prescription.qrHash] = prescription;
  }

  /// Obtiene una receta por su hash QR (para verificación del farmacéutico).
  Future<Prescription?> getByQrHash(String qrHash) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _prescriptions[qrHash];
  }

  /// Obtiene todas las recetas de un paciente.
  Future<List<Prescription>> getByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _prescriptions.values
        .where((p) => p.patientId == patientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Más reciente primero
  }

  /// Marca una receta como dispensada (el farmacéutico la despacha).
  Future<bool> dispensePrescription(String qrHash) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prescription = _prescriptions[qrHash];
    if (prescription == null) return false;
    _prescriptions[qrHash] = prescription.copyWith(
      status: PrescriptionStatus.dispensed,
    );
    return true;
  }

  /// Devuelve todas las recetas (para debug/testing).
  List<Prescription> get allPrescriptions => _prescriptions.values.toList();
}
