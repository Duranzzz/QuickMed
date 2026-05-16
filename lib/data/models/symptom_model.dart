import 'package:flutter/material.dart';

class Symptom {
  final String id;
  final String label;     // Una sola palabra (criterio HU 3)
  final IconData icon;

  const Symptom({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Catálogo de síntomas disponibles en el triaje.
const List<Symptom> kAvailableSymptoms = [
  Symptom(id: 'head',     label: 'Cabeza',    icon: Icons.person),
  Symptom(id: 'stomach',  label: 'Estómago',  icon: Icons.sick),
  Symptom(id: 'bones',    label: 'Huesos',    icon: Icons.accessibility_new),
  Symptom(id: 'heart',    label: 'Corazón',   icon: Icons.favorite),
  Symptom(id: 'lungs',    label: 'Pulmones',  icon: Icons.air),
  Symptom(id: 'other',    label: 'Otro',      icon: Icons.more_horiz),
];
