import 'package:flutter/material.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/store_auth/store_auth_service.dart';

class StoreAuthController extends ChangeNotifier {
  final StoreAuthService _authService = StoreAuthService();

  bool _isLoading = false;
  Map<String, dynamic>? _currentSession;
  String? _error;
  String? _storeId;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentSession => _currentSession;
  String? get error => _error;
  String? get storeId => _storeId ?? _currentSession?['storeId']?.toString();
  bool get isLoggedIn => _currentSession != null;
  String? get storeName => _currentSession?['storeName']?.toString();

  StoreAuthController() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    _currentSession = await _authService.getCurrentSession();
    _storeId = _currentSession?['storeId']?.toString();
    notifyListeners();
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
        _currentSession = {
          'storeId': result['storeId']?.toString() ?? '',
          'username': username,
        };
      }
      _storeId = result['storeId']?.toString();
      _setLoading(false);
      return true;
    }

    final messageKey = result['messageKey']?.toString();
    _error = messageKey != null
        ? StringHelper.tr(messageKey)
        : (result['message']?.toString() ??
            StringHelper.tr('store_login_failed'));
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentSession = null;
    _storeId = null;
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
