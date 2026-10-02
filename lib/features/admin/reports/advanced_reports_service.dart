import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:printing/printing.dart';

class AdvancedReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getAdvancedStats() async {
    try {
      final usersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();
      final recsSnapshot = await _firestore
          .collection(AppConstants.recommendationsCollection)
          .get();
      final storesSnapshot = await _firestore
          .collection(AppConstants.storesCollection)
          .where('active', isEqualTo: true)
          .get();

      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      var usersThisWeek = 0;
      var usersThisMonth = 0;
      var usersThisYear = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;

        if (createdAt.isAfter(startOfWeek)) usersThisWeek++;
        if (createdAt.isAfter(startOfMonth)) usersThisMonth++;
        if (createdAt.isAfter(startOfYear)) usersThisYear++;
      }

      final recsByMonth = <String, int>{};
      for (final doc in recsSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;

        final monthKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        recsByMonth[monthKey] = (recsByMonth[monthKey] ?? 0) + 1;
      }

      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalRecommendations': recsSnapshot.docs.length,
        'activeStores': storesSnapshot.docs.length,
        'usersThisWeek': usersThisWeek,
        'usersThisMonth': usersThisMonth,
        'usersThisYear': usersThisYear,
        'recommendationsByMonth': recsByMonth,
        'avgRecommendationsPerUser': usersSnapshot.docs.isEmpty
            ? 0
            : recsSnapshot.docs.length / usersSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting advanced stats: $e');
      return {};
    }
  }

  Future<Map<String, int>> getPerfumesPerStore() async {
    try {
      final storesSnapshot = await _firestore
          .collection(AppConstants.storesCollection)
          .get();

      final result = <String, int>{};

      for (final storeDoc in storesSnapshot.docs) {
        final perfumesSnapshot = await storeDoc.reference
            .collection(AppConstants.perfumesCollection)
            .where('active', isEqualTo: true)
            .get();

        result[storeDoc.data()['name']?.toString() ?? StringHelper.tr('unknown')] =
            perfumesSnapshot.docs.length;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting perfumes per store: $e');
      return {};
    }
  }

  Future<Map<int, int>> getUserActivityByHour() async {
    try {
      final recsSnapshot = await _firestore
          .collection(AppConstants.recommendationsCollection)
          .get();

      final activity = <int, int>{};
      for (final doc in recsSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;

        final hour = createdAt.hour;
        activity[hour] = (activity[hour] ?? 0) + 1;
      }

      return activity;
    } catch (e) {
      debugPrint('Error getting user activity: $e');
      return {};
    }
  }

  Future<Uint8List> generatePDF({
    required Map<String, dynamic> stats,
    required Map<String, int> familyDistribution,
    required Map<String, int> perfumesPerStore,
    required Map<int, int> activityByHour,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final familyTotal = familyDistribution.values.fold<int>(
            0,
            (a, b) => a + b,
          );
          final activityRows =
              activityByHour.entries
                  .map<List<String>>(
                    (e) => [
                      '${e.key.toString().padLeft(2, '0')}:00 - ${(e.key + 1).toString().padLeft(2, '0')}:00',
                      e.value.toString(),
                    ],
                  )
                  .toList()
                ..sort(
                  (a, b) => int.parse(
                    a[0].split(':')[0],
                  ).compareTo(int.parse(b[0].split(':')[0])),
                );

          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Neuro-Scent Advisor - Advanced Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('General Stats')),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Total Users',
                  stats['totalUsers']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Total Recs',
                  stats['totalRecommendations']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Active Stores',
                  stats['activeStores']?.toString() ?? '0',
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Users (Week)',
                  stats['usersThisWeek']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Users (Month)',
                  stats['usersThisMonth']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Users (Year)',
                  stats['usersThisYear']?.toString() ?? '0',
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Header(level: 1, child: pw.Text('Perfume Family Distribution')),
            pw.SizedBox(height: 10),
            ...familyDistribution.entries.map((e) {
              final ratio = familyTotal == 0 ? 0.0 : e.value / familyTotal;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  children: [
                    pw.SizedBox(width: 110, child: pw.Text(e.key)),
                    pw.Expanded(
                      child: pw.Stack(
                        children: [
                          pw.Container(
                            height: 20,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey300,
                              borderRadius: pw.BorderRadius.circular(10),
                            ),
                          ),
                          pw.Container(
                            width: ratio * 320,
                            child: pw.Container(
                              height: 20,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue700,
                                borderRadius: pw.BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text('${e.value}'),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 30),
            pw.Header(level: 1, child: pw.Text('Perfumes Per Store')),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: const ['Store', 'Perfumes'],
              data: perfumesPerStore.entries
                  .map((e) => [e.key, e.value.toString()])
                  .toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 30),
            pw.Header(level: 1, child: pw.Text('Activity By Hour')),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: const ['Hour', 'Recommendations'],
              data: activityRows,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildStatCard(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> sharePDF(Uint8List pdfData, String filename) async {
    try {
      await Printing.sharePdf(bytes: pdfData, filename: filename);
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      rethrow;
    }
  }
}
