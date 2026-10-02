import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/localization/locale_controller.dart';

class StringHelper {
  static String tr(String key) {
    if (LocaleController.currentCode == 'en') {
      return AppConstants.englishTexts[key] ??
          AppConstants.arabicTexts[key] ??
          key;
    }
    return AppConstants.arabicTexts[key] ??
        AppConstants.englishTexts[key] ??
        key;
  }
}
