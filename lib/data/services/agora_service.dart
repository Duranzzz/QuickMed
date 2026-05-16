import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

/// Niveles de calidad de conexión simplificados para la UI.
enum ConnectionQuality { excellent, good, poor, disconnected }

/// Servicio que encapsula toda la lógica de Agora RTC.
/// Gestiona el ciclo de vida del engine, unión/salida de canales
/// y reporta la calidad de red para las HU 7 y 8.
class AgoraService extends ChangeNotifier {
  static const String _appId = '989407f7b4ca4bf0b5fd59f9431dd8a9';
  static const String defaultChannel = 'DemoQuickMed';

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  bool _localVideoEnabled = true;
  bool get localVideoEnabled => _localVideoEnabled;

  bool _localAudioEnabled = true;
  bool get localAudioEnabled => _localAudioEnabled;

  ConnectionQuality _connectionQuality = ConnectionQuality.excellent;
  ConnectionQuality get connectionQuality => _connectionQuality;

  /// Calidad de conexión del usuario remoto (HU 8: el médico ve la señal del paciente).
  ConnectionQuality _remoteConnectionQuality = ConnectionQuality.excellent;
  ConnectionQuality get remoteConnectionQuality => _remoteConnectionQuality;

  bool _isJoined = false;
  bool get isJoined => _isJoined;

  // --- Demo: forzar degradación manualmente ---
  bool _demoForcePoor = false;
  bool get demoForcePoor => _demoForcePoor;

  /// Inicializa el RtcEngine de Agora.
  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Habilitar video por defecto
    await _engine!.enableVideo();
    await _engine!.startPreview();

    // Registrar callbacks
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint('[Agora] Unido al canal: ${connection.channelId}');
        _isJoined = true;
        notifyListeners();
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint('[Agora] Usuario remoto unido: $remoteUid');
        _remoteUid = remoteUid;
        notifyListeners();
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint('[Agora] Usuario remoto salió: $remoteUid');
        _remoteUid = null;
        notifyListeners();
      },
      onNetworkQuality: (RtcConnection connection, int remoteUid, QualityType txQuality, QualityType rxQuality) {
        // Si el demo forzó mala señal, no actualizar con datos reales
        if (_demoForcePoor) return;

        if (remoteUid == 0) {
          // Calidad LOCAL (mi propia conexión)
          final quality = _mapQuality(txQuality);
          if (quality != _connectionQuality) {
            _connectionQuality = quality;
            _handleDegradation();
            notifyListeners();
          }
        } else {
          // Calidad REMOTA (HU 8: la señal del paciente vista por el médico)
          final quality = _mapQuality(rxQuality);
          if (quality != _remoteConnectionQuality) {
            _remoteConnectionQuality = quality;
            notifyListeners();
          }
        }
      },
    ));
  }

  /// Une al usuario al canal de la demo.
  Future<void> joinChannel({String channel = defaultChannel, int uid = 0}) async {
    if (_engine == null) return;
    await _engine!.joinChannel(
      token: '', // Sin token para testing (No certificate mode)
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  /// Sale del canal y limpia el estado.
  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
    _remoteUid = null;
    _isJoined = false;
    _demoForcePoor = false;
    _connectionQuality = ConnectionQuality.excellent;
    _remoteConnectionQuality = ConnectionQuality.excellent;
    _localVideoEnabled = true;
    _localAudioEnabled = true;
    notifyListeners();
  }

  /// Alterna cámara on/off.
  Future<void> toggleVideo() async {
    _localVideoEnabled = !_localVideoEnabled;
    await _engine?.muteLocalVideoStream(!_localVideoEnabled);
    notifyListeners();
  }

  /// Alterna micrófono on/off.
  Future<void> toggleAudio() async {
    _localAudioEnabled = !_localAudioEnabled;
    await _engine?.muteLocalAudioStream(!_localAudioEnabled);
    notifyListeners();
  }

  // ===== DEMO: Degradación forzada (Botón Secreto) =====

  /// Fuerza "mala conexión" para la demo (HU 7 + HU 8).
  void demoForceDegrade() {
    _demoForcePoor = true;
    _connectionQuality = ConnectionQuality.poor;
    _remoteConnectionQuality = ConnectionQuality.poor;
    _handleDegradation();
    notifyListeners();
  }

  /// Restaura la conexión en la demo.
  void demoRestoreConnection() {
    _demoForcePoor = false;
    _connectionQuality = ConnectionQuality.excellent;
    _remoteConnectionQuality = ConnectionQuality.excellent;
    // Re-habilitar video
    _localVideoEnabled = true;
    _engine?.muteLocalVideoStream(false);
    notifyListeners();
  }

  // ===== Privados =====

  /// Mapea la calidad de Agora a nuestro enum simplificado.
  ConnectionQuality _mapQuality(QualityType quality) {
    switch (quality) {
      case QualityType.qualityExcellent:
      case QualityType.qualityGood:
        return ConnectionQuality.excellent;
      case QualityType.qualityPoor:
        return ConnectionQuality.good;
      case QualityType.qualityBad:
      case QualityType.qualityVbad:
        return ConnectionQuality.poor;
      case QualityType.qualityDown:
        return ConnectionQuality.disconnected;
      default:
        return ConnectionQuality.good;
    }
  }

  /// Apaga la cámara automáticamente si la conexión es mala (HU 7).
  void _handleDegradation() {
    if (_connectionQuality == ConnectionQuality.poor ||
        _connectionQuality == ConnectionQuality.disconnected) {
      // Apagar cámara para priorizar audio
      _localVideoEnabled = false;
      _engine?.muteLocalVideoStream(true);
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}
