import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final usersSnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      final storesSnapshot = await _firestore
          .collection(AppConstants.storesCollection)
          .where('active', isEqualTo: true)
          .get();

      final recommendationsSnapshot =
          await _firestore.collection(AppConstants.recommendationsCollection).get();

      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final newUsersThisMonth = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt == null) return false;
        return createdAt.toDate().isAfter(startOfMonth);
      }).length;

      return {
        'totalUsers': usersSnapshot.docs.length,
        'activeStores': storesSnapshot.docs.length,
        'totalRecommendations': recommendationsSnapshot.docs.length,
        'newUsersThisMonth': newUsersThisMonth,
        'avgRecommendationsPerUser': usersSnapshot.docs.isEmpty
            ? 0
            : recommendationsSnapshot.docs.length / usersSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting general stats: $e');
      return {
        'totalUsers': 0,
        'activeStores': 0,
        'totalRecommendations': 0,
        'newUsersThisMonth': 0,
        'avgRecommendationsPerUser': 0,
      };
    }
  }

  Future<Map<String, int>> getPerfumeFamilyDistribution() async {
    try {
      final distribution = <String, int>{};
      final recommendationsSnapshot =
          await _firestore.collection(AppConstants.recommendationsCollection).get();

      for (final doc in recommendationsSnapshot.docs) {
        final data = doc.data();
        final family =
            data['perfumeFamily'] as String? ?? StringHelper.tr('unknown');
        distribution[family] = (distribution[family] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      debugPrint('Error getting family distribution: $e');
      return {};
    }
  }

  Future<Map<String, double>> getPersonalityDistribution() async {
    try {
      final usersSnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      var opennessSum = 0.0;
      var extraversionSum = 0.0;
      var neuroticismSum = 0.0;
      var count = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final profile = data['personalityProfile'] as Map<String, dynamic>?;
        if (profile != null && profile.isNotEmpty) {
          opennessSum += (profile['openness'] as num? ?? 0.5).toDouble();
          extraversionSum += (profile['extraversion'] as num? ?? 0.5).toDouble();
          neuroticismSum += (profile['neuroticism'] as num? ?? 0.5).toDouble();
          count++;
        }
      }

      if (count == 0) {
        return {'openness': 0, 'extraversion': 0, 'neuroticism': 0};
      }

      return {
        'openness': opennessSum / count,
        'extraversion': extraversionSum / count,
        'neuroticism': neuroticismSum / count,
      };
    } catch (e) {
      debugPrint('Error getting personality distribution: $e');
      return {};
    }
  }

  Future<Map<String, double>> getSensoryPreferences() async {
    try {
      final usersSnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      var freshnessSum = 0.0;
      var sweetnessSum = 0.0;
      var warmthSum = 0.0;
      var intensitySum = 0.0;
      var count = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final profile = data['personalityProfile'] as Map<String, dynamic>?;
        if (profile != null && profile.isNotEmpty) {
          freshnessSum += (profile['freshnessPreference'] as num? ?? 0.5).toDouble();
          sweetnessSum += (profile['sweetnessPreference'] as num? ?? 0.5).toDouble();
          warmthSum += (profile['warmthPreference'] as num? ?? 0.5).toDouble();
          intensitySum += (profile['intensityPreference'] as num? ?? 0.5).toDouble();
          count++;
        }
      }

      if (count == 0) {
        return {'freshness': 0, 'sweetness': 0, 'warmth': 0, 'intensity': 0};
      }

      return {
        'freshness': freshnessSum / count,
        'sweetness': sweetnessSum / count,
        'warmth': warmthSum / count,
        'intensity': intensitySum / count,
      };
    } catch (e) {
      debugPrint('Error getting sensory preferences: $e');
      return {};
    }
  }

  // Optimized: 1 recommendations query + ceil(uniqueUserIds/10) user queries.
  Future<List<Map<String, dynamic>>> getRecentRecommendations({
    int limit = 20,
  }) async {
    try {
      final recommendationsSnapshot = await _firestore
          .collection(AppConstants.recommendationsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (recommendationsSnapshot.docs.isEmpty) {
        return [];
      }

      final userIds = recommendationsSnapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final usersData = await _fetchUsersBatch(userIds);

      final recommendations = recommendationsSnapshot.docs.map((doc) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        final userData = userId != null ? usersData[userId] : null;

        return {
          ...data,
          'id': doc.id,
          'userName': userData?['name'] ?? StringHelper.tr('unknown'),
          'date': (data['createdAt'] as Timestamp?)?.toDate(),
        };
      }).toList();

      return recommendations;
    } catch (e) {
      debugPrint('Error getting recent recommendations: $e');
      return [];
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchUsersBatch(
    List<String> userIds,
  ) async {
    final usersData = <String, Map<String, dynamic>>{};
    if (userIds.isEmpty) return usersData;

    const chunkSize = 10;
    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        usersData[doc.id] = doc.data();
      }
    }

    return usersData;
  }

  Future<String> exportUsersToCSV() async {
    try {
      final usersSnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      final buffer = StringBuffer();
      buffer.writeln(
        'id,phone,name,gender,openness,extraversion,neuroticism,freshness,sweetness,warmth,intensity,created_at,last_active,recommendations_count',
      );

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final profile = data['personalityProfile'] as Map<String, dynamic>?;
        final pastRecs = data['pastRecommendations'] as List? ?? [];

        final row = [
          doc.id,
          data['phone'] ?? '',
          data['name'] ?? '',
          data['gender'] ?? '',
          profile?['openness'] ?? '',
          profile?['extraversion'] ?? '',
          profile?['neuroticism'] ?? '',
          profile?['freshnessPreference'] ?? '',
          profile?['sweetnessPreference'] ?? '',
          profile?['warmthPreference'] ?? '',
          profile?['intensityPreference'] ?? '',
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? '',
          (data['lastActive'] as Timestamp?)?.toDate().toIso8601String() ?? '',
          pastRecs.length.toString(),
        ];

        buffer.writeln(row.map(_escapeCsvField).join(','));
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error exporting users: $e');
      return '';
    }
  }

  String _escapeCsvField(Object? value) {
    final text = (value ?? '').toString().replaceAll('"', '""');
    return '"$text"';
  }
}
