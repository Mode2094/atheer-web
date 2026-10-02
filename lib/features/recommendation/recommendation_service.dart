// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/core/services/telemetry_service.dart';
import 'package:perfume/features/stores/store_cache_service.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/personality_profile_model.dart';
import 'package:perfume/shared/models/recommendation_model.dart';

const int _maxRetries = 2;
const Duration _initialRetryDelay = Duration(milliseconds: 500);
const Duration _cloudTimeout = Duration(seconds: 5);
const double _familyScoreWeight = 0.45;
const double _coreAlignmentWeight = 0.30;
const double _contextAlignmentWeight = 0.25;

class RecommendationService {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final String _cloudFunctionName;
  final HttpsCallable Function(FirebaseFunctions functions, String functionName)
  _callableBuilder;

  RecommendationService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    String cloudFunctionName = 'getRecommendationV2',
    HttpsCallable Function(FirebaseFunctions functions, String functionName)?
    callableBuilder,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudFunctionName = cloudFunctionName,
       _callableBuilder = callableBuilder ?? _defaultCallableBuilder;

  static HttpsCallable _defaultCallableBuilder(
    FirebaseFunctions functions,
    String functionName,
  ) {
    return functions.httpsCallable(functionName);
  }

  static const Map<String, Map<String, double>> FAMILY_MATCHING = {
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

  Future<Map<String, dynamic>?> getRecommendation({
    required PersonalityProfileModel profile,
    required String storeId,
    required String gender,
    String? userId,
  }) async {
    final stopwatch = Stopwatch()..start();
    Map<String, dynamic>? result;

    if (userId != null && userId.trim().isNotEmpty) {
      result = await _getRecommendationFromCloud(
        profile: profile,
        storeId: storeId,
        gender: gender,
        userId: userId,
      );
    } else {
      try {
        final callable = _callableBuilder(_functions, _cloudFunctionName);
        final response = await callable.call({
          'profile': profile.toJson(),
          'storeId': storeId,
          'gender': gender,
        });

        final data = response.data;
        if (data is Map) {
          result = Map<String, dynamic>.from(data);
        }
      } catch (e) {
        debugPrint('Cloud function failed (legacy), using local fallback: $e');
      }
    }

    if (result == null || result['success'] != true) {
      final localResult = await _getRecommendationLocal(
        profile: profile,
        storeId: storeId,
        gender: gender,
      );

      if (userId != null &&
          userId.trim().isNotEmpty &&
          result != null &&
          result['success'] != true) {
        unawaited(
          TelemetryService().logFallback(
            userId: userId,
            storeId: storeId,
            reason: 'cloud_unsuccessful_used_local',
            totalLatency: stopwatch.elapsed,
            retryCount: 0,
          ),
        );
      }

      if (localResult != null && localResult['success'] == true) {
        return _enforceStrictGenderPolicy(localResult, gender);
      }
      return localResult;
    }

    return _enforceStrictGenderPolicy(result, gender);
  }

  Future<Map<String, dynamic>?> _getRecommendationFromCloud({
    required PersonalityProfileModel profile,
    required String storeId,
    required String gender,
    required String userId,
  }) async {
    var retryCount = 0;
    var currentDelay = _initialRetryDelay;
    final stopwatch = Stopwatch()..start();

    while (retryCount <= _maxRetries) {
      try {
        final callable = _callableBuilder(_functions, _cloudFunctionName);
        final dynamic response = await Future.any([
          callable.call({
            'profile': profile.toJson(),
            'storeId': storeId,
            'gender': gender,
          }),
          Future.delayed(
            _cloudTimeout,
            () => throw TimeoutException('Cloud timeout'),
          ),
        ]);

        if (response is! HttpsCallableResult) {
          throw StateError('Unexpected cloud response type');
        }

        final data = response.data;
        if (data is Map) {
          final mapped = Map<String, dynamic>.from(data);
          final success = mapped['success'] == true;
          unawaited(
            TelemetryService().logCloudCall(
              userId: userId,
              storeId: storeId,
              success: success,
              latency: stopwatch.elapsed,
              source: retryCount == 0 ? 'cloud' : 'retry_$retryCount',
            ),
          );
          return mapped;
        }

        unawaited(
          TelemetryService().logCloudCall(
            userId: userId,
            storeId: storeId,
            success: false,
            latency: stopwatch.elapsed,
            errorCode: 'InvalidResponse',
            errorMessage: 'Cloud function returned non-map data',
            source: retryCount == 0 ? 'cloud' : 'retry_$retryCount',
          ),
        );
        return null;
      } catch (e) {
        retryCount++;
        unawaited(
          TelemetryService().logCloudCall(
            userId: userId,
            storeId: storeId,
            success: false,
            latency: stopwatch.elapsed,
            errorCode: e.runtimeType.toString(),
            errorMessage: e.toString(),
            source: retryCount == 1 ? 'cloud' : 'retry_${retryCount - 1}',
          ),
        );

        if (retryCount > _maxRetries) {
          unawaited(
            TelemetryService().logFallback(
              userId: userId,
              storeId: storeId,
              reason: _fallbackReasonFromError(e),
              totalLatency: stopwatch.elapsed,
              retryCount: retryCount - 1,
            ),
          );
          debugPrint('Cloud function failed after retries: $e');
          return null;
        }

        await Future.delayed(currentDelay);
        currentDelay *= 2;
      }
    }

    return null;
  }

  String _fallbackReasonFromError(Object error) {
    if (error is TimeoutException) return 'cloud_timeout';
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unauthenticated') return 'auth_error';
      return 'cloud_${error.code}';
    }
    return 'cloud_failed_after_$_maxRetries retries';
  }

