import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/triage_session_model.dart';
import '../../providers/triage_provider.dart';
import '../widgets/pain_level_selector.dart';
import 'doctor_dashboard_screen.dart';

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  PainLevel? _selectedLevel;

  Future<void> _onConfirm() async {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona cómo es tu dolor para continuar.')),
      );
      return;
    }

    final triageProvider = context.read<TriageProvider>();
    final saved = await triageProvider.savePainLevel(_selectedLevel!);

    if (saved && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
      );
    }
  }

  String _levelLabel(PainLevel level) {
    switch (level) {
      case PainLevel.mild:
        return 'Leve';
      case PainLevel.moderate:
        return 'Moderado';
      case PainLevel.severe:
        return 'Fuerte';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TriageProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cómo es el dolor?'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Indica cuánto te duele',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Elige la opción que más se parezca a cómo te sientes',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PainLevelSelector(
              selected: _selectedLevel,
              onSelected: (level) => setState(() => _selectedLevel = level),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _onConfirm,
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
                  : const Text('Confirmar', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Color? _buttonColor(PainLevel level) {
    switch (level) {
      case PainLevel.mild:
        return const Color(0xFF4CAF50);
      case PainLevel.moderate:
        return const Color(0xFFFFC107);
      case PainLevel.severe:
        return const Color(0xFFF44336);
      default:
        return null;
    }
  }
}
