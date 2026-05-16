import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/symptom_model.dart';
import '../../data/models/triage_session_model.dart';
import '../../providers/triage_provider.dart';
import '../widgets/pain_level_selector.dart';
import 'patient_call_setup_screen.dart';

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  /// Índice del síntoma actual que estamos evaluando.
  int _currentSymptomIndex = 0;

  /// Dolor por síntoma: symptomId -> PainLevel.
  final Map<String, PainLevel> _painPerSymptom = {};

  PainLevel? _selectedLevel;

  List<Symptom> get _symptoms =>
      context.read<TriageProvider>().selectedSymptoms;

  Symptom get _currentSymptom => _symptoms[_currentSymptomIndex];

  bool get _isLast => _currentSymptomIndex >= _symptoms.length - 1;

  void _onNext() {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el nivel de dolor para continuar.')),
      );
      return;
    }

    // Guardar nivel de dolor para este síntoma
    _painPerSymptom[_currentSymptom.id] = _selectedLevel!;

    if (_isLast) {
      _onFinish();
    } else {
      setState(() {
        _currentSymptomIndex++;
        _selectedLevel = null;
      });
    }
  }

  Future<void> _onFinish() async {
    final triageProvider = context.read<TriageProvider>();

    // Guardar el mapa completo y el nivel general (máximo)
    final saved = await triageProvider.savePainLevels(_painPerSymptom);

    if (saved && mounted) {
      // Demo: directo al botón de consulta (HU 6). En producción irá la sala de espera (HU 9).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PatientCallSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TriageProvider>().isLoading;
    final total = _symptoms.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dolor: ${_currentSymptom.label} (${_currentSymptomIndex + 1}/$total)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícono del síntoma actual
            Icon(
              _currentSymptom.icon,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              '¿Cuánto te duele: ${_currentSymptom.label}?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Síntoma ${_currentSymptomIndex + 1} de $total',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Selector de 5 niveles
            PainLevelSelector(
              selected: _selectedLevel,
              onSelected: (level) => setState(() => _selectedLevel = level),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isLoading ? null : _onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _selectedLevel != null
                    ? _buttonColor(_selectedLevel!)
                    : null,
                foregroundColor: _selectedLevel != null ? Colors.white : null,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isLast ? 'Confirmar' : 'Siguiente síntoma →',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _buttonColor(PainLevel level) {
    switch (level) {
      case PainLevel.veryMild:
        return const Color(0xFF81C784);
      case PainLevel.mild:
        return const Color(0xFF4CAF50);
      case PainLevel.moderate:
        return const Color(0xFFFFC107);
      case PainLevel.severe:
        return const Color(0xFFFF5722);
      case PainLevel.verySevere:
        return const Color(0xFFF44336);
      default:
        return null;
    }
  }
}
