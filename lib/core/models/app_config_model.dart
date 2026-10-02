import 'package:perfume/core/models/app_version_model.dart';

class AppConfigModel {
  const AppConfigModel({
    required this.platform,
    required this.version,
    this.enabled = true,
  });

  final String platform;
  final AppVersionModel version;
  final bool enabled;

  factory AppConfigModel.fromMap(Map<String, dynamic> data) {
    return AppConfigModel(
      platform: (data['platform'] as String?)?.trim() ?? 'android',
      version: AppVersionModel(
        latestVersion: (data['latestVersion'] as num?)?.toInt() ?? 0,
        versionName: (data['versionName'] as String?)?.trim() ?? '',
        apkUrl: (data['apkUrl'] as String?)?.trim() ?? '',
        apkStoragePath: (data['apkStoragePath'] as String?)?.trim(),
        apkSha256: (data['apkSha256'] as String?)?.trim(),
        mandatory: data['mandatory'] as bool? ?? false,
        releaseNotes: (data['releaseNotes'] as String?)?.trim(),
      ),
      enabled: data['enabled'] as bool? ?? true,
    );
  }
}
