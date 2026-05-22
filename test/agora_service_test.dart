import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/services/agora_service.dart';

void main() {
  group('AgoraService - Lógica de Degradación', () {
    late AgoraService service;

    setUp(() {
      service = AgoraService();
    });

    test('Estado inicial es ConnectionQuality.excellent', () {
      expect(service.connectionQuality, ConnectionQuality.excellent);
    });

    test('Video y audio están habilitados por defecto', () {
      expect(service.localVideoEnabled, isTrue);
      expect(service.localAudioEnabled, isTrue);
    });

    test('demoForceDegrade cambia la calidad a poor', () {
      service.demoForceDegrade();
      expect(service.connectionQuality, ConnectionQuality.poor);
    });

    test('demoForceDegrade desactiva el video local (HU 7)', () {
      service.demoForceDegrade();
      expect(service.localVideoEnabled, isFalse);
    });

    test('demoForceDegrade mantiene el audio activo (priorizar voz)', () {
      service.demoForceDegrade();
      expect(service.localAudioEnabled, isTrue);
    });

    test('demoRestoreConnection restaura calidad a excellent', () {
      service.demoForceDegrade();
      service.demoRestoreConnection();
      expect(service.connectionQuality, ConnectionQuality.excellent);
    });

    test('demoRestoreConnection reactiva el video local', () {
      service.demoForceDegrade();
      service.demoRestoreConnection();
      expect(service.localVideoEnabled, isTrue);
    });

    test('El flag demoForcePoor se activa y desactiva correctamente', () {
      expect(service.demoForcePoor, isFalse);
      service.demoForceDegrade();
      expect(service.demoForcePoor, isTrue);
      service.demoRestoreConnection();
      expect(service.demoForcePoor, isFalse);
    });
  });

  group('AgoraService - Monitoreo Remoto (HU 8)', () {
    late AgoraService service;

    setUp(() {
      service = AgoraService();
    });

    test('Calidad remota inicia en excellent', () {
      expect(service.remoteConnectionQuality, ConnectionQuality.excellent);
    });

    test('demoForceDegrade NO cambia la calidad remota localmente (se envía al otro dispositivo)', () {
      service.demoForceDegrade();
      // La calidad remota local no cambia: el mensaje va al otro dispositivo vía data stream
      expect(service.remoteConnectionQuality, ConnectionQuality.excellent);
    });

    test('demoRestoreConnection restaura la calidad remota a excellent', () {
      service.demoForceDegrade();
      service.demoRestoreConnection();
      expect(service.remoteConnectionQuality, ConnectionQuality.excellent);
    });

    test('Calidad local y remota son independientes por defecto', () {
      // Ambas inician en excellent
      expect(service.connectionQuality, ConnectionQuality.excellent);
      expect(service.remoteConnectionQuality, ConnectionQuality.excellent);
    });

    test('demoForceDegrade cambia solo la calidad local, no la remota', () {
      service.demoForceDegrade();
      expect(service.connectionQuality, ConnectionQuality.poor);
      // La remota se mantiene: el otro dispositivo recibe el mensaje por stream
      expect(service.remoteConnectionQuality, ConnectionQuality.excellent);
    });
  });
}
