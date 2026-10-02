import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/features/recommendation/recommendation_service.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/personality_profile_model.dart';

import 'comparison_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFunctions>(),
  MockSpec<HttpsCallable>(),
  MockSpec<HttpsCallableResult>(),
])
void main() {
  group('Cloud vs Local Comparison Tests', () {
    late RecommendationService service;
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late FakeFirebaseFirestore fakeFirestore;

    const storeId = 'test_store';

    final testProfiles = <PersonalityProfileModel>[
      const PersonalityProfileModel(
        openness: 0.8,
        extraversion: 0.7,
        neuroticism: 0.3,
        freshnessPreference: 0.6,
        sweetnessPreference: 0.4,
        warmthPreference: 0.5,
        intensityPreference: 0.7,
      ),
      const PersonalityProfileModel(
        openness: 0.3,
        extraversion: 0.4,
        neuroticism: 0.8,
        freshnessPreference: 0.2,
        sweetnessPreference: 0.9,
        warmthPreference: 0.8,
        intensityPreference: 0.9,
      ),
      const PersonalityProfileModel(
        openness: 0.6,
        extraversion: 0.6,
        neuroticism: 0.5,
        freshnessPreference: 0.5,
        sweetnessPreference: 0.5,
        warmthPreference: 0.5,
        intensityPreference: 0.5,
      ),
      const PersonalityProfileModel(
        openness: 0.9,
        extraversion: 0.8,
        neuroticism: 0.2,
        freshnessPreference: 0.8,
        sweetnessPreference: 0.2,
        warmthPreference: 0.3,
        intensityPreference: 0.6,
      ),
      const PersonalityProfileModel(
        openness: 0.2,
        extraversion: 0.3,
        neuroticism: 0.9,
        freshnessPreference: 0.1,
        sweetnessPreference: 0.8,
        warmthPreference: 0.9,
        intensityPreference: 0.8,
      ),
      const PersonalityProfileModel(
        openness: 0.75,
        extraversion: 0.55,
        neuroticism: 0.35,
        freshnessPreference: 0.45,
        sweetnessPreference: 0.65,
        warmthPreference: 0.55,
        intensityPreference: 0.4,
      ),
      const PersonalityProfileModel(
        openness: 0.45,
        extraversion: 0.35,
        neuroticism: 0.55,
        freshnessPreference: 0.7,
        sweetnessPreference: 0.3,
        warmthPreference: 0.4,
        intensityPreference: 0.5,
      ),
      const PersonalityProfileModel(
        openness: 0.52,
        extraversion: 0.48,
        neuroticism: 0.41,
        freshnessPreference: 0.62,
        sweetnessPreference: 0.58,
        warmthPreference: 0.47,
        intensityPreference: 0.66,
      ),
      const PersonalityProfileModel(
        openness: 0.38,
        extraversion: 0.72,
        neuroticism: 0.44,
        freshnessPreference: 0.82,
        sweetnessPreference: 0.22,
        warmthPreference: 0.35,
        intensityPreference: 0.6,
      ),
      const PersonalityProfileModel(
        openness: 0.67,
        extraversion: 0.29,
        neuroticism: 0.6,
        freshnessPreference: 0.3,
        sweetnessPreference: 0.7,
        warmthPreference: 0.73,
        intensityPreference: 0.77,
      ),
      const PersonalityProfileModel(
        openness: 0.41,
        extraversion: 0.51,
        neuroticism: 0.49,
        freshnessPreference: 0.59,
        sweetnessPreference: 0.43,
        warmthPreference: 0.52,
        intensityPreference: 0.48,
      ),
      const PersonalityProfileModel(
        openness: 0.88,
        extraversion: 0.39,
        neuroticism: 0.22,
        freshnessPreference: 0.47,
        sweetnessPreference: 0.68,
        warmthPreference: 0.77,
        intensityPreference: 0.85,
      ),
    ];

    final mockPerfumes = <PerfumeModel>[
      const PerfumeModel(
        id: 'p1',
        name: 'عطر خشبي',
        family: 'خشبي',
        genderTarget: 'male',
        intensityLevel: 'قوي',
        sweetnessLevel: 'متوسط',
        freshnessLevel: 'خفيف',
        warmthLevel: 'قوي',
        active: true,
      ),
      const PerfumeModel(
        id: 'p2',
        name: 'عطر زهري',
        family: 'زهري',
        genderTarget: 'female',
        intensityLevel: 'خفيف',
        sweetnessLevel: 'قوي',
        freshnessLevel: 'خفيف',
        warmthLevel: 'خفيف',
        active: true,
      ),
      const PerfumeModel(
        id: 'p3',
        name: 'عطر منعش',
        family: 'منعش',
        genderTarget: 'unisex',
        intensityLevel: 'متوسط',
        sweetnessLevel: 'خفيف',
        freshnessLevel: 'قوي',
        warmthLevel: 'خفيف',
        active: true,
      ),
      const PerfumeModel(
        id: 'p4',
        name: 'عطر شرقي',
        family: 'شرقي',
        genderTarget: 'female',
        intensityLevel: 'قوي',
        sweetnessLevel: 'قوي',
        freshnessLevel: 'خفيف',
        warmthLevel: 'قوي',
        active: true,
      ),
      const PerfumeModel(
        id: 'p5',
        name: 'عطر سرخسي',
        family: 'سرخسي',
        genderTarget: 'unisex',
        intensityLevel: 'متوسط',
        sweetnessLevel: 'متوسط',
        freshnessLevel: 'متوسط',
        warmthLevel: 'متوسط',
        active: true,
      ),
      const PerfumeModel(
        id: 'p6',
        name: 'عطر خشبي منعش',
        family: 'Woody',
        genderTarget: 'ذكر',
        intensityLevel: 'متوسط',
        sweetnessLevel: 'خفيف',
        freshnessLevel: 'متوسط',
        warmthLevel: 'قوي',
        active: true,
      ),
      const PerfumeModel(
        id: 'p7',
        name: 'عطر زهري ناعم',
        family: 'Floral',
        genderTarget: 'أنثى',
        intensityLevel: 'خفيف',
        sweetnessLevel: 'متوسط',
        freshnessLevel: 'متوسط',
        warmthLevel: 'خفيف',
        active: true,
      ),
    ];

    setUp(() async {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      fakeFirestore = FakeFirebaseFirestore();

      await _seedPerfumes(
        firestore: fakeFirestore,
        perfumes: mockPerfumes,
        storeId: storeId,
      );

      service = RecommendationService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        callableBuilder: (functions, functionName) => mockCallable,
      );
    });

    test('اختبار التطابق لـ top-1 recommendation', () async {
      final genders = ['male', 'female', 'unisex'];
      var matches = 0;
      var total = 0;

      for (final profile in testProfiles) {
        for (final gender in genders) {
          reset(mockCallable);

          final cloudPayload = _buildCloudStyleRecommendation(
            profile: profile,
            perfumes: mockPerfumes,
            gender: gender,
          );
          final cloudResponse = MockHttpsCallableResult();
          when(cloudResponse.data).thenReturn(cloudPayload);
          when(mockCallable.call(any)).thenAnswer((_) async => cloudResponse);

          final cloudResult = await service.getRecommendation(
            profile: profile,
            storeId: storeId,
            gender: gender,
          );
          expect(cloudResult, isNotNull);
          expect(cloudResult!['success'], true);

          when(mockCallable.call(any)).thenThrow(
            FirebaseFunctionsException(
              code: 'unavailable',
              message: 'forced fallback',
            ),
          );

          final localResult = await service.getRecommendation(
            profile: profile,
            storeId: storeId,
            gender: gender,
          );
          expect(localResult, isNotNull);
          expect(localResult!['success'], true);

          if (_topId(cloudResult) == _topId(localResult)) {
            matches++;
          }
          total++;
        }
      }

      final matchRate = total == 0 ? 0.0 : matches / total;
      expect(
        matchRate,
        greaterThan(0.99),
        reason:
            'Top-1 matching rate is ${(matchRate * 100).toStringAsFixed(2)}%',
      );
    });

    test('مقارنة top-3 matching rate', () async {
      final genders = ['male', 'female', 'unisex'];
      var matches = 0;
      var total = 0;

      for (final profile in testProfiles) {
        for (final gender in genders) {
          reset(mockCallable);

          final cloudPayload = _buildCloudStyleRecommendation(
            profile: profile,
            perfumes: mockPerfumes,
            gender: gender,
          );
          final cloudResponse = MockHttpsCallableResult();
          when(cloudResponse.data).thenReturn(cloudPayload);
          when(mockCallable.call(any)).thenAnswer((_) async => cloudResponse);

          final cloudResult = await service.getRecommendation(
            profile: profile,
            storeId: storeId,
            gender: gender,
          );
          expect(cloudResult, isNotNull);
          expect(cloudResult!['success'], true);

          when(mockCallable.call(any)).thenThrow(
            FirebaseFunctionsException(
              code: 'unavailable',
              message: 'forced fallback',
            ),
          );

          final localResult = await service.getRecommendation(
            profile: profile,
            storeId: storeId,
            gender: gender,
          );
          expect(localResult, isNotNull);
          expect(localResult!['success'], true);

          final cloudTop3 = _topIds(cloudResult, 3);
          final localTop3 = _topIds(localResult, 3);
          if (listEquals(cloudTop3, localTop3)) {
            matches++;
          }
          total++;
        }
      }

      final matchRate = total == 0 ? 0.0 : matches / total;
      expect(
        matchRate,
        greaterThan(0.99),
        reason:
            'Top-3 matching rate is ${(matchRate * 100).toStringAsFixed(2)}%',
      );
    });
  });
}

