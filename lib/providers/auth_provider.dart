import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      _user = User(name: name, email: email, phone: phone);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _user = User(name: 'Usuário Mockado', email: email, phone: '(11) 99999-9999');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recoverPassword({String? email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.recoverPassword(email: email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}