import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class OtpSession {
  final String code;
  final DateTime expiresAt;
  int failedAttempts;
  DateTime? blockedUntil;

  OtpSession({
    required this.code,
    required this.expiresAt,
    this.failedAttempts = 0,
    this.blockedUntil,
  });
}

class AuthMockRepository {
  // Base de datos simulada en memoria
  final List<User> _mockUsers = [
    User(id: '1', phone: '70000000'),
    User(id: '2', phone: '71111111'),
  ];

  final Map<String, OtpSession> _otpSessions = {};
  final _uuid = const Uuid();

  /// Verifica si el número existe. Si no, crea un nuevo usuario.
  Future<User> loginOrCreate(String phone) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final existingUser = _mockUsers.firstWhere((user) => user.phone == phone);
      return existingUser;
    } catch (e) {
      final newUser = User(
        id: _uuid.v4(),
        phone: phone,
      );
      _mockUsers.add(newUser);
      return newUser;
    }
  }

  /// Simula el envío de un SMS con el código OTP (hardcodeado a '1234')
  Future<void> sendOTP(String phone) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final existingSession = _otpSessions[phone];
    if (existingSession?.blockedUntil != null) {
      if (DateTime.now().isBefore(existingSession!.blockedUntil!)) {
        throw Exception('Cuenta bloqueada. Intenta en 15 minutos.');
      }
    }

    // Simulamos que el SMS siempre es 1234 para poder probar
    _otpSessions[phone] = OtpSession(
      code: '1234',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  /// Verifica el código OTP aplicando expiración y bloqueo por intentos fallidos
  Future<bool> verifyOTP(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final session = _otpSessions[phone];
    if (session == null) throw Exception('No hay un código OTP activo.');

    if (session.blockedUntil != null && DateTime.now().isBefore(session.blockedUntil!)) {
      throw Exception('Cuenta bloqueada. Intenta en 15 minutos.');
    }

    if (DateTime.now().isAfter(session.expiresAt)) {
      throw Exception('El código ha expirado.');
    }

    if (session.code == code) {
      // Login exitoso, se limpia la sesión OTP
      _otpSessions.remove(phone);
      return true;
    } else {
      session.failedAttempts++;
      if (session.failedAttempts >= 3) {
        session.blockedUntil = DateTime.now().add(const Duration(minutes: 15));
        throw Exception('Código incorrecto. Has sido bloqueado por 15 minutos.');
      }
      throw Exception('Código incorrecto. Intento ${session.failedAttempts} de 3.');
    }
  }
}