Future<void> _seedPerfumes({
  required FakeFirebaseFirestore firestore,
  required List<PerfumeModel> perfumes,
  required String storeId,
}) async {
  for (final perfume in perfumes) {
    await firestore
        .collection('stores')
        .doc(storeId)
        .collection('perfumes')
        .doc(perfume.id)
        .set({...perfume.toJson(), 'active': true});
  }
}

Map<String, dynamic> _buildCloudStyleRecommendation({
  required PersonalityProfileModel profile,
  required List<PerfumeModel> perfumes,
  required String gender,
}) {
  const familyScoreWeight = 0.45;
  const coreAlignmentWeight = 0.30;
  const contextAlignmentWeight = 0.25;

  const familyMatching = {
    'منعش': {
      'openness': 0.4,
      'extraversion': 0.6,
      'neuroticism': 0.3,
      'freshness': 0.9,
      'sweetness': 0.2,
      'warmth': 0.1,
      'intensity': 0.3,
    },
    'زهري': {
      'openness': 0.5,
      'extraversion': 0.5,
      'neuroticism': 0.6,
      'freshness': 0.5,
      'sweetness': 0.7,
      'warmth': 0.4,
      'intensity': 0.4,
    },
    'شرقي': {
      'openness': 0.7,
      'extraversion': 0.8,
      'neuroticism': 0.4,
      'freshness': 0.1,
      'sweetness': 0.8,
      'warmth': 0.9,
      'intensity': 0.8,
    },
    'خشبي': {
      'openness': 0.6,
      'extraversion': 0.4,
      'neuroticism': 0.5,
      'freshness': 0.3,
      'sweetness': 0.3,
      'warmth': 0.8,
      'intensity': 0.7,
    },
    'سرخسي': {
      'openness': 0.65,
      'extraversion': 0.55,
      'neuroticism': 0.5,
      'freshness': 0.6,
      'sweetness': 0.4,
      'warmth': 0.6,
      'intensity': 0.6,
    },
  };

  var bestFamily = 'منعش';
  var bestFamilyScore = -1.0;
  for (final entry in familyMatching.entries) {
    final score = _calculateFamilyScore(profile, entry.value);
    if (score > bestFamilyScore) {
      bestFamilyScore = score;
      bestFamily = entry.key;
    }
  }

  final familyWeights = familyMatching[bestFamily]!;
  final recommendations = <Map<String, dynamic>>[];
  for (final perfume in perfumes.where((e) => e.active)) {
    final normalizedPerfume = _normalizePerfumeForScoring(perfume);
    final normalizedFamily = _normalizeFamily(normalizedPerfume.family);

    var familyScore = 0.0;
    familyScore += profile.openness * familyWeights['openness']!;
    familyScore += profile.extraversion * familyWeights['extraversion']!;
    familyScore +=
        (1 - profile.neuroticism) * (1 - familyWeights['neuroticism']!);
    familyScore += profile.freshnessPreference * familyWeights['freshness']!;
    familyScore += profile.sweetnessPreference * familyWeights['sweetness']!;
    familyScore += profile.warmthPreference * familyWeights['warmth']!;
    familyScore += profile.intensityPreference * familyWeights['intensity']!;
    familyScore = familyScore / 7;

    final coreAlignment = _calculateCorePreferenceAlignment(
      profile: profile,
      perfume: normalizedPerfume,
    );
    final contextAlignment = _calculateContextPreferenceAlignment(
      profile: profile,
      perfume: normalizedPerfume,
      normalizedFamily: normalizedFamily,
      familyMatching: familyMatching,
    );

    var totalScore =
        (familyScore * familyScoreWeight) +
        (coreAlignment * coreAlignmentWeight) +
        (contextAlignment * contextAlignmentWeight);
    if (!_genderMatches(normalizedPerfume.genderTarget, gender)) {
      totalScore *= 0.3;
    }
    if (normalizedFamily == bestFamily) {
      totalScore *= 1.2;
    }
    totalScore = totalScore.clamp(0.0, 1.0).toDouble();

    recommendations.add({
      ...normalizedPerfume.toJson(),
      'id': normalizedPerfume.id,
      'family': normalizedFamily,
      'matchScore': totalScore,
    });
  }

  recommendations.sort(
    (a, b) => (b['matchScore'] as double).compareTo(a['matchScore'] as double),
  );

  if (recommendations.isEmpty) {
    return {'success': false, 'error': 'لا توجد عطور مطابقة'};
  }

  final alternativesEnd = recommendations.length >= 7
      ? 7
      : recommendations.length;
  final allEnd = recommendations.length >= 7 ? 7 : recommendations.length;

  return {
    'success': true,
    'family': bestFamily,
    'mainRecommendation': {
      ...recommendations.first,
      'reason': _reasonForFamily(bestFamily),
    },
    'alternatives': recommendations.length > 1
        ? recommendations.sublist(1, alternativesEnd)
        : <Map<String, dynamic>>[],
    'all': recommendations.sublist(0, allEnd),
  };
}

