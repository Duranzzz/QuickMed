import 'package:flutter/material.dart';
import '../../data/models/prescription_model.dart';

/// Pantalla resumen de la receta emitida.
/// En HU 12 se le agrega el QR visual.
class PrescriptionSummaryScreen extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionSummaryScreen({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receta Emitida'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono de éxito
              const Icon(Icons.check_circle, size: 72, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              const Text(
                '¡Receta emitida exitosamente!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Paciente: ${prescription.patientId}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Placeholder para QR (HU 12)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('QR se generará en HU 12',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Lista de medicamentos
              const Text(
                'Medicamentos recetados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...prescription.medications.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.medication, color: Color(0xFF1976D2)),
                      ),
                      title: Text(m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${m.dose} · ${m.frequency} · ${m.duration}'),
                    ),
                  )),
              const SizedBox(height: 24),

              // Botón volver al panel
              ElevatedButton.icon(
                onPressed: () {
                  // Volver al dashboard del doctor
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Volver al Panel'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
