import 'package:flutter/material.dart';
import '../../data/services/agora_service.dart';

/// Widget indicador de señal tipo "barras de celular" (HU 8).
/// Muestra la calidad de conexión de un participante con color semafórico.
class SignalIndicator extends StatelessWidget {
  final ConnectionQuality quality;
  final String? label;

  const SignalIndicator({
    super.key,
    required this.quality,
    this.label,
  });

  Color get _color {
    switch (quality) {
      case ConnectionQuality.excellent:
        return const Color(0xFF4CAF50); // Verde
      case ConnectionQuality.good:
        return const Color(0xFFFFC107); // Amarillo
      case ConnectionQuality.poor:
        return const Color(0xFFF44336); // Rojo
      case ConnectionQuality.disconnected:
        return const Color(0xFFF44336); // Rojo
    }
  }

  IconData get _icon {
    switch (quality) {
      case ConnectionQuality.excellent:
        return Icons.signal_cellular_4_bar;
      case ConnectionQuality.good:
        return Icons.signal_cellular_alt_2_bar;
      case ConnectionQuality.poor:
        return Icons.signal_cellular_alt_1_bar;
      case ConnectionQuality.disconnected:
        return Icons.signal_cellular_off;
    }
  }

  String get _defaultLabel {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Excelente';
      case ConnectionQuality.good:
        return 'Buena';
      case ConnectionQuality.poor:
        return 'Mala';
      case ConnectionQuality.disconnected:
        return 'Sin señal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 4),
          Text(
            label ?? _defaultLabel,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
