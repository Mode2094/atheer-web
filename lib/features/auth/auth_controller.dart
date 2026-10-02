import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfume/features/auth/auth_service.dart';
import 'package:perfume/shared/models/user_model.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State
  bool _isLoading = false;
  User? _user;
  UserModel? _userProfile;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get hasCompleteProfile =>
      _userProfile != null &&
      _userProfile!.name.isNotEmpty &&
      _userProfile!.gender.isNotEmpty;

  // تسجيل الدخول برقم الهاتف
  Future<bool> signInWithPhone(String phoneNumber) async {
    _setLoading(true);
    _error = null;

    try {
      // 1. تسجيل الدخول
      final user = await _authService.signInWithPhone(phoneNumber);
      if (user == null) throw Exception('Failed to sign in');
      _user = user;

      // 2. التأكد من وجود ملف المستخدم
      await _authService.ensureUserProfile(phoneNumber);

      // 3. تحميل ملف المستخدم
      await loadUserProfile();

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // تحميل ملف المستخدم
  Future<void> loadUserProfile() async {
    _userProfile = await _authService.getUserProfile();
    notifyListeners();
  }

  // تحديث ملف المستخدم بعد الأسئلة
  Future<void> updateProfile({
    required String name,
    required String gender,
    String? phone,
    String? country,
    required Map<String, dynamic> personalityProfile,
  }) async {
    _setLoading(true);
    await _authService.updateUserProfile(
      name: name,
      gender: gender,
      phone: phone,
      country: country,
      personalityProfile: personalityProfile,
    );
    await loadUserProfile();
    _setLoading(false);
  }

  // إضافة توصية للسجل
  Future<void> addToHistory(String perfumeId) async {
    await _authService.addRecommendationToHistory(perfumeId);
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  // Compatibility methods (OTP disabled)
  Future<bool> sendOTP(String phoneNumber) async {
    return signInWithPhone(phoneNumber);
  }

  Future<bool> verifyOTP(String smsCode) async {
    _error = 'OTP is disabled in current flow';
    notifyListeners();
    return false;
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
