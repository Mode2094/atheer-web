import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:perfume/features/admin/reports/advanced_reports_service.dart';
import 'package:perfume/features/admin/reports/reports_service.dart';

class AdvancedReportsController extends ChangeNotifier {
  final ReportsService _reportsService = ReportsService();
  final AdvancedReportsService _advancedService = AdvancedReportsService();

  bool _isLoading = false;
  Map<String, dynamic> _advancedStats = {};
  Map<String, int> _perfumesPerStore = {};
  Map<int, int> _userActivity = {};
  Uint8List? _generatedPDF;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic> get advancedStats => _advancedStats;
  Map<String, int> get perfumesPerStore => _perfumesPerStore;
  Map<int, int> get userActivity => _userActivity;
  Uint8List? get generatedPDF => _generatedPDF;
  String? get error => _error;

  Future<void> loadAllAdvancedData() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _loadAdvancedStats(),
        _loadPerfumesPerStore(),
        _loadUserActivity(),
      ]);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<void> _loadAdvancedStats() async {
    _advancedStats = await _advancedService.getAdvancedStats();
    notifyListeners();
  }

  Future<void> _loadPerfumesPerStore() async {
    _perfumesPerStore = await _advancedService.getPerfumesPerStore();
    notifyListeners();
  }

  Future<void> _loadUserActivity() async {
    _userActivity = await _advancedService.getUserActivityByHour();
    notifyListeners();
  }

  Future<void> generateAndSharePDF() async {
    _setLoading(true);
    _error = null;

    try {
      final familyDist = await _reportsService.getPerfumeFamilyDistribution();
      final pdfData = await _advancedService.generatePDF(
        stats: _advancedStats,
        familyDistribution: familyDist,
        perfumesPerStore: _perfumesPerStore,
        activityByHour: _userActivity,
      );

      _generatedPDF = pdfData;
      final now = DateTime.now();
      final filename = 'report_${now.year}_${now.month}_${now.day}.pdf';
      await _advancedService.sharePDF(pdfData, filename);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
