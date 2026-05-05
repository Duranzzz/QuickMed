import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthMockRepository {
  // Base de datos simulada en memoria
  final List<User> _mockUsers = [
    User(id: '1', phone: '70000000'),
    User(id: '2', phone: '71111111'),
  ];

  final _uuid = const Uuid();

  /// Verifica si el número existe. Si no, crea un nuevo usuario.
  /// Simula el tiempo de red (1.5 segundos).
  Future<User> loginOrCreate(String phone) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // Buscar usuario existente
      final existingUser = _mockUsers.firstWhere((user) => user.phone == phone);
      return existingUser;
    } catch (e) {
      // Si no se encuentra, lo "creamos" y lo agregamos a la lista mock
      final newUser = User(
        id: _uuid.v4(),
        phone: phone,
      );
      _mockUsers.add(newUser);
      return newUser;
    }
  }
}
