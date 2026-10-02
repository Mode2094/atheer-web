import 'package:perfume/shared/models/recommendation_model.dart';
import 'package:perfume/shared/models/user_model.dart';

class UserReportModel {
  final UserModel user;
  final int totalRecommendations;
  final String favoriteFamily;
  final bool hasCompleteProfile;
  final Map<String, double> personalityAverages;

  UserReportModel({
    required this.user,
    required this.totalRecommendations,
    required this.favoriteFamily,
    required this.hasCompleteProfile,
    required this.personalityAverages,
  });

  factory UserReportModel.fromUser(
    UserModel user,
    List<RecommendationModel> recs,
  ) {
    final familyCount = <String, int>{};
    for (final rec in recs) {
      final family = rec.perfumeFamily;
      familyCount[family] = (familyCount[family] ?? 0) + 1;
    }

    return UserReportModel.fromSummary(
      user: user,
      totalRecommendations: recs.length,
      familyCount: familyCount,
    );
  }

  factory UserReportModel.fromSummary({
    required UserModel user,
    required int totalRecommendations,
    required Map<String, int> familyCount,
  }) {
    var favoriteFamily = 'غير محدد';
    var maxCount = 0;
    familyCount.forEach((family, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteFamily = family;
      }
    });

    final hasCompleteProfile =
        user.name.isNotEmpty &&
        user.gender.isNotEmpty &&
        user.personalityProfile.isNotEmpty;

    final personalityAverages = <String, double>{};
    if (user.personalityProfile.isNotEmpty) {
      personalityAverages['openness'] =
          (user.personalityProfile['openness'] as num?)?.toDouble() ?? 0.5;
      personalityAverages['extraversion'] =
          (user.personalityProfile['extraversion'] as num?)?.toDouble() ?? 0.5;
      personalityAverages['neuroticism'] =
          (user.personalityProfile['neuroticism'] as num?)?.toDouble() ?? 0.5;
      personalityAverages['freshness'] =
          (user.personalityProfile['freshnessPreference'] as num?)
              ?.toDouble() ??
          0.5;
      personalityAverages['sweetness'] =
          (user.personalityProfile['sweetnessPreference'] as num?)
              ?.toDouble() ??
          0.5;
      personalityAverages['warmth'] =
          (user.personalityProfile['warmthPreference'] as num?)?.toDouble() ??
          0.5;
      personalityAverages['intensity'] =
          (user.personalityProfile['intensityPreference'] as num?)
              ?.toDouble() ??
          0.5;
    }

    return UserReportModel(
      user: user,
      totalRecommendations: totalRecommendations,
      favoriteFamily: favoriteFamily,
      hasCompleteProfile: hasCompleteProfile,
      personalityAverages: personalityAverages,
    );
  }
}
