import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/prescription_model.dart';
import '../../data/repositories/prescription_mock_repository.dart';
import 'prescription_summary_screen.dart';

/// Repositorio global compartido (singleton simple para la demo).
final prescriptionRepository = PrescriptionMockRepository();

class PrescriptionScreen extends StatefulWidget {
  final String patientId;

  const PrescriptionScreen({super.key, required this.patientId});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_MedicationEntry> _medications = [_MedicationEntry()];
  bool _isSaving = false;

  void _addMedication() {
    setState(() => _medications.add(_MedicationEntry()));
  }

  void _removeMedication(int index) {
    if (_medications.length > 1) {
      setState(() => _medications.removeAt(index));
    }
  }

  Future<void> _emitPrescription() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    // Generar UUID v4 único para el hash QR (HU 12)
    final hash = const Uuid().v4();

    final prescription = Prescription(
      id: 'rx-$hash',
      qrHash: hash,
      patientId: widget.patientId,
      doctorId: 'doctor-demo',
      date: DateTime.now(),
      medications: _medications.map((e) => e.toModel()).toList(),
    );

    await prescriptionRepository.savePrescription(prescription);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PrescriptionSummaryScreen(prescription: prescription),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Receta'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Cabecera
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(Icons.medical_services,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paciente: ${widget.patientId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de medicamentos (scrollable)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _medications.length + 1, // +1 para el botón agregar
                itemBuilder: (context, index) {
                  if (index == _medications.length) {
                    // Botón agregar medicamento
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar medicamento'),
                      ),
                    );
                  }
                  return _MedicationFormCard(
                    entry: _medications[index],
                    index: index,
                    canRemove: _medications.length > 1,
                    onRemove: () => _removeMedication(index),
                  );
                },
              ),
            ),

            // Botón emitir
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _emitPrescription,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Emitir Receta',
                      style: const TextStyle(fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Entrada de medicamento (estado interno del formulario) =====

class _MedicationEntry {
  String name = '';
  String dose = '';
  String frequency = '';
  String duration = '';

  MedicationItem toModel() => MedicationItem(
        name: name,
        dose: dose,
        frequency: frequency,
        duration: duration,
      );
}

// ===== Tarjeta de formulario para un medicamento =====

class _MedicationFormCard extends StatelessWidget {
  final _MedicationEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MedicationFormCard({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del medicamento
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Medicamento ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove,
                    color: Colors.red.shade400,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Nombre
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento',
                hintText: 'ej. Amoxicilina',
                prefixIcon: Icon(Icons.medication, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
              onSaved: (v) => entry.name = v ?? '',
            ),
            const SizedBox(height: 10),

            // Dosis y frecuencia en fila
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Dosis',
                      hintText: 'ej. 500mg',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                    onSaved: (v) => entry.dose = v ?? '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia',
                      hintText: 'ej. Cada 8h',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                    onSaved: (v) => entry.frequency = v ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Duración
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Duración',
                hintText: 'ej. 7 días',
                prefixIcon: Icon(Icons.schedule, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
              onSaved: (v) => entry.duration = v ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
