import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/services/waiting_room_service.dart';

void main() {
  group('WaitingRoomService - Cola de espera (HU 9)', () {
    late WaitingRoomService service;

    setUp(() {
      service = WaitingRoomService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Posición inicial es 0 antes de startWaiting', () {
      expect(service.position, 0);
      expect(service.isReady, isFalse);
    });

    test('startWaiting asigna la posición inicial correcta', () {
      service.startWaiting(initialPosition: 5);
      expect(service.position, 5);
      expect(service.isReady, isFalse);
    });

    test('startWaiting con valor por defecto asigna posición 3', () {
      service.startWaiting();
      expect(service.position, 3);
    });

    test('demoSkipToReady pone posición en 1 y activa isReady', () {
      service.startWaiting(initialPosition: 5);
      service.demoSkipToReady();
      expect(service.position, 1);
      expect(service.isReady, isTrue);
    });

    test('isReady es false mientras la posición es mayor a 1', () {
      service.startWaiting(initialPosition: 3);
      expect(service.isReady, isFalse);
    });

    test('Notifica a los listeners al iniciar la espera', () {
      int notifyCount = 0;
      service.addListener(() => notifyCount++);
      service.startWaiting(initialPosition: 2);
      expect(notifyCount, 1);
    });

    test('Notifica a los listeners al usar demoSkipToReady', () {
      service.startWaiting(initialPosition: 3);
      int notifyCount = 0;
      service.addListener(() => notifyCount++);
      service.demoSkipToReady();
      expect(notifyCount, 1);
    });
  });
}
