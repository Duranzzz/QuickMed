import 'dart:async';
import 'package:flutter/foundation.dart';

/// Servicio mock que simula la cola de espera del paciente.
/// En producción esto sería un WebSocket o polling contra el backend.
class WaitingRoomService extends ChangeNotifier {
  int _position = 0;
  int get position => _position;

  bool _isReady = false;
  bool get isReady => _isReady;

  Timer? _timer;

  /// Inicia la simulación de la cola.
  /// [initialPosition] es el número de turno asignado al paciente.
  void startWaiting({int initialPosition = 3}) {
    _position = initialPosition;
    _isReady = false;
    notifyListeners();

    // Simular que la cola avanza cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_position > 1) {
        _position--;
        debugPrint('[WaitingRoom] Posición actualizada: $_position');
        notifyListeners();
      } else {
        // Es el turno del paciente
        _isReady = true;
        _timer?.cancel();
        debugPrint('[WaitingRoom] ¡Es tu turno!');
        notifyListeners();
      }
    });
  }

  /// Fuerza que sea el turno del paciente (para demo).
  void demoSkipToReady() {
    _position = 1;
    _isReady = true;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