double _calculateFamilyScore(
  PersonalityProfileModel profile,
  Map<String, double> weights,
) {
  var score = 0.0;
  score += profile.openness * weights['openness']!;
  score += profile.extraversion * weights['extraversion']!;
  score += (1 - profile.neuroticism) * (1 - weights['neuroticism']!);
  score += profile.freshnessPreference * weights['freshness']!;
  score += profile.sweetnessPreference * weights['sweetness']!;
  score += profile.warmthPreference * weights['warmth']!;
  score += profile.intensityPreference * weights['intensity']!;
  return score;
}

double _calculateCorePreferenceAlignment({
  required PersonalityProfileModel profile,
  required PerfumeModel perfume,
}) {
  var alignment = 0.0;
  alignment += _closeness(profile.freshnessPreference, perfume.freshnessValue);
  alignment += _closeness(profile.sweetnessPreference, perfume.sweetnessValue);
  alignment += _closeness(profile.warmthPreference, perfume.warmthValue);
  alignment += _closeness(profile.intensityPreference, perfume.intensityValue);
  return alignment / 4;
}

double _calculateContextPreferenceAlignment({
  required PersonalityProfileModel profile,
  required PerfumeModel perfume,
  required String normalizedFamily,
  required Map<String, Map<String, double>> familyMatching,
}) {
  final usageSignal = _resolveUsageSignal(perfume);
  final projectionSignal = _normalize01(
    perfume.projection,
    fallback: perfume.intensityValue,
  );
  final longevitySignal = _normalize01(
    perfume.longevity,
    fallback: ((perfume.intensityValue * 0.6) + (perfume.warmthValue * 0.4))
        .clamp(0.0, 1.0)
        .toDouble(),
  );
  final luxurySignal = _normalize01(
    perfume.luxuryScore,
    fallback: _familyLuxuryBaseline(normalizedFamily, familyMatching),
  );
  final impressionSignal = _resolveImpressionSignal(
    perfume: perfume,
    projectionSignal: projectionSignal,
    luxurySignal: luxurySignal,
  );

  var alignment = 0.0;
  alignment += _closeness(profile.usagePreference, usageSignal);
  alignment += _closeness(profile.projectionPreference, projectionSignal);
  alignment += _closeness(profile.longevityPreference, longevitySignal);
  alignment += _closeness(profile.impressionPreference, impressionSignal);
  alignment += _closeness(profile.luxuryPreference, luxurySignal);
  return alignment / 5;
}

