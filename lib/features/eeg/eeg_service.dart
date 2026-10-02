import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/models/eeg_result_model.dart';

class EEGService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> saveEEGResult({
    required String userId,
    required String storeId,
    required String perfumeId,
    required String perfumeName,
    required Map<String, dynamic> eegData,
  }) async {
    try {
      final result = EEGResultModel(
        userId: userId,
        storeId: storeId,
        perfumeId: perfumeId,
        perfumeName: perfumeName,
        relaxation: (eegData['relaxation'] as num?)?.toDouble() ?? 0.0,
        attention: (eegData['attention'] as num?)?.toDouble() ?? 0.0,
        engagement: (eegData['engagement'] as num?)?.toDouble() ?? 0.0,
        excitement: (eegData['excitement'] as num?)?.toDouble() ?? 0.0,
        stress: (eegData['stress'] as num?)?.toDouble() ?? 0.0,
        interest: (eegData['interest'] as num?)?.toDouble() ?? 0.0,
        rawData: eegData,
      );

      await _firestore
          .collection(AppConstants.eegResultsCollection)
          .add(result.toFirestoreJson());

      debugPrint('EEG result saved for perfume: $perfumeName');
      return true;
    } catch (e) {
      debugPrint('Error saving EEG result: $e');
      return false;
    }
  }

  Future<List<EEGResultModel>> getEEGResultsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eegResultsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return EEGResultModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting EEG results for user: $e');
      return [];
    }
  }

  Future<List<EEGResultModel>> getEEGResultsForPerfume({
    required String storeId,
    required String perfumeId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eegResultsCollection)
          .where('storeId', isEqualTo: storeId)
          .where('perfumeId', isEqualTo: perfumeId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return EEGResultModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting EEG results for perfume: $e');
      return [];
    }
  }

  Future<Map<String, double>> getEEGStatsForPerfume(String perfumeId) async {
    try {
      final statsDoc = await _firestore
          .collection(AppConstants.eegStatsCollection)
          .doc(perfumeId)
          .get();

      if (statsDoc.exists) {
        final data = statsDoc.data()!;
        return {
          'avgRelaxation': (data['avgRelaxation'] as num?)?.toDouble() ?? 0,
          'avgAttention': (data['avgAttention'] as num?)?.toDouble() ?? 0,
          'avgEngagement': (data['avgEngagement'] as num?)?.toDouble() ?? 0,
          'avgExcitement': (data['avgExcitement'] as num?)?.toDouble() ?? 0,
          'avgStress': (data['avgStress'] as num?)?.toDouble() ?? 0,
          'avgInterest': (data['avgInterest'] as num?)?.toDouble() ?? 0,
          'totalTests': (data['count'] as num?)?.toDouble() ?? 0,
          'lastUpdated':
              (data['lastUpdated'] as Timestamp?)
                      ?.toDate()
                      .millisecondsSinceEpoch
                      .toDouble() ??
                  0,
        };
      }

      final snapshot = await _firestore
          .collection(AppConstants.eegResultsCollection)
          .where('perfumeId', isEqualTo: perfumeId)
          .get();

      if (snapshot.docs.isEmpty) return {};

      double relaxationSum = 0;
      double attentionSum = 0;
      double engagementSum = 0;
      double excitementSum = 0;
      double stressSum = 0;
      double interestSum = 0;
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        relaxationSum += (data['relaxation'] as num?)?.toDouble() ?? 0;
        attentionSum += (data['attention'] as num?)?.toDouble() ?? 0;
        engagementSum += (data['engagement'] as num?)?.toDouble() ?? 0;
        excitementSum += (data['excitement'] as num?)?.toDouble() ?? 0;
        stressSum += (data['stress'] as num?)?.toDouble() ?? 0;
        interestSum += (data['interest'] as num?)?.toDouble() ?? 0;
        count++;
      }

      return {
        'avgRelaxation': relaxationSum / count,
        'avgAttention': attentionSum / count,
        'avgEngagement': engagementSum / count,
        'avgExcitement': excitementSum / count,
        'avgStress': stressSum / count,
        'avgInterest': interestSum / count,
        'totalTests': count.toDouble(),
        'lastUpdated': 0,
      };
    } catch (e) {
      debugPrint('Error getting EEG stats: $e');
      return {};
    }
  }

  Future<List<EEGResultModel>> getRecentEEGResults(
    String perfumeId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eegResultsCollection)
          .where('perfumeId', isEqualTo: perfumeId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => EEGResultModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting recent EEG results: $e');
      return [];
    }
  }
}
