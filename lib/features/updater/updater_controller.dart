import 'package:flutter/foundation.dart';
import 'package:perfume/core/services/setup_service.dart';
import 'package:perfume/core/services/update_service.dart';
import 'package:perfume/core/utils/logger.dart';

class UpdaterController extends ChangeNotifier {
  final UpdateService _updateService = UpdateService();

  bool _initialized = false;
  bool _isChecking = false;
  bool _isUpdating = false;
  bool _updateAvailable = false;
  double _progress = 0;
  String _statusMessage = '';
  String? _error;

  bool get initialized => _initialized;
  bool get isChecking => _isChecking;
  bool get isUpdating => _isUpdating;
  bool get updateAvailable => _updateAvailable;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  String? get error => _error;

  Future<void> initialize() async {
    if (_initialized) return;
    await _updateService.initialize();
    _initialized = true;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    await initialize();
    _isChecking = true;
    _error = null;
    notifyListeners();
    try {
      _updateAvailable = await _updateService.isUpdateAvailable();
    } catch (e, st) {
      _error = e.toString();
      AppLogger.e('checkForUpdates failed', e, st);
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> shouldCheckForUpdate() => SetupService.shouldCheckForUpdate();

  Future<bool> performUpdate({bool force = false}) async {
    await initialize();
    _isUpdating = true;
    _error = null;
    _progress = 0;
    notifyListeners();

    final success = await _updateService.performAutoUpdate(
      force: force,
      onStatus: (status) {
        _statusMessage = status;
        notifyListeners();
      },
      onProgress: (progress) {
        _progress = progress;
        notifyListeners();
      },
    );

    if (!success && _error == null) {
      _error = 'فشل التحديث';
    }

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  Future<void> startAutoUpdateFlow() async {
    await initialize();
    if (_isUpdating) return;

    _isUpdating = true;
    _statusMessage = 'جاري التحقق من التحديثات...';
    _error = null;
    notifyListeners();

    try {
      final success = await _updateService.performAutoUpdateWithJitter(
        onStatus: (status) {
          _statusMessage = status;
          notifyListeners();
        },
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );
      if (!success) {
        _statusMessage = _statusMessage.isEmpty ? 'لا يوجد تحديث جديد' : _statusMessage;
      }
    } catch (e, st) {
      _error = e.toString();
      AppLogger.e('startAutoUpdateFlow failed', e, st);
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
