import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/services/firebase_service.dart';
import 'package:perfume/shared/models/user_model.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  // تسجيل الدخول الفوري برقم الهاتف (بدون OTP)
  Future<User?> signInWithPhone(String phoneNumber) async {
    try {
      // استخدام Anonymous Auth للتطوير الحالي
      final user = _firebaseService.auth.currentUser;
      if (user != null) return user;

      final userCredential = await _firebaseService.auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  // إنشاء أو تحديث ملف المستخدم في Firestore
  Future<void> ensureUserProfile(String phoneNumber) async {
    final user = _firebaseService.auth.currentUser;
    if (user == null) return;

    final userRef = _firebaseService.usersRef.doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'id': user.uid,
        'phone': phoneNumber,
        'country': '',
        'name': '',
        'gender': '',
        'personalityProfile': <String, dynamic>{},
        'pastRecommendations': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
      debugPrint('Created profile in ${AppConstants.usersCollection}');
    } else {
      await userRef.update({'lastActive': FieldValue.serverTimestamp()});
    }
  }

  // الحصول على ملف المستخدم
  Future<UserModel?> getUserProfile() async {
    final user = _firebaseService.auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firebaseService.usersRef.doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
    return null;
  }

  // تحديث ملف المستخدم بعد الإجابة على الأسئلة
  Future<void> updateUserProfile({
    required String name,
    required String gender,
    String? phone,
    String? country,
    required Map<String, dynamic> personalityProfile,
  }) async {
    final user = _firebaseService.auth.currentUser;
    if (user == null) return;

    try {
      final Map<String, dynamic> updateData = {
        'name': name,
        'gender': gender,
        'personalityProfile': personalityProfile,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (phone != null && phone.isNotEmpty) {
        updateData['phone'] = phone;
      }
      if (country != null && country.isNotEmpty) {
        updateData['country'] = country;
      }

      await _firebaseService.usersRef.doc(user.uid).update(updateData);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  // إضافة توصية إلى سجل المستخدم
  Future<void> addRecommendationToHistory(String perfumeId) async {
    final user = _firebaseService.auth.currentUser;
    if (user == null) return;

    try {
      await _firebaseService.usersRef.doc(user.uid).update({
        'pastRecommendations': FieldValue.arrayUnion([perfumeId]),
        'lastRecommendation': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding recommendation to history: $e');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  // التحقق من وجود مستخدم
  bool get isLoggedIn => _firebaseService.auth.currentUser != null;
}
