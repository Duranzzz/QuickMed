import 'package:flutter/material.dart';

import '../../data/models/prescription_model.dart';

/// Pantalla de verificación de receta para el farmacéutico (HU 15).
/// Muestra el estado, datos del paciente/médico y medicamentos.
class PharmacyVerificationScreen extends StatelessWidget {
  final Prescription prescription;

  const PharmacyVerificationScreen({super.key, required this.prescription});

  /// Color y texto según el estado de la receta.
  ({Color color, IconData icon, String label}) _statusInfo() {
    switch (prescription.status) {
      case PrescriptionStatus.active:
        return (
          color: const Color(0xFF4CAF50),
          icon: Icons.verified,
          label: 'VÁLIDA',
        );
      case PrescriptionStatus.expired:
        return (
          color: const Color(0xFFF44336),
          icon: Icons.cancel,
          label: 'EXPIRADA',
        );
      case PrescriptionStatus.dispensed:
        return (
          color: const Color(0xFFFF9800),
          icon: Icons.check_circle,
          label: 'DISPENSADA',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo();
    final rx = prescription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Receta'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Estado de la receta ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: status.color, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(status.icon, size: 64, color: status.color),
                    const SizedBox(height: 12),
                    Text(
                      'Receta ${status.label}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusDescription(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: status.color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Datos del paciente y médico ──
              _buildInfoCard(
                title: 'Datos de la Receta',
                children: [
                  _buildInfoRow(Icons.person, 'Paciente', rx.patientId),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.medical_services, 'Médico', rx.doctorId),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Fecha de emisión',
                    '${rx.date.day}/${rx.date.month}/${rx.date.year}',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.fingerprint,
                    'Código de verificación',
                    rx.qrHash,
                    monospace: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Lista de medicamentos ──
              _buildInfoCard(
                title: 'Medicamentos Recetados',
                children: [
                  ...rx.medications.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    return Column(
                      children: [
                        if (i > 0) const Divider(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFFFF3E0),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dosis: ${m.dose}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Frecuencia: ${m.frequency}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Duración: ${m.duration}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // ── Botón de volver a escanear ──
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear otra receta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFFF9800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusDescription() {
    switch (prescription.status) {
      case PrescriptionStatus.active:
        return 'Esta receta es auténtica y puede ser dispensada.';
      case PrescriptionStatus.expired:
        return 'Esta receta ha expirado y no puede ser dispensada.';
      case PrescriptionStatus.dispensed:
        return 'Esta receta ya fue dispensada anteriormente.';
    }
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool monospace = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: monospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
