class PerfumeConstants {
  // العائلات الرئيسية
  static const List<String> mainFamilies = [
    'زهري',
    'شرقي',
    'خشبي',
    'منعش',
    'سرخسي',
  ];

  // العائلات الفرعية حسب العائلة الرئيسية
  static const Map<String, List<String>> subFamilies = {
    'زهري': ['زهري', 'زهري ناعم', 'زهري شرقي'],
    'شرقي': ['شرقي ناعم', 'شرقي', 'شرقي خشبي'],
    'خشبي': ['أخشاب', 'طحلبي خشبي', 'خشبي جاف'],
    'منعش': ['حمضيات', 'فواكه', 'أخضر', 'مائي'],
    'سرخسي': ['سرخسي'],
  };

  // مستويات القوة
  static const Map<String, double> intensityLevels = {
    'خفيف': 0.3,
    'معتدل': 0.6,
    'قوي': 0.9,
  };
  static const List<String> intensityOptions = ['خفيف', 'معتدل', 'قوي'];

  // مستويات الحلاوة
  static const Map<String, double> sweetnessLevels = {
    'غير حلو': 0.2,
    'حلو خفيف': 0.4,
    'حلو': 0.6,
    'حلو جداً': 0.8,
  };
  static const List<String> sweetnessOptions = [
    'غير حلو',
    'حلو خفيف',
    'حلو',
    'حلو جداً',
  ];

  // مستويات الانتعاش
  static const Map<String, double> freshnessLevels = {
    'دافئ': 0.2,
    'معتدل': 0.5,
    'منعش': 0.8,
  };
  static const List<String> freshnessOptions = ['دافئ', 'معتدل', 'منعش'];

  // مستويات الدفء
  static const Map<String, double> warmthLevels = {
    'بارد': 0.2,
    'محايد': 0.5,
    'دافئ': 0.8,
  };
  static const List<String> warmthOptions = ['بارد', 'محايد', 'دافئ'];

  static double getDefaultIntensity() => intensityLevels['معتدل']!;
  static double getDefaultSweetness() => sweetnessLevels['حلو']!;
  static double getDefaultFreshness() => freshnessLevels['معتدل']!;
  static double getDefaultWarmth() => warmthLevels['محايد']!;
}
