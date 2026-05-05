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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
