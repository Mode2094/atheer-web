import 'package:flutter/material.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/core/localization/locale_controller.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final isArabic = controller.locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withValues(alpha: 0.25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.loc.selectLanguage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.setLocale('ar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isArabic
                        ? Colors.amber
                        : Colors.grey.shade800,
                    foregroundColor: isArabic ? Colors.black : Colors.white,
                  ),
                  child: Text(context.loc.languageArabic),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.setLocale('en'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isArabic
                        ? Colors.amber
                        : Colors.grey.shade800,
                    foregroundColor: !isArabic ? Colors.black : Colors.white,
                  ),
                  child: Text(context.loc.languageEnglish),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
