import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/models/store_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreAuthService {
  static const String _sessionKey = 'store_user_session';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.storeUsersCollection)
          .where('username', isEqualTo: username)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'messageKey': 'store_login_invalid_username',
        };
      }

      final doc = querySnapshot.docs.first;
      final user = StoreUserModel.fromJson({...doc.data(), 'id': doc.id});

      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        return {
          'success': false,
          'messageKey': 'store_login_invalid_password',
        };
      }

      await doc.reference.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      final session = {
        'id': user.id,
        'username': user.username,
        'storeId': user.storeId,
        'storeName': user.storeName,
        'role': user.role,
      };

      await _saveSession(session);

      return {
        'success': true,
        'session': session,
        'storeId': user.storeId,
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'messageKey': 'store_login_failed'};
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

  Future<bool> createStoreUser({
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  }) async {
    try {
      final existing = await _firestore
          .collection(AppConstants.storeUsersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return false;
      }

      await _firestore.collection(AppConstants.storeUsersCollection).add({
        'username': username,
        'passwordHash': _hashPassword(password),
        'storeId': storeId,
        'storeName': storeName,
        'role': 'store',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });

      return true;
    } catch (e) {
      debugPrint('Create store user error: $e');
      return false;
    }
  }

  Future<bool> changePassword(String userId, String newPassword) async {
    try {
      await _firestore.collection(AppConstants.storeUsersCollection).doc(userId).update({
        'passwordHash': _hashPassword(newPassword),
      });
      return true;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }
}
