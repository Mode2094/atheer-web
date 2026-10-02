import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _ensureAuthenticated() async {
    if (_auth.currentUser != null) return;
    await _auth.signInAnonymously();
  }

  Future<Map<String, dynamic>> uploadAPK({
    required File file,
    required String versionName,
    required int versionCode,
  }) async {
    try {
      await _ensureAuthenticated();
      const fileName = 'atheer-release.apk';
      final fileSize = await file.length();
      final storageRef = _storage.ref().child('ota/android/$fileName');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final now = FieldValue.serverTimestamp();

      // Admin-facing update channel.
      await _firestore.collection('app_updates').doc('latest').set({
        'latestVersion': versionCode,
        'versionName': versionName,
        'downloadUrl': downloadUrl,
        'apkStoragePath': 'ota/android/$fileName',
        'releaseDate': now,
        'updatedAt': now,
        'mandatory': false,
        'enabled': true,
        'fileSize': fileSize,
        'updateSignal': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      await _firestore
          .collection('app_updates')
          .doc('history')
          .collection('versions')
          .add({
            'versionCode': versionCode,
            'versionName': versionName,
            'downloadUrl': downloadUrl,
            'releaseDate': now,
            'fileSize': fileSize,
          });

      // Keep compatibility with existing OTA checker in this project.
      await _firestore.collection('app_config').doc('android').set({
        'latestVersion': versionCode,
        'versionName': versionName,
        'apkUrl': downloadUrl,
        'apkStoragePath': 'ota/android/$fileName',
        'mandatory': false,
        'enabled': true,
        'releaseNotes': 'تم رفع إصدار $versionName من لوحة الأدمن',
        'updatedAt': now,
      }, SetOptions(merge: true));

      return {
        'success': true,
        'downloadUrl': downloadUrl,
        'versionCode': versionCode,
        'versionName': versionName,
      };
    } catch (e) {
      debugPrint('Error uploading APK: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getLatestVersion() async {
    try {
      await _ensureAuthenticated();
      final doc = await _firestore.collection('app_updates').doc('latest').get();
      if (doc.exists) {
        return doc.data() ?? <String, dynamic>{};
      }
      return <String, dynamic>{};
    } catch (e) {
      debugPrint('Error getting latest version: $e');
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      await _ensureAuthenticated();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;

      final latestDoc = await _firestore.collection('app_updates').doc('latest').get();
      if (!latestDoc.exists) {
        return {'hasUpdate': false};
      }

      final latestData = latestDoc.data()!;
      final latestVersion = (latestData['latestVersion'] as num?)?.toInt() ?? 0;

      return {
        'hasUpdate': latestVersion > currentVersion,
        'latestVersion': latestVersion,
        'currentVersion': currentVersion,
        'versionName': latestData['versionName'],
        'downloadUrl': latestData['downloadUrl'],
        'mandatory': latestData['mandatory'] ?? false,
        'fileSize': latestData['fileSize'],
      };
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return {'hasUpdate': false, 'error': e.toString()};
    }
  }

  Future<File?> downloadAPK(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('Error downloading APK: $e');
    }
    return null;
  }
}
