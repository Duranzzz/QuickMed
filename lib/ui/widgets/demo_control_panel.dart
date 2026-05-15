import 'package:flutter/material.dart';
import '../../data/services/agora_service.dart';

/// Panel flotante secreto para la demo.
/// Permite forzar la degradación de video manualmente.
class DemoControlPanel extends StatelessWidget {
  final AgoraService agoraService;

  const DemoControlPanel({super.key, required this.agoraService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: agoraService,
      builder: (context, _) {
        final isPoor = agoraService.demoForcePoor;

        return FloatingActionButton.small(
          heroTag: 'demo_panel',
          backgroundColor: isPoor ? Colors.red : Colors.grey.shade700,
          onPressed: () => _showDemoSheet(context, isPoor),
          child: const Icon(Icons.science, size: 20, color: Colors.white),
        );
      },
    );
  }

  void _showDemoSheet(BuildContext context, bool isPoor) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎛️ Panel de Demo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Estado actual: ${isPoor ? "🔴 Señal MALA (forzada)" : "🟢 Señal BUENA"}',
                style: TextStyle(
                  color: isPoor ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (!isPoor)
                ElevatedButton.icon(
                  onPressed: () {
                    agoraService.demoForceDegrade();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.signal_wifi_off),
                  label: const Text('Simular Caída de Señal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    agoraService.demoRestoreConnection();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.wifi),
                  label: const Text('Restaurar Señal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
