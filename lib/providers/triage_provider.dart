import 'package:flutter/material.dart';
import '../data/models/symptom_model.dart';
import '../data/models/triage_session_model.dart';
import '../data/repositories/triage_mock_repository.dart';

class TriageProvider extends ChangeNotifier {
  final TriageMockRepository _repository = TriageMockRepository();

  TriageSession? _session;
  final List<Symptom> _selectedSymptoms = [];
  bool _isLoading = false;

  TriageSession? get session => _session;
  List<Symptom> get selectedSymptoms => List.unmodifiable(_selectedSymptoms);
  bool get isLoading => _isLoading;

  Future<void> startSession(String userId) async {
    _isLoading = true;
    notifyListeners();
    _session = await _repository.startSession(userId);
    _selectedSymptoms.clear();
    _isLoading = false;
    notifyListeners();
  }

  void toggleSymptom(Symptom symptom) {
    if (_selectedSymptoms.any((s) => s.id == symptom.id)) {
      _selectedSymptoms.removeWhere((s) => s.id == symptom.id);
    } else {
      _selectedSymptoms.add(symptom);
    }
    notifyListeners();
  }

  bool isSelected(Symptom symptom) =>
      _selectedSymptoms.any((s) => s.id == symptom.id);

  Future<bool> saveSymptoms() async {
    if (_session == null || _selectedSymptoms.isEmpty) return false;
    _isLoading = true;
    notifyListeners();
    await _repository.saveSymptoms(_session!.userId, _selectedSymptoms);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  PainLevel get currentPainLevel => _session?.painLevel ?? PainLevel.none;

  Future<bool> savePainLevel(PainLevel level) async {
    if (_session == null) return false;
    _isLoading = true;
    notifyListeners();
    await _repository.savePainLevel(_session!.userId, level);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Guarda dolor por síntoma y calcula el nivel general (máximo).
  Future<bool> savePainLevels(Map<String, PainLevel> painPerSymptom) async {
    if (_session == null) return false;
    _isLoading = true;
    notifyListeners();
    await _repository.savePainLevels(_session!.userId, painPerSymptom);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // --- Dashboard del médico ---
  List<TriageSession> _triageQueue = [];
  List<TriageSession> get triageQueue => List.unmodifiable(_triageQueue);

  Future<void> fetchTriageQueue() async {
    _isLoading = true;
    notifyListeners();
    _triageQueue = await _repository.getTriageQueue();
    _isLoading = false;
    notifyListeners();
  }
}
