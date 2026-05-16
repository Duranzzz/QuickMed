import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../../data/services/agora_service.dart';
import '../widgets/demo_control_panel.dart';
import '../widgets/signal_indicator.dart';

class CallScreen extends StatefulWidget {
  final bool isDoctor;

  const CallScreen({super.key, this.isDoctor = false});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = AgoraService();
    _initCall();
  }

  Future<void> _initCall() async {
    await _agoraService.initialize();
    await _agoraService.joinChannel();
  }

  Future<void> _endCall() async {
    await _agoraService.leaveChannel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: _agoraService,
        builder: (context, _) {
          return Stack(
            children: [
              // --- Video remoto (pantalla completa) ---
              _buildRemoteVideo(),

              // --- Video local (esquina superior derecha) ---
              Positioned(
                top: 48,
                right: 16,
                child: _buildLocalVideo(),
              ),

              // --- Indicador de señal del otro participante (HU 8) ---
              Positioned(
                top: 48,
                left: 16,
                child: SignalIndicator(
                  quality: _agoraService.remoteConnectionQuality,
                  label: widget.isDoctor ? 'Paciente' : 'Doctor',
                ),
              ),

              // --- Indicador de señal propia (referencia) ---
              Positioned(
                top: 48,
                left: 130,
                child: SignalIndicator(
                  quality: _agoraService.connectionQuality,
                  label: 'Tú',
                ),
              ),

              // --- Banner de degradación (HU 7) ---
              if (_agoraService.connectionQuality == ConnectionQuality.poor ||
                  _agoraService.connectionQuality == ConnectionQuality.disconnected)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: _buildDegradationBanner(),
                ),

              // --- Controles de llamada (abajo) ---
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildCallControls(),
              ),

              // --- Botón secreto de demo (esquina inferior izquierda) ---
              Positioned(
                bottom: 120,
                left: 16,
                child: DemoControlPanel(agoraService: _agoraService),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Video del otro participante ---
  Widget _buildRemoteVideo() {
    if (_agoraService.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _agoraService.engine!,
          canvas: VideoCanvas(uid: _agoraService.remoteUid!),
          connection: const RtcConnection(channelId: AgoraService.defaultChannel),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            _agoraService.isJoined
                ? 'Esperando al otro participante...'
                : 'Conectando...',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // --- Tu propia cámara (mini preview) ---
  Widget _buildLocalVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 120,
        height: 160,
        child: _agoraService.localVideoEnabled && _agoraService.engine != null
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _agoraService.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : Container(
                color: Colors.grey.shade800,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off, color: Colors.white54, size: 32),
                      SizedBox(height: 4),
                      Text('Cámara off', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }



  // --- Banner "Modo solo audio" (HU 7) ---
  Widget _buildDegradationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent),
      ),
      child: const Row(
        children: [
          Icon(Icons.signal_wifi_off, color: Colors.white, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo solo audio activado por mala conexión',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- Botones de control de llamada ---
  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Micrófono
        _CallControlButton(
          icon: _agoraService.localAudioEnabled ? Icons.mic : Icons.mic_off,
          label: _agoraService.localAudioEnabled ? 'Micro' : 'Silencio',
          color: _agoraService.localAudioEnabled ? Colors.white : Colors.red,
          onTap: () => _agoraService.toggleAudio(),
        ),

        // Colgar
        _CallControlButton(
          icon: Icons.call_end,
          label: 'Colgar',
          color: Colors.red,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
          onTap: _endCall,
        ),

        // Cámara
        _CallControlButton(
          icon: _agoraService.localVideoEnabled ? Icons.videocam : Icons.videocam_off,
          label: _agoraService.localVideoEnabled ? 'Cámara' : 'Cámara off',
          color: _agoraService.localVideoEnabled ? Colors.white : Colors.red,
          onTap: () => _agoraService.toggleVideo(),
        ),
      ],
    );
  }
}

/// Botón circular de control de llamada.
class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.2),
            child: Icon(icon, color: iconColor ?? color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
