import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserRole _role = UserRole.unauthenticated;
  String? _familyId;
  Map<String, dynamic>? _familyData;
  bool _isLoading = false;
  String _error = '';

  UserRole get role => _role;
  String? get familyId => _familyId;
  Map<String, dynamic>? get familyData => _familyData;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  String get currentOperatorUid => _authService.currentUser?.id ?? '';

  Future<bool> loginAdmin(String email, String password) async {
    _setLoading(true);
    try {
      _role = await _authService.loginAdmin(email, password);
      _setLoading(false);
      return _role == UserRole.admin;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> loginOperator(String email, String password) async {
    _setLoading(true);
    try {
      _role = await _authService.loginOperator(email, password);
      _setLoading(false);
      return _role == UserRole.operator;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signupOperator(String email, String password, String name) async {
    _setLoading(true);
    try {
      final response = await _authService.signupOperator(email, password, name);
      if (response.user != null) {
        _role = UserRole.operator;
        _setLoading(false);
        return true;
      }
      _setError('Signup failed');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> loginHOF(String mobile, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.loginHOF(mobile, password);
      if (result != null) {
        _role = result['role'];
        _familyId = result['familyId']?.toString();
        _familyData = result['familyData'];
        _setLoading(false);
        return true;
      }
      _setError('Invalid credentials');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _role = UserRole.unauthenticated;
    _familyId = null;
    _familyData = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = '';
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _isLoading = false;
    notifyListeners();
  }
}
