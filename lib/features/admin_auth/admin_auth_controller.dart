import 'package:flutter/material.dart';
import 'package:perfume/features/admin_auth/admin_auth_service.dart';

class AdminAuthController extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();

  bool _isLoading = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _currentSession;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get currentSession => _currentSession;
  String? get error => _error;
  bool get isLoggedIn => _currentSession != null;

  AdminAuthController() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    _currentSession = await _authService.getCurrentSession();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshSession() async {
    await _checkSession();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;

    final result = await _authService.login(username, password);

    if (result['success'] == true) {
      final session = result['session'];
      if (session is Map<String, dynamic>) {
        _currentSession = session;
      } else if (session is Map) {
        _currentSession = session.map((k, v) => MapEntry(k.toString(), v));
      } else {
        _currentSession = null;
      }
      _setLoading(false);
      return true;
    }

    _error = result['message']?.toString() ?? 'فشل تسجيل الدخول';
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentSession = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
