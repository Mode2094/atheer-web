import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/features/recommendation/recommendation_service.dart';
import 'package:perfume/shared/models/personality_profile_model.dart';
import 'package:perfume/shared/models/recommendation_model.dart';

class EEGSessionSummary {
  final bool isValid;
  final double eegScore;

  const EEGSessionSummary({required this.isValid, required this.eegScore});
}

class RecommendationController extends ChangeNotifier {
  final RecommendationService _service = RecommendationService();

  bool _isLoading = false;
  Map<String, dynamic>? _recommendation;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get recommendation => _recommendation;
  String? get error => _error;
  bool get hasRecommendation => _recommendation != null;

  Future<bool> getRecommendation({
    required PersonalityProfileModel profile,
    required String storeId,
    required String gender,
    required String userId,
    EEGSessionSummary? eegSummary,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _service.getRecommendation(
        profile: profile,
        storeId: storeId,
        gender: gender,
        userId: userId,
      );

      if (result != null && result['success'] == true) {
        final adjusted = _applyEegScoreIfProvided(result, eegSummary);
        _recommendation = _normalizeRecommendationScores(adjusted);
        await _saveRecommendationToHistory(
          adjusted,
          userId,
          storeId,
          eegSummary,
        );
        _setLoading(false);
        return true;
      }

      _error = result?['error']?.toString() ?? 'Unknown error';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> _saveRecommendationToHistory(
    Map<String, dynamic> result,
    String userId,
    String storeId,
    EEGSessionSummary? eegSummary,
  ) async {
    final main = result['mainRecommendation'];
    if (main is! Map<String, dynamic>) return;

    final scoreRaw = main['matchScore'];
    double confidenceScore = scoreRaw is num ? scoreRaw.toDouble() : 0.0;
    confidenceScore = confidenceScore.clamp(0.0, 1.0).toDouble();

    final wasEegUsed = eegSummary?.isValid ?? false;
    final rec = RecommendationModel(
      userId: userId,
      storeId: storeId,
      perfumeId: (main['id'] ?? '').toString(),
      perfumeName: (main['name'] ?? '').toString(),
      perfumeFamily: (result['family'] ?? '').toString(),
      reason: (main['reason'] ?? '').toString(),
      confidenceScore: confidenceScore,
      wasEegUsed: wasEegUsed,
    );

    // نكتب السجل مباشرة لإضافة `eegScore` دون تغيير الموديل الحالي.
    try {
      final payload = rec.toFirestoreJson();
      if (eegSummary != null) {
        payload['eegScore'] = eegSummary.eegScore;
      }
      await FirebaseFirestore.instance
          .collection(AppConstants.recommendationsCollection)
          .add(payload);
    } catch (_) {
      // تجاهل أخطاء السجل حتى لا تعطل تجربة المستخدم.
    }
  }

  void clear() {
    _recommendation = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic> _normalizeRecommendationScores(
    Map<String, dynamic> result,
  ) {
    final normalized = Map<String, dynamic>.from(result);
    final main = normalized['mainRecommendation'];
    if (main is Map) {
      final normalizedMain = Map<String, dynamic>.from(main);
      final scoreRaw = normalizedMain['matchScore'];
      double confidenceScore = scoreRaw is num ? scoreRaw.toDouble() : 0.0;
      confidenceScore = confidenceScore.clamp(0.0, 1.0).toDouble();
      normalizedMain['matchScore'] = confidenceScore;
      normalized['mainRecommendation'] = normalizedMain;
    }
    return normalized;
  }

  Map<String, dynamic> _applyEegScoreIfProvided(
    Map<String, dynamic> result,
    EEGSessionSummary? eegSummary,
  ) {
    if (eegSummary == null || eegSummary.isValid != true) {
      return result;
    }

    final updated = Map<String, dynamic>.from(result);
    final main = updated['mainRecommendation'];
    if (main is! Map) return updated;

    final normalizedMain = Map<String, dynamic>.from(main);
    final baseRaw = normalizedMain['matchScore'];
    final baseScore = (baseRaw is num) ? baseRaw.toDouble() : 0.0;
    final combinedScore = ((baseScore * 0.7) + (eegSummary.eegScore * 0.3))
        .clamp(0.0, 1.0)
        .toDouble();

    normalizedMain['matchScore'] = combinedScore;
    normalizedMain['wasEegUsed'] = true;
    normalizedMain['eegScore'] = eegSummary.eegScore;
    updated['mainRecommendation'] = normalizedMain;
    return updated;
  }
}
