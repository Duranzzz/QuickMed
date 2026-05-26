import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/symptom_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/triage_provider.dart';
import '../widgets/symptom_button.dart';
import 'pain_screen.dart';

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia la sesión de triaje al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<TriageProvider>().startSession(userId);
    });
  }

  Future<void> _onContinue() async {
    final triageProvider = context.read<TriageProvider>();
    if (triageProvider.selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un síntoma para continuar.')),
      );
      return;
    }
    final saved = await triageProvider.saveSymptoms();
    if (saved && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final triageProvider = context.watch<TriageProvider>();
    final selectedCount = triageProvider.selectedSymptoms.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué te molesta?'),
        centerTitle: true,
      ),
      body: triageProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Toca todo lo que sientes',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Puedes elegir más de uno',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Lista de síntomas (máx 5 por HU 3)
                    Expanded(
                      child: ListView.separated(
                        itemCount: kAvailableSymptoms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final symptom = kAvailableSymptoms[index];
                          return SymptomButton(
                            symptom: symptom,
                            isSelected: triageProvider.isSelected(symptom),
                            onTap: () => triageProvider.toggleSymptom(symptom),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contador de síntomas seleccionados
                    if (selectedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '$selectedCount síntoma${selectedCount > 1 ? 's' : ''} seleccionado${selectedCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ElevatedButton(
                      onPressed: triageProvider.isLoading ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
