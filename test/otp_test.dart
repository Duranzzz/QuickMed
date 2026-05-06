import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/repositories/auth_mock_repository.dart';

void main() {
  late AuthMockRepository repository;
  const testPhone = '70000000';

  setUp(() async {
    repository = AuthMockRepository();
    await repository.loginOrCreate(testPhone);
    await repository.sendOTP(testPhone);
  });

  group('OTP - Verificación exitosa', () {
    test('Devuelve true con el código correcto (1234)', () async {
      final result = await repository.verifyOTP(testPhone, '1234');
      expect(result, isTrue);
    });
  });

  group('OTP - Intentos fallidos y bloqueo', () {
    test('Lanza excepción con código incorrecto (intento 1 de 3)', () async {
      String? errorMsg;
      try {
        await repository.verifyOTP(testPhone, '0000');
      } catch (e) {
        errorMsg = e.toString();
      }
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('Intento 1 de 3'));
    });

    test('Bloquea la cuenta tras 3 intentos fallidos consecutivos', () async {
      String? lastError;
      for (int i = 0; i < 3; i++) {
        try {
          await repository.verifyOTP(testPhone, '0000');
        } catch (e) {
          lastError = e.toString();
        }
      }
      // El tercer error debe ser el de bloqueo
      expect(lastError, isNotNull);
      expect(lastError, contains('bloqueado por 15 minutos'));
    });

    test('Tras bloqueo, incluso el código correcto es rechazado', () async {
      // Agotar los 3 intentos para activar el bloqueo
      for (int i = 0; i < 3; i++) {
        try {
          await repository.verifyOTP(testPhone, '0000');
        } catch (_) {}
      }
      // Ahora el código correcto también es rechazado
      String? errorMsg;
      try {
        await repository.verifyOTP(testPhone, '1234');
      } catch (e) {
        errorMsg = e.toString();
      }
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('bloqueada'));
    });
  });

  group('OTP - Sin sesión activa', () {
    test('Lanza excepción si se verifica un número sin OTP enviado', () async {
      String? errorMsg;
      try {
        await repository.verifyOTP('69999999', '1234');
      } catch (e) {
        errorMsg = e.toString();
      }
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('No hay un código OTP activo'));
    });
  });
}
