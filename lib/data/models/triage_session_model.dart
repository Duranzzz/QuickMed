import 'symptom_model.dart';

enum PainLevel { none, mild, moderate, severe }

class TriageSession {
  final String userId;
  final List<Symptom> selectedSymptoms;
  PainLevel painLevel;
  final DateTime createdAt;

  TriageSession({
    required this.userId,
    List<Symptom>? selectedSymptoms,
    this.painLevel = PainLevel.none,
    DateTime? createdAt,
  })  : selectedSymptoms = selectedSymptoms ?? [],
        createdAt = createdAt ?? DateTime.now();
}
