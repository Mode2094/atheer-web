import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:perfume/features/update/update_service.dart';

class UpdateController extends ChangeNotifier {
  final UpdateService _service = UpdateService();

  bool _isLoading = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _fileSize;
  String? _versionName;
  int? _versionCode;
  String? _error;
  Map<String, dynamic>? _latestVersion;
  double _uploadProgress = 0.0;

  bool get isLoading => _isLoading;
  String? get selectedFilePath => _selectedFilePath;
  String? get selectedFileName => _selectedFileName;
  int? get fileSize => _fileSize;
  String? get versionName => _versionName;
  int? get versionCode => _versionCode;
  String? get error => _error;
  Map<String, dynamic>? get latestVersion => _latestVersion;
  double get uploadProgress => _uploadProgress;

  UpdateController() {
    loadLatestVersion();
  }

  Future<void> loadLatestVersion() async {
    _latestVersion = await _service.getLatestVersion();
    notifyListeners();
  }

  Future<void> pickAPK() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['apk'],
        allowMultiple: false,
      );

      if (result != null) {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _fileSize = result.files.single.size;

        final regex = RegExp(r'v(\d+\.\d+\.\d+)');
        final match = regex.firstMatch(_selectedFileName ?? '');
        if (match != null) {
          _versionName = match.group(1);
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> uploadUpdate({
    required String versionName,
    required int versionCode,
  }) async {
    if (_selectedFilePath == null) {
      _error = 'الرجاء اختيار ملف APK';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _uploadProgress = 0.0;
    _error = null;

    final file = File(_selectedFilePath!);
    final result = await _service.uploadAPK(
      file: file,
      versionName: versionName,
      versionCode: versionCode,
    );

    _uploadProgress = 1.0;
    _setLoading(false);

    if (result['success'] == true) {
      _selectedFilePath = null;
      _selectedFileName = null;
      _fileSize = null;
      _versionName = null;
      _versionCode = null;
      await loadLatestVersion();
      return true;
    } else {
      _error = result['error']?.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSelection() {
    _selectedFilePath = null;
    _selectedFileName = null;
    _fileSize = null;
    _versionName = null;
    _versionCode = null;
    notifyListeners();
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
