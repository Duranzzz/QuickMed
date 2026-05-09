import 'package:flutter/material.dart';
import '../../data/models/triage_session_model.dart';

/// Tarjeta de paciente para el Dashboard del médico.
/// Muestra borde rojo y badge de urgencia si el dolor es "Fuerte".
class PatientTriageCard extends StatelessWidget {
  final TriageSession session;

  const PatientTriageCard({super.key, required this.session});

  bool get _isUrgent => session.painLevel == PainLevel.severe;

  Color get _borderColor {
    switch (session.painLevel) {
      case PainLevel.severe:
        return const Color(0xFFF44336);
      case PainLevel.moderate:
        return const Color(0xFFFFC107);
      case PainLevel.mild:
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey.shade300;
    }
  }

  String get _painLabel {
    switch (session.painLevel) {
      case PainLevel.severe:
        return 'URGENTE';
      case PainLevel.moderate:
        return 'Moderado';
      case PainLevel.mild:
        return 'Leve';
      default:
        return 'Sin datos';
    }
  }

  String get _painEmoji {
    switch (session.painLevel) {
      case PainLevel.severe:
        return '😣';
      case PainLevel.moderate:
        return '😐';
      case PainLevel.mild:
        return '😊';
      default:
        return '❔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _isUrgent
            ? const Color(0xFFFFF5F5)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: _isUrgent ? 2.5 : 1.5),
        boxShadow: _isUrgent
            ? [
                BoxShadow(
                  color: const Color(0xFFF44336).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: ID del paciente + badge de urgencia
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _borderColor.withOpacity(0.15),
                  child: Icon(Icons.person, color: _borderColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente: ${session.userId}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Hace ${DateTime.now().difference(session.createdAt).inMinutes} min',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                // Badge de nivel de dolor
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_painEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        _painLabel,
                        style: TextStyle(
                          color: _isUrgent ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Síntomas seleccionados
            if (session.selectedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              const Text(
                'Síntomas reportados:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: session.selectedSymptoms.map((s) {
                  return Chip(
                    avatar: Icon(s.icon, size: 16, color: _borderColor),
                    label: Text(s.label,
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor:
                        _borderColor.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
