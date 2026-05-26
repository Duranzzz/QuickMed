import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/triage_session_model.dart';
import '../../providers/triage_provider.dart';
import '../widgets/patient_triage_card.dart';
import 'call_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TriageProvider>().fetchTriageQueue();
    });
  }

  int _urgentCount(List<TriageSession> queue) =>
      queue.where((s) => s.painLevel == PainLevel.severe || s.painLevel == PainLevel.verySevere).length;

  /// HU 10: Admitir al paciente y navegar a la videollamada.
  Future<void> _admitAndCall(String userId) async {
    final triageProvider = context.read<TriageProvider>();
    final admitted = await triageProvider.admitPatient(userId);

    if (admitted != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CallScreen(isDoctor: true, patientId: userId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final triageProvider = context.watch<TriageProvider>();
    final queue = triageProvider.triageQueue;
    final urgent = _urgentCount(queue);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Médico'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar cola',
            onPressed: () => context.read<TriageProvider>().fetchTriageQueue(),
          ),
        ],
      ),
      body: SafeArea(
        child: triageProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : queue.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Sin pacientes en espera',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner de resumen
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: urgent > 0
                              ? const Color(0xFFFFF5F5)
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: urgent > 0
                                ? const Color(0xFFF44336)
                                : colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              urgent > 0
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                              color: urgent > 0
                                  ? const Color(0xFFF44336)
                                  : colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                urgent > 0
                                    ? '$urgent paciente${urgent > 1 ? 's' : ''} requiere${urgent > 1 ? 'n' : ''} atención URGENTE'
                                    : '${queue.length} paciente${queue.length > 1 ? 's' : ''} en cola — Sin urgencias',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: urgent > 0
                                      ? const Color(0xFFC62828)
                                      : colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lista de pacientes ordenada: urgentes primero
                      Expanded(
                        child: ListView.builder(
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final session = queue[index];
                            return PatientTriageCard(
                              session: session,
                              onAdmit: () => _admitAndCall(session.userId),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
