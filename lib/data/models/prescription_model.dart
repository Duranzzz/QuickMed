import 'package:flutter/foundation.dart';

/// Estado de una receta médica.
enum PrescriptionStatus { active, expired, dispensed }

/// Un medicamento individual dentro de una receta.
class MedicationItem {
  final String name;
  final String dose;
  final String frequency;
  final String duration;

  const MedicationItem({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'duration': duration,
      };

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      name: json['name'] as String,
      dose: json['dose'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );
  }
}

/// Receta médica completa con QR hash único.
@immutable
class Prescription {
  final String id;
  final String qrHash;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final List<MedicationItem> medications;
  final PrescriptionStatus status;

  const Prescription({
    required this.id,
    required this.qrHash,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.medications,
    this.status = PrescriptionStatus.active,
  });

  /// URL simulada que contiene el QR (para la demo).
  String get qrUrl => 'https://quickmed.demo/rx/$qrHash';

  Prescription copyWith({PrescriptionStatus? status}) {
    return Prescription(
      id: id,
      qrHash: qrHash,
      patientId: patientId,
      doctorId: doctorId,
      date: date,
      medications: medications,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'qrHash': qrHash,
        'patientId': patientId,
        'doctorId': doctorId,
        'date': date.toIso8601String(),
        'medications': medications.map((m) => m.toJson()).toList(),
        'status': status.name,
      };

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      qrHash: json['qrHash'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      date: DateTime.parse(json['date'] as String),
      medications: (json['medications'] as List)
          .map((m) => MedicationItem.fromJson(m as Map<String, dynamic>))
          .toList(),
      status: PrescriptionStatus.values.byName(json['status'] as String),
    );
  }
}
