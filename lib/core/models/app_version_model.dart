import 'package:cloud_firestore/cloud_firestore.dart';

class AppVersionModel {
  const AppVersionModel({
    required this.latestVersion,
    required this.versionName,
    required this.apkUrl,
    this.apkStoragePath,
    this.apkSha256,
    this.mandatory = false,
    this.releaseNotes,
  });

  final int latestVersion;
  final String versionName;
  final String apkUrl;
  final String? apkStoragePath;
  final String? apkSha256;
  final bool mandatory;
  final String? releaseNotes;

  factory AppVersionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppVersionModel(
      latestVersion: (data['latestVersion'] as num?)?.toInt() ?? 0,
      versionName: (data['versionName'] as String?)?.trim() ?? '',
      apkUrl: (data['apkUrl'] as String?)?.trim() ?? '',
      apkStoragePath: (data['apkStoragePath'] as String?)?.trim(),
      apkSha256: (data['apkSha256'] as String?)?.trim(),
      mandatory: data['mandatory'] as bool? ?? false,
      releaseNotes: (data['releaseNotes'] as String?)?.trim(),
    );
  }

  bool isValid() => latestVersion > 0 && apkUrl.isNotEmpty;
}
