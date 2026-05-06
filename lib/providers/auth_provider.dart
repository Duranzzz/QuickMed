import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_mock_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthMockRepository _repository = AuthMockRepository();
  
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> loginWithPhone(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _repository.loginOrCreate(phone);
      // Tras hacer el login/create, disparamos el envío del OTP
      await _repository.sendOTP(phone);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyOTP(String code) async {
    if (_currentUser == null) return 'No hay usuario autenticado';
    
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.verifyOTP(_currentUser!.phone, code);
      _isLoading = false;
      notifyListeners();
      return null; // Null significa éxito, no hay mensaje de error
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', ''); // Devuelve el mensaje de error del mock
    }
  }
}
