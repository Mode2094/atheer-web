import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/update/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  final UpdateService _service = UpdateService();

  Future<void> checkForUpdate(BuildContext context) async {
    final result = await _service.checkForUpdate();
    if (!context.mounted) return;

    if (result['hasUpdate'] == true) {
      _showUpdateDialog(
        context,
        result['versionName']?.toString(),
        (result['latestVersion'] as num?)?.toInt(),
        result['mandatory'] == true,
        result['downloadUrl']?.toString(),
      );
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String? versionName,
    int? latestVersion,
    bool mandatory,
    String? downloadUrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (ctx) => PopScope(
        canPop: !mandatory,
        child: AlertDialog(
          backgroundColor: const Color(0xFF23233D),
          title: const Text(
            'تحديث جديد متوفر',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإصدار الجديد: ${versionName ?? 'غير معروف'} (${latestVersion ?? '-'})',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              const Text(
                'يرجى تحديث التطبيق للحصول على آخر الميزات والتحسينات',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            if (!mandatory)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'لاحقاً',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            TextButton(
              onPressed: () async {
                if (downloadUrl != null && downloadUrl.isNotEmpty) {
                  final uri = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
                if (!mandatory && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'تحديث الآن',
                style: TextStyle(color: ThemeConstants.accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
