import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'call_screen.dart';

class PatientCallSetupScreen extends StatefulWidget {
  const PatientCallSetupScreen({super.key});

  @override
  State<PatientCallSetupScreen> createState() => _PatientCallSetupScreenState();
}

class _PatientCallSetupScreenState extends State<PatientCallSetupScreen> {
  bool _isLoading = false;

  Future<void> _requestPermissionsAndEnter() async {
    setState(() => _isLoading = true);

    // Solicitar permisos de cámara y micrófono simultáneamente
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    setState(() => _isLoading = false);

    if (cameraGranted && micGranted) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CallScreen()),
        );
      }
    } else {
      if (mounted) {
        // HU 6: Manejar el caso donde el usuario deniega los permisos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitamos acceso a tu cámara y micrófono para la videoconsulta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sala de Consulta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.video_camera_front_rounded,
                size: 100,
                color: Color(0xFF4CAF50), // Verde
              ),
              const SizedBox(height: 32),
              const Text(
                'El médico está listo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Presiona el botón de abajo para entrar a la videoconsulta. Se te pedirá permiso para usar la cámara.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 48),
              
              // El Gran Botón Verde (HU 6)
              ElevatedButton(
                onPressed: _isLoading ? null : _requestPermissionsAndEnter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, size: 32),
                          SizedBox(width: 12),
                          Text(
                            'ENTRAR A CONSULTA',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