  // Internal fallback only: used when Cloud Function is unavailable.
  Future<Map<String, dynamic>?> _getRecommendationLocal({
    required PersonalityProfileModel profile,
    required String storeId,
    required String gender,
  }) async {
    try {
      final cacheService = StoreCacheService();
      final cachedPerfumes = cacheService.getCachedPerfumes(storeId);
      late final List<PerfumeModel> perfumes;

      if (cachedPerfumes != null) {
        debugPrint('Using cached perfumes for store $storeId');
        perfumes = cachedPerfumes;
      } else {
        debugPrint('Fetching perfumes from Firestore for store $storeId');
        final perfumesSnapshot = await _firestore
            .collection(AppConstants.storesCollection)
            .doc(storeId)
            .collection(AppConstants.perfumesCollection)
            .where('active', isEqualTo: true)
            .get();
        perfumes = perfumesSnapshot.docs.map(_perfumeFromDoc).toList();
        cacheService.cachePerfumes(storeId, perfumes);
      }

      if (perfumes.isEmpty) {
        return {'success': false, 'error': 'No perfumes found in this store'};
      }

      final bestFamily = _findBestFamily(profile);
      final recommendations = <Map<String, dynamic>>[];
      final familyWeights =
          FAMILY_MATCHING[bestFamily] ?? FAMILY_MATCHING['منعش']!;
      final openness = profile.openness;
      final extraversion = profile.extraversion;
      final neuroticism = profile.neuroticism;
      final freshnessPref = profile.freshnessPreference;
      final sweetnessPref = profile.sweetnessPreference;
      final warmthPref = profile.warmthPreference;
      final intensityPref = profile.intensityPreference;

      for (final perfume in perfumes) {
        final normalizedFamily = _normalizeFamily(perfume.family);

        double familyScore = 0;
        familyScore += openness * familyWeights['openness']!;
        familyScore += extraversion * familyWeights['extraversion']!;
        familyScore += (1 - neuroticism) * (1 - familyWeights['neuroticism']!);
        familyScore += freshnessPref * familyWeights['freshness']!;
        familyScore += sweetnessPref * familyWeights['sweetness']!;
        familyScore += warmthPref * familyWeights['warmth']!;
        familyScore += intensityPref * familyWeights['intensity']!;
        familyScore = familyScore / 7;

        final corePreferenceAlignment = _calculateCorePreferenceAlignment(
          profile: profile,
          perfume: perfume,
        );
        final contextPreferenceAlignment = _calculateContextPreferenceAlignment(
          profile: profile,
          perfume: perfume,
          normalizedFamily: normalizedFamily,
        );

        double totalScore =
            (familyScore * _familyScoreWeight) +
            (corePreferenceAlignment * _coreAlignmentWeight) +
            (contextPreferenceAlignment * _contextAlignmentWeight);

        if (!_genderMatches(perfume.genderTarget, gender)) {
          continue;
        }

        if (normalizedFamily == bestFamily) {
          totalScore *= 1.2;
        }
        totalScore = totalScore.clamp(0.0, 1.0).toDouble();

        recommendations.add({
          ...perfume.toJson(),
          'id': perfume.id,
          'family': normalizedFamily,
          'matchScore': totalScore,
        });
      }

      recommendations.sort(
        (a, b) =>
            (b['matchScore'] as double).compareTo(a['matchScore'] as double),
      );

      if (recommendations.isEmpty) {
        return {
          'success': true,
          'family': bestFamily,
          'mainRecommendation': null,
          'alternatives': <Map<String, dynamic>>[],
          'all': <Map<String, dynamic>>[],
          'message': 'no_gender_match',
        };
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
    } catch (e) {
      debugPrint('Local recommendation error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  String _findBestFamily(PersonalityProfileModel profile) {
    var bestFamily = 'منعش';
    var bestScore = -1.0;

    for (final entry in FAMILY_MATCHING.entries) {
      final score = _calculateFamilyScore(profile, entry.value);
      if (score > bestScore) {
        bestScore = score;
        bestFamily = entry.key;
      }
    }

    return bestFamily;
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
    alignment += _closeness(
      profile.freshnessPreference,
      perfume.freshnessValue,
    );
    alignment += _closeness(
      profile.sweetnessPreference,
      perfume.sweetnessValue,
    );
    alignment += _closeness(profile.warmthPreference, perfume.warmthValue);
    alignment += _closeness(
      profile.intensityPreference,
      perfume.intensityValue,
    );
    return alignment / 4;
  }

  double _calculateContextPreferenceAlignment({
    required PersonalityProfileModel profile,
    required PerfumeModel perfume,
    required String normalizedFamily,
  }) {
    final usageSignal = _resolveUsageSignal(perfume);
    final projectionSignal = _resolveProjectionSignal(perfume);
    final longevitySignal = _resolveLongevitySignal(perfume);
    final luxurySignal = _resolveLuxurySignal(
      perfume: perfume,
      normalizedFamily: normalizedFamily,
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

  double _resolveProjectionSignal(PerfumeModel perfume) {
    return _normalize01(perfume.projection, fallback: perfume.intensityValue);
  }

  double _resolveLongevitySignal(PerfumeModel perfume) {
    final fallback =
        ((perfume.intensityValue * 0.6) + (perfume.warmthValue * 0.4))
            .clamp(0.0, 1.0)
            .toDouble();
    return _normalize01(perfume.longevity, fallback: fallback);
  }

  double _resolveLuxurySignal({
    required PerfumeModel perfume,
    required String normalizedFamily,
  }) {
    return _normalize01(
      perfume.luxuryScore,
      fallback: _familyLuxuryBaseline(normalizedFamily),
    );
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

  double _familyLuxuryBaseline(String family) {
    final weights = FAMILY_MATCHING[family];
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

  PerfumeModel _perfumeFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = Map<String, dynamic>.from(doc.data());
    json['id'] = doc.id;

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
      englishAliases: const {
        'Cool': 'بارد',
        'Neutral': 'محايد',
        'Warm': 'دافئ',
      },
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
      fallback: _familyLuxuryBaseline(json['family']?.toString() ?? ''),
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

  String _normalizeFamily(String family) {
    if (PerfumeConstants.mainFamilies.contains(family)) {
      return family;
    }
    switch (family) {
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

  Future<void> saveRecommendation(RecommendationModel recommendation) async {
    try {
      await _firestore
          .collection(AppConstants.recommendationsCollection)
          .add(recommendation.toFirestoreJson());
    } catch (e) {
      debugPrint('Error saving recommendation: $e');
    }
  }

  Map<String, dynamic> _enforceStrictGenderPolicy(
    Map<String, dynamic> source,
    String userGender,
  ) {
    final result = Map<String, dynamic>.from(source);
    final allCandidates = <Map<String, dynamic>>[];

    final all = result['all'];
    if (all is List) {
      allCandidates.addAll(
        all.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    }

    if (allCandidates.isEmpty) {
      final main = result['mainRecommendation'];
      if (main is Map) {
        allCandidates.add(Map<String, dynamic>.from(main));
      }
      final alternatives = result['alternatives'];
      if (alternatives is List) {
        allCandidates.addAll(
          alternatives
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
    }

    final filtered = allCandidates.where((item) {
      final perfumeGender = item['genderTarget']?.toString() ?? '';
      return _genderMatches(perfumeGender, userGender);
    }).toList();

    if (filtered.isEmpty) {
      result['mainRecommendation'] = null;
      result['alternatives'] = <Map<String, dynamic>>[];
      result['all'] = <Map<String, dynamic>>[];
      result['message'] = 'no_gender_match';
      result['success'] = true;
      return result;
    }

    final uniqueById = <String, Map<String, dynamic>>{};
    for (final item in filtered) {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      uniqueById[id] = item;
    }
    final unique = uniqueById.isNotEmpty
        ? uniqueById.values.toList()
        : filtered;

    final preferredMain = result['mainRecommendation'];
    Map<String, dynamic>? main;
    if (preferredMain is Map) {
      final normalizedMain = Map<String, dynamic>.from(preferredMain);
      final mainGender = normalizedMain['genderTarget']?.toString() ?? '';
      if (_genderMatches(mainGender, userGender)) {
        main = normalizedMain;
      }
    }
    main ??= unique.first;

    final mainId = main['id']?.toString() ?? '';
    final alternatives = unique
        .where((item) => (item['id']?.toString() ?? '') != mainId)
        .take(6)
        .toList();

    if ((main['reason']?.toString() ?? '').isEmpty) {
      final sourceMain = result['mainRecommendation'];
      if (sourceMain is Map && sourceMain['reason'] != null) {
        main['reason'] = sourceMain['reason'];
      }
    }

    result['mainRecommendation'] = main;
    result['alternatives'] = alternatives;
    result['all'] = [main, ...alternatives].take(7).toList();
    result['success'] = true;
    return result;
  }

  bool _genderMatches(String perfumeGender, String userGender) {
    final normalizedPerfume = _normalizeGender(perfumeGender);
    final normalizedUser = _normalizeGender(userGender);

    if (normalizedUser.isEmpty) return normalizedPerfume == 'unisex';
    if (normalizedPerfume.isEmpty) return false;
    return normalizedPerfume == normalizedUser;
  }

  String _normalizeGender(String value) {
    var normalized = value.trim().toLowerCase();
    normalized = normalized
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');

    if (normalized == 'male' ||
        normalized == 'm' ||
        normalized == 'ذكر' ||
        value == AppConstants.genderMale) {
      return 'male';
    }
    if (normalized == 'female' ||
        normalized == 'f' ||
        normalized == 'انثى' ||
        normalized == 'انثي' ||
        value == AppConstants.genderFemale) {
      return 'female';
    }
    if (normalized == 'unisex' ||
        normalized == 'both' ||
        normalized == 'all' ||
        normalized == 'للجنسين' ||
        value == AppConstants.genderUnisex) {
      return 'unisex';
    }
    return normalized;
  }
}
