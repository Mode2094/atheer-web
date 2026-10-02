import 'package:perfume/core/utils/string_helper.dart';

class PerfumeLocalizationHelper {
  static String displayValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return value;

    switch (normalized) {
      case 'male':
      case 'ذكر':
        return StringHelper.tr('gender_male');
      case 'female':
      case 'أنثى':
        return StringHelper.tr('gender_female');
      case 'unisex':
      case 'للجنسين':
        return StringHelper.tr('gender_unisex');
      case 'floral':
      case 'زهري':
        return StringHelper.tr('family_floral');
      case 'oriental':
      case 'شرقي':
        return StringHelper.tr('family_oriental');
      case 'woody':
      case 'خشبي':
        return StringHelper.tr('family_woody');
      case 'fresh':
      case 'منعش':
        return StringHelper.tr('family_fresh');
      case 'fern':
      case 'سرخسي':
        return StringHelper.tr('family_fern');
      case 'خفيف':
      case 'light':
        return StringHelper.tr('intensity_light');
      case 'معتدل':
      case 'medium':
      case 'moderate':
        return StringHelper.tr('intensity_medium');
      case 'قوي':
      case 'strong':
        return StringHelper.tr('intensity_strong');
      case 'غير حلو':
      case 'not sweet':
        return StringHelper.tr('sweetness_not_sweet');
      case 'حلو خفيف':
      case 'light sweet':
        return StringHelper.tr('sweetness_light_sweet');
      case 'حلو':
      case 'sweet':
        return StringHelper.tr('sweetness_sweet');
      case 'حلو جداً':
      case 'very sweet':
        return StringHelper.tr('sweetness_very_sweet');
      case 'بارد':
      case 'cool':
        return StringHelper.tr('warmth_cool');
      case 'محايد':
      case 'neutral':
        return StringHelper.tr('warmth_neutral');
      case 'دافئ':
      case 'warm':
        return StringHelper.tr('warmth_warm');
      case 'زهري ناعم':
        return StringHelper.tr('subfamily_floral_soft');
      case 'زهري شرقي':
        return StringHelper.tr('subfamily_floral_oriental');
      case 'شرقي ناعم':
        return StringHelper.tr('subfamily_oriental_soft');
      case 'شرقي خشبي':
        return StringHelper.tr('subfamily_oriental_woody');
      case 'أخشاب':
        return StringHelper.tr('subfamily_woods');
      case 'طحلبي خشبي':
        return StringHelper.tr('subfamily_mossy_woody');
      case 'خشبي جاف':
        return StringHelper.tr('subfamily_dry_woody');
      case 'حمضيات':
        return StringHelper.tr('subfamily_citrus');
      case 'فواكه':
        return StringHelper.tr('subfamily_fruity');
      case 'أخضر':
        return StringHelper.tr('subfamily_green');
      case 'مائي':
        return StringHelper.tr('subfamily_aquatic');
      default:
        return value;
    }
  }
}
