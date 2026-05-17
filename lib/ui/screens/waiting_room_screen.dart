import 'package:flutter/material.dart';
import '../../data/services/waiting_room_service.dart';
import 'patient_call_setup_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  late final WaitingRoomService _waitingService;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _waitingService = WaitingRoomService();
    _waitingService.addListener(_onWaitingUpdate);
    _waitingService.startWaiting(initialPosition: 3);

    // Animación de pulso para el indicador de espera
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _onWaitingUpdate() {
    if (_waitingService.isReady && mounted) {
      // ¡Es el turno! Navegar al botón verde.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PatientCallSetupScreen()),
      );
    }
  }

  @override
  void dispose() {
    _waitingService.removeListener(_onWaitingUpdate);
    _waitingService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Sala de Espera'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _waitingService,
          builder: (context, _) {
            final position = _waitingService.position;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícono animado de espera
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.08),
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    'Estás en la sala de espera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Un médico te atenderá pronto.\nTu turno avanza automáticamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Número grande de posición
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Es usted el paciente número',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            '$position',
                            key: ValueKey<int>(position),
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'en la fila',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Indicador de progreso
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 24),

                  // Botón demo: saltar espera
                  OutlinedButton.icon(
                    onPressed: () => _waitingService.demoSkipToReady(),
                    icon: const Icon(Icons.science, size: 18),
                    label: const Text('Demo: saltar espera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
