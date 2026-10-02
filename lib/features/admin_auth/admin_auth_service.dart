import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/models/admin_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String _sessionKey = 'admin_session';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.adminUsersCollection)
          .where('username', isEqualTo: username)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'اسم المستخدم غير صحيح'};
      }

      final doc = querySnapshot.docs.first;
      final admin = AdminUserModel.fromJson({...doc.data(), 'id': doc.id});

      final hashedPassword = _hashPassword(password);
      if (admin.passwordHash != hashedPassword) {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }

      await doc.reference.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      final session = {
        'id': admin.id,
        'username': admin.username,
        'name': admin.name,
        'role': admin.role,
      };

      await _saveSession(session);

      return {
        'success': true,
        'session': session,
      };
    } catch (e) {
      debugPrint('Admin login error: $e');
      return {'success': false, 'message': 'حدث خطأ في تسجيل الدخول'};
    }
  }

  Future<void> _saveSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, json.encode(session));
  }

  Future<Map<String, dynamic>?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStr = prefs.getString(_sessionKey);
    if (sessionStr == null) return null;

    try {
      final decoded = json.decode(sessionStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<bool> isLoggedIn() async {
    final session = await getCurrentSession();
    return session != null;
  }
}
