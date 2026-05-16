import 'symptom_model.dart';

enum PainLevel { none, veryMild, mild, moderate, severe, verySevere }

class TriageSession {
  final String userId;
  final List<Symptom> selectedSymptoms;
  PainLevel painLevel;
  /// Dolor por síntoma individual (HU 8 mejora).
  final Map<String, PainLevel> symptomPainLevels;
  final DateTime createdAt;

  TriageSession({
    required this.userId,
    List<Symptom>? selectedSymptoms,
    this.painLevel = PainLevel.none,
    Map<String, PainLevel>? symptomPainLevels,
    DateTime? createdAt,
  })  : selectedSymptoms = selectedSymptoms ?? [],
        symptomPainLevels = symptomPainLevels ?? {},
        createdAt = createdAt ?? DateTime.now();

  /// Calcula el nivel general como el máximo dolor entre todos los síntomas.
  PainLevel get overallPainLevel {
    if (symptomPainLevels.isEmpty) return painLevel;
    return symptomPainLevels.values.reduce(
      (max, level) => level.index > max.index ? level : max,
    );
  }
}
