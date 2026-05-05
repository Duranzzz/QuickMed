import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/data/repositories/auth_mock_repository.dart';

void main() {
  late AuthMockRepository authRepository;

  setUp(() {
    authRepository = AuthMockRepository();
  });

  group('AuthMockRepository Unit Tests', () {
    test('loginOrCreate should return existing user if phone is in database', () async {
      final user = await authRepository.loginOrCreate('70000000');
      expect(user.phone, '70000000');
      expect(user.id, '1');
    });

    test('loginOrCreate should create new user if phone is not in database', () async {
      const newPhone = '79999999';
      final user = await authRepository.loginOrCreate(newPhone);
      expect(user.phone, newPhone);
      expect(user.id, isNot('1'));
      expect(user.id, isNot('2'));
    });
  });
}
