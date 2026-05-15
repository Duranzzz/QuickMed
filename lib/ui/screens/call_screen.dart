import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videoconsulta (Próximamente)')),
      body: const Center(
        child: Text(
          'Simulación de Sala de Llamada\n(HU 7 y HU 8 en construcción)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
