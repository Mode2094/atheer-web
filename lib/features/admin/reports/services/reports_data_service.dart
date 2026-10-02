import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/features/admin/reports/models/user_report_model.dart';
import 'package:perfume/shared/models/user_model.dart';

class ReportsPageData {
  final List<UserReportModel> users;
  final Map<String, dynamic> stats;

  const ReportsPageData({required this.users, required this.stats});

  factory ReportsPageData.empty() {
    return const ReportsPageData(users: [], stats: _emptyStats);
  }

  static const Map<String, dynamic> _emptyStats = {
    'totalUsers': 0,
    'totalRecommendations': 0,
    'newUsersThisMonth': 0,
    'genderDistribution': <String, int>{},
    'countries': <String, int>{},
  };
}

class ReportsDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static ReportsPageData? _cachedPageData;
  static DateTime? _cacheExpiresAt;
  static const Duration _cacheTtl = Duration(minutes: 2);

  Future<ReportsPageData> getReportsPageData({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final canUseCache =
        !forceRefresh &&
        _cachedPageData != null &&
        _cacheExpiresAt != null &&
        now.isBefore(_cacheExpiresAt!);

    if (canUseCache) {
      return _cachedPageData!;
    }

    try {
      final usersFuture = _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();
      final recommendationsFuture = _firestore
          .collection(AppConstants.recommendationsCollection)
          .get();

      final usersSnapshot = await usersFuture;
      final recommendationsSnapshot = await recommendationsFuture;

      final recommendationCountByUser = <String, int>{};
      final familyCountByUser = <String, Map<String, int>>{};

      for (final recommendationDoc in recommendationsSnapshot.docs) {
        final data = recommendationDoc.data();
        final userId = data['userId'] as String?;
        if (userId == null || userId.isEmpty) {
          continue;
        }

        recommendationCountByUser[userId] =
            (recommendationCountByUser[userId] ?? 0) + 1;

        final family = (data['perfumeFamily'] as String?)?.trim();
        if (family == null || family.isEmpty) {
          continue;
        }

        final familyCount = familyCountByUser.putIfAbsent(
          userId,
          () => <String, int>{},
        );
        familyCount[family] = (familyCount[family] ?? 0) + 1;
      }

      final reports = <UserReportModel>[];
      final genderDist = <String, int>{};
      final countries = <String, int>{};

      final startOfMonth = DateTime(now.year, now.month, 1);
      var newUsersThisMonth = 0;

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final user = UserModel.fromJson({...userData, 'id': userDoc.id});

        final gender = (userData['gender'] as String?)?.trim();
        if (gender != null && gender.isNotEmpty) {
          genderDist[gender] = (genderDist[gender] ?? 0) + 1;
        }

        final country = (userData['country'] as String?)?.trim();
        if (country != null && country.isNotEmpty) {
          countries[country] = (countries[country] ?? 0) + 1;
        }

        final createdAt = _toDateTime(userData['createdAt']);
        if (createdAt != null && createdAt.isAfter(startOfMonth)) {
          newUsersThisMonth++;
        }

        reports.add(
          UserReportModel.fromSummary(
            user: user,
            totalRecommendations: recommendationCountByUser[user.id] ?? 0,
            familyCount: familyCountByUser[user.id] ?? const <String, int>{},
          ),
        );
      }

      final pageData = ReportsPageData(
        users: reports,
        stats: {
          'totalUsers': usersSnapshot.docs.length,
          'totalRecommendations': recommendationsSnapshot.docs.length,
          'newUsersThisMonth': newUsersThisMonth,
          'genderDistribution': genderDist,
          'countries': countries,
        },
      );

      _cachedPageData = pageData;
      _cacheExpiresAt = now.add(_cacheTtl);

      return pageData;
    } catch (e) {
      debugPrint('Error loading reports page data: $e');
      return ReportsPageData.empty();
    }
  }

  Future<List<UserReportModel>> getAllUsersWithReports({
    bool forceRefresh = false,
  }) async {
    final pageData = await getReportsPageData(forceRefresh: forceRefresh);
    return pageData.users;
  }

  Future<Map<String, dynamic>> getGeneralStats({
    bool forceRefresh = false,
  }) async {
    final pageData = await getReportsPageData(forceRefresh: forceRefresh);
    return pageData.stats;
  }

  void invalidateCache() {
    _cachedPageData = null;
    _cacheExpiresAt = null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static Future<String> exportToCSV(List<UserReportModel> users) async {
    final buffer = StringBuffer();
    buffer.writeln(
      'name,phone,gender,country,favorite_family,recommendations_count,registration_date',
    );

    for (final report in users) {
      final createdAt = report.user.createdAt is Timestamp
          ? (report.user.createdAt as Timestamp).toDate()
          : DateTime.now();

      final row = [
        report.user.name,
        report.user.phone,
        report.user.gender,
        report.user.country,
        report.favoriteFamily,
        report.totalRecommendations.toString(),
        '${createdAt.year}/${createdAt.month}/${createdAt.day}',
      ];

      buffer.writeln(row.map((e) => '"$e"').join(','));
    }

    return buffer.toString();
  }
}
