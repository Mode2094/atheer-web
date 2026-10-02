import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfume/core/models/eeg_result_model.dart';
import 'package:perfume/features/eeg/eeg_service.dart';
import 'package:perfume/features/eeg/providers/eeg_device_provider.dart';
import 'package:perfume/features/eeg/providers/mock_eeg_provider.dart';

class EEGController extends ChangeNotifier {
  final EEGService _service = EEGService();

  late EEGDeviceProvider _deviceProvider;
  StreamSubscription<Map<String, double>>? _metricsSubscription;
  Map<String, double>? _lastMetrics;

  bool _isLoading = false;
  List<EEGResultModel> _userResults = [];
  List<EEGResultModel> _perfumeResults = [];
  Map<String, double> _perfumeStats = {};
  String? _error;

  EEGController({EEGDeviceProvider? deviceProvider}) {
    _deviceProvider = deviceProvider ?? MockEEGProvider();
    _attachMetricsListener();
  }

  bool get isLoading => _isLoading;
  List<EEGResultModel> get userResults => _userResults;
  List<EEGResultModel> get perfumeResults => _perfumeResults;
  Map<String, double> get perfumeStats => _perfumeStats;
  String? get error => _error;

  bool get isConnected => _deviceProvider.isConnected;
  bool get isSessionActive => _deviceProvider.isSessionActive;

  // Score مبسط للاستخدام في الواجهة/السجل، يعتمد على آخر قياسات وصلت.
  double get overallScore {
    final metrics = _lastMetrics;
    if (metrics == null) return 0.0;

    final interest = (metrics['interest'] ?? 0.0).clamp(0.0, 1.0).toDouble();
    final excitement =
        (metrics['excitement'] ?? 0.0).clamp(0.0, 1.0).toDouble();
    final stress = (metrics['stress'] ?? 0.0).clamp(0.0, 1.0).toDouble();
    final relaxation =
        (metrics['relaxation'] ?? 0.0).clamp(0.0, 1.0).toDouble();

    final score =
        (interest * 0.4) +
        (excitement * 0.2) +
        ((1 - stress) * 0.2) +
        (relaxation * 0.2);
    return score.clamp(0.0, 1.0).toDouble();
  }

  Future<void> setDeviceProvider(EEGDeviceProvider provider) async {
    _error = null;

    // تنظيف مزوّد الجهاز الحالي بأفضل جهد قبل الاستبدال.
    try {
      await _deviceProvider.stopSession();
    } catch (_) {}
    try {
      await _deviceProvider.disconnect();
    } catch (_) {}

    _deviceProvider = provider;
    _lastMetrics = null;
    _attachMetricsListener();
    notifyListeners();
  }

  Future<bool> connect() async {
    _error = null;
    try {
      final ok = await _deviceProvider.connect();
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _error = null;
    try {
      await _deviceProvider.disconnect();
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> startSession() async {
    _error = null;
    try {
      final ok = await _deviceProvider.startSession();
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, double>?> stopSession() async {
    _error = null;
    try {
      final last = await _deviceProvider.stopSession();
      if (last != null) {
        _lastMetrics = last;
      }
      notifyListeners();
      return last;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> saveResult({
    required String userId,
    required String storeId,
    required String perfumeId,
    required String perfumeName,
    required Map<String, dynamic> eegData,
  }) async {
    _setLoading(true);
    _error = null;

    final success = await _service.saveEEGResult(
      userId: userId,
      storeId: storeId,
      perfumeId: perfumeId,
      perfumeName: perfumeName,
      eegData: eegData,
    );

    if (!success) {
      _error = 'Failed to save EEG result';
    }

    _setLoading(false);
    return success;
  }

  Future<void> loadUserResults(String userId) async {
    _setLoading(true);
    _error = null;
    _userResults = await _service.getEEGResultsForUser(userId);
    _setLoading(false);
  }

  Future<void> loadPerfumeResults({
    required String storeId,
    required String perfumeId,
  }) async {
    _setLoading(true);
    _error = null;
    _perfumeResults = await _service.getEEGResultsForPerfume(
      storeId: storeId,
      perfumeId: perfumeId,
    );
    _setLoading(false);
  }

  Future<void> loadPerfumeStats(String perfumeId) async {
    _setLoading(true);
    _error = null;
    _perfumeStats = {};
    _perfumeStats = await _service.getEEGStatsForPerfume(perfumeId);
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

  void _attachMetricsListener() {
    _metricsSubscription?.cancel();
    _metricsSubscription = _deviceProvider.metricsStream.listen((metrics) {
      _lastMetrics = metrics;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    _metricsSubscription = null;
    super.dispose();
  }
}