double _resolveUsageSignal(PerfumeModel perfume) {
  final raw =
      (perfume.intensityValue * 0.45) +
      (perfume.warmthValue * 0.35) +
      (perfume.freshnessValue * 0.2);
  return raw.clamp(0.0, 1.0).toDouble();
}

double _resolveImpressionSignal({
  required PerfumeModel perfume,
  required double projectionSignal,
  required double luxurySignal,
}) {
  final raw =
      (projectionSignal * 0.4) +
      (luxurySignal * 0.35) +
      (perfume.sweetnessValue * 0.25);
  return raw.clamp(0.0, 1.0).toDouble();
}

double _familyLuxuryBaseline(
  String family,
  Map<String, Map<String, double>> familyMatching,
) {
  final weights = familyMatching[family];
  if (weights == null) return 0.5;
  final baseline =
      (weights['warmth']! * 0.4) +
      (weights['intensity']! * 0.35) +
      (weights['sweetness']! * 0.25);
  return baseline.clamp(0.0, 1.0).toDouble();
}

double _closeness(double target, double value) {
  return (1 - (target - value).abs()).clamp(0.0, 1.0).toDouble();
}

double _normalize01(double? value, {double fallback = 0.5}) {
  final candidate = value;
  if (candidate == null || candidate.isNaN) {
    return fallback.clamp(0.0, 1.0).toDouble();
  }
  return candidate.clamp(0.0, 1.0).toDouble();
}

