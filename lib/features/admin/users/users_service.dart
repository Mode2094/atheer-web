import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/shared/models/recommendation_model.dart';
import 'package:perfume/shared/models/user_model.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserWithRecommendations(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {'user': null, 'recommendations': <RecommendationModel>[]};
      }

      final user = UserModel.fromJson({...userDoc.data()!, 'id': userDoc.id});

      final recSnapshot = await _firestore
          .collection(AppConstants.recommendationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final recommendations = recSnapshot.docs
          .map(
            (doc) => RecommendationModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();

      return {
        'user': user,
        'recommendations': recommendations,
      };
    } catch (e) {
      debugPrint('Error getting user details: $e');
      return {'user': null, 'recommendations': <RecommendationModel>[]};
    }
  }
}
