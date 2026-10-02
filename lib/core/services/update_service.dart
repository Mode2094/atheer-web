import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/models/app_version_model.dart';
import 'package:perfume/core/services/firebase_service.dart';
import 'package:perfume/core/services/setup_service.dart';
import 'package:perfume/core/utils/logger.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
      sendTimeout: const Duration(seconds: AppConstants.connectionTimeoutSeconds),
      headers: const {'Cache-Control': 'no-cache'},
    ),
  );

  PackageInfo? _packageInfo;
  AppVersionModel? _remoteVersion;
  bool _isInitialized = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  bool get isInitialized => _isInitialized;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  AppVersionModel? get remoteVersion => _remoteVersion;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _packageInfo = await PackageInfo.fromPlatform();
    _isInitialized = true;
    AppLogger.i(
      'UpdateService ready. version=${_packageInfo?.version} build=${_packageInfo?.buildNumber}',
    );
  }

  Future<int> getCurrentVersionCode() async {
    await initialize();
    final buildNumber = int.tryParse(_packageInfo?.buildNumber ?? '');
    if (buildNumber != null && buildNumber > 0) return buildNumber;

    final major = int.tryParse((_packageInfo?.version ?? '1').split('.').first);
    return major ?? 1;
  }

  Future<AppVersionModel?> checkForUpdate() async {
    await initialize();
    final initialized = await _firebaseService.initialize();
    if (!initialized) {
      AppLogger.e('Cannot check update because Firebase is not initialized');
      return null;
    }

    try {
      final doc = await _firebaseService.appConfigCollection
          .doc(AppConstants.firebaseConfigDocument)
          .get();
      if (!doc.exists) {
        AppLogger.w('No app config document found');
        return null;
      }

      final version = AppVersionModel.fromFirestore(doc);
      if (!version.isValid() && (version.apkStoragePath ?? '').isNotEmpty) {
        final storageUrl = await _firebaseService.storage
            .ref(version.apkStoragePath)
            .getDownloadURL();
        _remoteVersion = AppVersionModel(
          latestVersion: version.latestVersion,
          versionName: version.versionName,
          apkUrl: storageUrl,
          apkStoragePath: version.apkStoragePath,
          apkSha256: version.apkSha256,
          mandatory: version.mandatory,
          releaseNotes: version.releaseNotes,
        );
      } else {
        _remoteVersion = version;
      }

      AppLogger.i('Remote version fetched: ${_remoteVersion?.latestVersion}');
      return _remoteVersion;
    } catch (e, st) {
      AppLogger.e('checkForUpdate failed', e, st);
      return null;
    }
  }

  Future<bool> isUpdateAvailable() async {
    final current = await getCurrentVersionCode();
    final remote = await checkForUpdate();
    if (remote == null || !remote.isValid()) return false;
    return remote.latestVersion > current;
  }

  Future<bool> requestInstallPermission() async {
    if (!Platform.isAndroid) return false;
    if (await Permission.requestInstallPackages.isGranted) return true;
    final status = await Permission.requestInstallPackages.request();
    return status.isGranted;
  }

  Future<File?> downloadUpdate({
    required String url,
    Function(double progress)? onProgress,
  }) async {
    if (_isDownloading) {
      AppLogger.w('Download already in progress');
      return null;
    }

    _isDownloading = true;
    _downloadProgress = 0;

    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https') {
        AppLogger.e('Rejected non-HTTPS update URL');
        return null;
      }

      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/${AppConstants.apkFileName}');
      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          _downloadProgress = received / total;
          onProgress?.call(_downloadProgress);
        },
      );

      AppLogger.i('APK downloaded: ${file.path}');
      return file;
    } catch (e, st) {
      AppLogger.e('downloadUpdate failed', e, st);
      return null;
    } finally {
      _isDownloading = false;
    }
  }

  Future<bool> _verifyChecksumIfProvided(
    File file,
    String? expectedSha256,
  ) async {
    if (expectedSha256 == null || expectedSha256.isEmpty) return true;
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes).toString();
      return digest.toLowerCase() == expectedSha256.toLowerCase();
    } catch (e, st) {
      AppLogger.e('Checksum verification failed', e, st);
      return false;
    }
  }

  Future<bool> installUpdate(File apkFile) async {
    try {
      final hasPermission = await requestInstallPermission();
      if (!hasPermission) {
        AppLogger.e(AppConstants.errorPermission);
        return false;
      }

      // Explicitly persist setup/session critical values before installer handoff.
      await SetupService.persistCriticalSetupSnapshot();

      final result = await OpenFile.open(apkFile.path);
      final success = result.type == ResultType.done;
      if (!success) {
        AppLogger.e('OpenFile failed: ${result.message}');
      }
      return success;
    } catch (e, st) {
      AppLogger.e('installUpdate failed', e, st);
      return false;
    }
  }

  Future<T?> _withRetries<T>(Future<T?> Function() block) async {
    for (var attempt = 1; attempt <= AppConstants.maxUpdateRetries; attempt++) {
      try {
        final result = await block();
        if (result != null) return result;
      } catch (e, st) {
        AppLogger.e('Retryable OTA operation failed (attempt $attempt)', e, st);
      }

      if (attempt < AppConstants.maxUpdateRetries) {
        final backoff = AppConstants.retryBaseDelayMs * pow(2, attempt - 1);
        await Future.delayed(Duration(milliseconds: backoff.toInt()));
      }
    }
    return null;
  }

  Future<bool> performAutoUpdate({
    Function(String status)? onStatus,
    Function(double progress)? onProgress,
    bool force = false,
  }) async {
    if (!force) {
      final shouldCheck = await SetupService.shouldCheckForUpdate();
      if (!shouldCheck) {
        AppLogger.i('Skipping update check (<24h)');
        return false;
      }
      // Mark check time immediately to avoid checking on every launch
      // during transient network failures.
      await SetupService.saveLastUpdateCheck();
    }

    onStatus?.call('جاري التحقق من التحديثات...');
    final remote = await _withRetries<AppVersionModel?>(checkForUpdate);
    if (remote == null || !remote.isValid()) {
      return false;
    }

    final current = await getCurrentVersionCode();
    if (remote.latestVersion <= current) {
      onStatus?.call(AppConstants.successNoUpdate);
      return false;
    }

    onStatus?.call('جاري تحميل التحديث...');
    final apkFile = await _withRetries<File?>(() {
      return downloadUpdate(url: remote.apkUrl, onProgress: onProgress);
    });

    if (apkFile == null) {
      onStatus?.call(AppConstants.errorDownload);
      return false;
    }

    final checksumOk = await _verifyChecksumIfProvided(apkFile, remote.apkSha256);
    if (!checksumOk) {
      onStatus?.call('فشل التحقق الأمني من ملف التحديث');
      return false;
    }

    onStatus?.call('جاري تثبيت التحديث...');
    final installed = await installUpdate(apkFile);
    if (installed) {
      onStatus?.call(AppConstants.successUpdate);
      return true;
    }

    onStatus?.call(AppConstants.errorInstall);
    return false;
  }

  // Avoid synchronized checks from thousands of kiosks after reboot.
  Future<bool> performAutoUpdateWithJitter({
    int maxStartupDelaySeconds = 90,
    Function(String status)? onStatus,
    Function(double progress)? onProgress,
  }) async {
    final delay = Random().nextInt(maxStartupDelaySeconds + 1);
    if (delay > 0) {
      await Future.delayed(Duration(seconds: delay));
    }
    return performAutoUpdate(onStatus: onStatus, onProgress: onProgress);
  }

  Future<void> cleanupOldApks() async {
    try {
      final directory = await getApplicationSupportDirectory();
      if (!await directory.exists()) return;
      final files = directory.listSync();
      for (final file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          await file.delete();
        }
      }
    } catch (e, st) {
      AppLogger.e('cleanupOldApks failed', e, st);
    }
  }
}