PerfumeModel _normalizePerfumeForScoring(PerfumeModel perfume) {
  final json = Map<String, dynamic>.from(perfume.toJson());
  json['id'] = perfume.id;
  json['family'] = _normalizeFamily(json['family']?.toString() ?? '');
  json['intensityLevel'] = _resolveLevel(
    json: json,
    levelKey: 'intensityLevel',
    legacyNumericKey: 'intensity',
    levels: PerfumeConstants.intensityLevels,
    defaultLevel: 'معتدل',
    englishAliases: const {
      'Light': 'خفيف',
      'Moderate': 'معتدل',
      'Strong': 'قوي',
    },
  );
  json['sweetnessLevel'] = _resolveLevel(
    json: json,
    levelKey: 'sweetnessLevel',
    legacyNumericKey: 'sweetness',
    levels: PerfumeConstants.sweetnessLevels,
    defaultLevel: 'حلو',
    englishAliases: const {
      'Dry': 'غير حلو',
      'Light Sweet': 'حلو خفيف',
      'Sweet': 'حلو',
      'Very Sweet': 'حلو جداً',
    },
  );
  json['freshnessLevel'] = _resolveLevel(
    json: json,
    levelKey: 'freshnessLevel',
    legacyNumericKey: 'freshness',
    levels: PerfumeConstants.freshnessLevels,
    defaultLevel: 'معتدل',
    englishAliases: const {
      'Warm': 'دافئ',
      'Balanced': 'معتدل',
      'Fresh': 'منعش',
    },
  );
  json['warmthLevel'] = _resolveLevel(
    json: json,
    levelKey: 'warmthLevel',
    legacyNumericKey: 'warmth',
    levels: PerfumeConstants.warmthLevels,
    defaultLevel: 'محايد',
    englishAliases: const {'Cool': 'بارد', 'Neutral': 'محايد', 'Warm': 'دافئ'},
  );
  json['projection'] = _resolveMetric(
    json: json,
    key: 'projection',
    fallback: PerfumeConstants.intensityLevels[json['intensityLevel']] ?? 0.5,
  );
  json['longevity'] = _resolveMetric(
    json: json,
    key: 'longevity',
    fallback:
        ((PerfumeConstants.intensityLevels[json['intensityLevel']] ?? 0.5) *
            0.6) +
        ((PerfumeConstants.warmthLevels[json['warmthLevel']] ?? 0.5) * 0.4),
  );
  json['luxuryScore'] = _resolveMetric(
    json: json,
    key: 'luxuryScore',
    fallback: 0.5,
  );
  return PerfumeModel.fromJson(json);
}

