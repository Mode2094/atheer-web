import 'package:flutter/material.dart';
import 'package:perfume/features/admin/reports/reports_service.dart';

class ReportsController extends ChangeNotifier {
  final ReportsService _service = ReportsService();

  // State
  bool _isLoading = false;
  Map<String, dynamic> _generalStats = {};
  Map<String, int> _familyDistribution = {};
  Map<String, double> _personalityDistribution = {};
  Map<String, double> _sensoryPreferences = {};
  List<Map<String, dynamic>> _recentRecommendations = [];
  String? _error;
  String? _exportedCsv;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic> get generalStats => _generalStats;
  Map<String, int> get familyDistribution => _familyDistribution;
  Map<String, double> get personalityDistribution => _personalityDistribution;
  Map<String, double> get sensoryPreferences => _sensoryPreferences;
  List<Map<String, dynamic>> get recentRecommendations => _recentRecommendations;
  String? get error => _error;
  String? get exportedCsv => _exportedCsv;

  // تحميل كل البيانات
  Future<void> loadAllReports() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        loadGeneralStats(),
        loadFamilyDistribution(),
        loadPersonalityDistribution(),
        loadSensoryPreferences(),
        loadRecentRecommendations(),
      ]);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // تحميل الإحصائيات العامة
  Future<void> loadGeneralStats() async {
    _generalStats = await _service.getGeneralStats();
    notifyListeners();
  }

  // تحميل توزيع العائلات العطرية
  Future<void> loadFamilyDistribution() async {
    _familyDistribution = await _service.getPerfumeFamilyDistribution();
    notifyListeners();
  }

  // تحميل توزيع الشخصيات
  Future<void> loadPersonalityDistribution() async {
    _personalityDistribution = await _service.getPersonalityDistribution();
    notifyListeners();
  }

  // تحميل تفضيلات الحواس
  Future<void> loadSensoryPreferences() async {
    _sensoryPreferences = await _service.getSensoryPreferences();
    notifyListeners();
  }

  // تحميل آخر التوصيات
  Future<void> loadRecentRecommendations() async {
    _recentRecommendations = await _service.getRecentRecommendations();
    notifyListeners();
  }

  // تصدير بيانات العملاء
  Future<void> exportUsers() async {
    _setLoading(true);
    _exportedCsv = await _service.exportUsersToCSV();
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