String _resolveLevel({
  required Map<String, dynamic> json,
  required String levelKey,
  required String legacyNumericKey,
  required Map<String, double> levels,
  required String defaultLevel,
  required Map<String, String> englishAliases,
}) {
  final rawLevel = json[levelKey];
  if (rawLevel is String) {
    if (levels.containsKey(rawLevel)) {
      return rawLevel;
    }
    final mapped = englishAliases[rawLevel];
    if (mapped != null) {
      return mapped;
    }
  }

  final rawNumeric = json[legacyNumericKey];
  if (rawNumeric is num) {
    return _closestLevel(rawNumeric.toDouble(), levels);
  }

  return defaultLevel;
}

String _closestLevel(double value, Map<String, double> levels) {
  var selected = levels.keys.first;
  var minDiff = (value - levels[selected]!).abs();
  for (final entry in levels.entries) {
    final diff = (value - entry.value).abs();
    if (diff < minDiff) {
      minDiff = diff;
      selected = entry.key;
    }
  }
  return selected;
}

double _resolveMetric({
  required Map<String, dynamic> json,
  required String key,
  required double fallback,
}) {
  final raw = json[key];
  if (raw is num) {
    return raw.toDouble().clamp(0.0, 1.0).toDouble();
  }
  return fallback.clamp(0.0, 1.0).toDouble();
}

String _normalizeFamily(String family) {
  switch (family) {
    case 'زهري':
    case 'شرقي':
    case 'خشبي':
    case 'منعش':
    case 'سرخسي':
      return family;
    case 'Floral':
      return 'زهري';
    case 'Oriental':
      return 'شرقي';
    case 'Woody':
      return 'خشبي';
    case 'Fresh':
      return 'منعش';
    case 'Fougere':
    case 'Fougère':
      return 'سرخسي';
    default:
      return 'منعش';
  }
}

String _reasonForFamily(String bestFamily) {
  switch (bestFamily) {
    case 'منعش':
      return 'نشيط ومنعش، مثالي لشخصيتك المنطلقة';
    case 'زهري':
      return 'أنيق وجذاب، يعكس رقتك وحساسيتك';
    case 'شرقي':
      return 'دافئ وجريء، يليق بشخصيتك القوية';
    case 'خشبي':
      return 'كلاسيكي ومتين، يعبر عن ثقتك بنفسك';
    case 'سرخسي':
      return 'منعش وحيوي، يناسب شخصيتك النشطة';
    default:
      return 'متوازن ومناسب لتفضيلاتك الشخصية';
  }
}

bool _genderMatches(String perfumeGender, String userGender) {
  final normalizedPerfume = _normalizeGender(perfumeGender);
  final normalizedUser = _normalizeGender(userGender);

  if (normalizedUser.isEmpty || normalizedUser == 'unisex') {
    return true;
  }
  if (normalizedPerfume == 'unisex') {
    return true;
  }
  return normalizedPerfume == normalizedUser;
}

String _normalizeGender(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'male' || value == 'ذكر') {
    return 'male';
  }
  if (normalized == 'female' || value == 'أنثى') {
    return 'female';
  }
  if (normalized == 'unisex' || value == 'للجنسين') {
    return 'unisex';
  }
  return normalized;
}

String? _topId(Map<String, dynamic> result) {
  final main = result['mainRecommendation'];
  if (main is Map && main['id'] is String) {
    return main['id'] as String;
  }
  return null;
}

List<String> _topIds(Map<String, dynamic> result, int count) {
  final all = result['all'];
  if (all is! List) return const [];
  return all
      .take(count)
      .map((item) {
        if (item is Map && item['id'] is String) {
          return item['id'] as String;
        }
        return '';
      })
      .where((id) => id.isNotEmpty)
      .toList();
}
