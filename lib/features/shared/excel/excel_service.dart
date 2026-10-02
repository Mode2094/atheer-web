import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/features/shared/excel/file_download_stub.dart'
    if (dart.library.html) 'package:perfume/features/shared/excel/file_download_web.dart';
import 'package:perfume/shared/models/perfume_model.dart';

class ExcelImportResult {
  final List<PerfumeModel> perfumes;
  final List<String> errors;

  const ExcelImportResult({required this.perfumes, required this.errors});
}

class ExcelService {
  static const List<String> requiredColumns = [
    'name',
    'brandName',
    'description',
    'genderTarget',
    'family',
    'subFamily',
    'intensityLevel',
    'sweetnessLevel',
    'freshnessLevel',
    'warmthLevel',
    'notes',
    'imageUrl',
    'active',
  ];

  static const List<String> _essentialColumns = ['name', 'brandName', 'family'];

  static const Map<String, String> columnLabels = {
    'name': 'اسم العطر',
    'brandName': 'اسم الماركة',
    'description': 'الوصف',
    'genderTarget': 'الجنس',
    'family': 'العائلة',
    'subFamily': 'العائلة الفرعية',
    'intensityLevel': 'القوة',
    'sweetnessLevel': 'الحلاوة',
    'freshnessLevel': 'الانتعاش',
    'warmthLevel': 'الدفء',
    'notes': 'النوتات',
    'imageUrl': 'رابط الصورة',
    'active': 'نشط',
  };

  static const Map<String, List<String>> _columnAliases = {
    'name': ['perfume', 'perfume name', 'fragrance name', 'اسم', 'العطر'],
    'brandName': [
      'brand',
      'brand name',
      'company',
      'اسم العلامة التجارية',
      'العلامة التجارية',
      'الماركة',
    ],
    'description': ['desc', 'details', 'الوصف الكامل'],
    'genderTarget': ['gender', 'target gender', 'الجنس المستهدف'],
    'family': ['main family', 'fragrance family', 'العائلة العطرية'],
    'subFamily': ['sub family', 'sub-family', 'العائلة الثانوية'],
    'intensityLevel': ['intensity', 'strength', 'القوة العطرية'],
    'sweetnessLevel': ['sweetness', 'sweetness level', 'نسبة الحلاوة'],
    'freshnessLevel': ['freshness', 'freshness level', 'الانتعاش'],
    'warmthLevel': ['warmth', 'temperature', 'الدفء'],
    'notes': ['note', 'notes list', 'مكونات', 'النفحات'],
    'imageUrl': ['image', 'image url', 'image link', 'url', 'رابط', 'صورة'],
    'active': ['is active', 'enabled', 'status', 'فعال'],
  };

  Future<Uint8List> generateTemplate() async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'قالب الرفع') {
      excel.rename(defaultSheet, 'قالب الرفع');
    }

    final inputSheet = excel['قالب الرفع'];
    final referenceSheet = excel['مرجع القيم'];
    inputSheet.isRTL = true;
    referenceSheet.isRTL = true;

    inputSheet.appendRow([TextCellValue('قالب رفع العطور - متوافق مع النظام')]);
    inputSheet.appendRow([
      TextCellValue(
        'املأ الصفوف تحت العناوين مباشرة بدون تعديل أسماء الأعمدة. العائلة الفرعية يجب أن تكون من مرجع القيم.',
      ),
    ]);
    inputSheet.appendRow([TextCellValue('')]);

    final headerRowIndex = inputSheet.maxRows;
    inputSheet.appendRow(
      requiredColumns.map((c) => TextCellValue(columnLabels[c] ?? c)).toList(),
    );

    final sampleRowIndex = inputSheet.maxRows;
    inputSheet.appendRow([
      TextCellValue('سفاري إكستريم'),
      TextCellValue('ديور'),
      TextCellValue('عطر خشبي شرقي بطابع فاخر'),
      TextCellValue('للجنسين'),
      TextCellValue('خشبي'),
      TextCellValue('أخشاب'),
      TextCellValue('معتدل'),
      TextCellValue('حلو'),
      TextCellValue('معتدل'),
      TextCellValue('دافئ'),
      TextCellValue('عنبر, فانيليا, خشب'),
      TextCellValue('https://example.com/perfume.jpg'),
      TextCellValue('true'),
    ]);

    inputSheet.appendRow([TextCellValue('')]);
    inputSheet.appendRow([
      TextCellValue(
        'القيم الأساسية: الجنس (ذكر/أنثى/للجنسين) | العائلة (زهري/شرقي/خشبي/منعش/سرخسي) | نشط (true/false)',
      ),
    ]);
    inputSheet.appendRow([
      TextCellValue(
        'القوة: خفيف/معتدل/قوي | الحلاوة: غير حلو/حلو خفيف/حلو/حلو جداً | الانتعاش: دافئ/معتدل/منعش | الدفء: بارد/محايد/دافئ',
      ),
    ]);
    inputSheet.appendRow([
      TextCellValue(
        'العائلة الفرعية: راجع ورقة "مرجع القيم" لاختيار القيمة المطابقة لكل عائلة.',
      ),
    ]);

    _buildReferenceSheet(referenceSheet);

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A8A'),
      fontColorHex: ExcelColor.white,
    );
    final subtitleStyle = CellStyle(
      bold: true,
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#FDE68A'),
      fontColorHex: ExcelColor.black,
      textWrapping: TextWrapping.WrapText,
    );
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#0F766E'),
      fontColorHex: ExcelColor.white,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );
    final sampleStyle = CellStyle(
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#ECFEFF'),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      textWrapping: TextWrapping.WrapText,
    );
    final notesStyle = CellStyle(
      fontSize: 10,
      bold: true,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: ExcelColor.fromHexString('#FEF3C7'),
      fontColorHex: ExcelColor.fromHexString('#7C2D12'),
    );

    inputSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(
        columnIndex: requiredColumns.length - 1,
        rowIndex: 0,
      ),
    );
    inputSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(
        columnIndex: requiredColumns.length - 1,
        rowIndex: 1,
      ),
    );

    _styleRow(inputSheet, 0, requiredColumns.length, titleStyle);
    _styleRow(inputSheet, 1, requiredColumns.length, subtitleStyle);
    _styleRow(inputSheet, headerRowIndex, requiredColumns.length, headerStyle);
    _styleRow(inputSheet, sampleRowIndex, requiredColumns.length, sampleStyle);

    final notesStart = sampleRowIndex + 2;
    for (var i = 0; i < 3; i++) {
      inputSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: notesStart + i),
        CellIndex.indexByColumnRow(
          columnIndex: requiredColumns.length - 1,
          rowIndex: notesStart + i,
        ),
      );
      _styleRow(inputSheet, notesStart + i, requiredColumns.length, notesStyle);
    }

    inputSheet.setRowHeight(0, 28);
    inputSheet.setRowHeight(1, 40);
    inputSheet.setRowHeight(headerRowIndex, 24);
    inputSheet.setRowHeight(sampleRowIndex, 24);

    for (var i = 0; i < requiredColumns.length; i++) {
      inputSheet.setColumnWidth(i, 24);
    }
    inputSheet.setColumnWidth(2, 30);
    inputSheet.setColumnWidth(10, 28);
    inputSheet.setColumnWidth(11, 36);
    inputSheet.setColumnWidth(12, 12);

    return Uint8List.fromList(excel.encode() ?? <int>[]);
  }

  void _buildReferenceSheet(Sheet sheet) {
    sheet.appendRow([TextCellValue('مرجع القيم المسموحة لملف رفع العطور')]);
    sheet.appendRow([
      TextCellValue(
        'استخدم هذا المرجع لاختيار العائلة الفرعية الصحيحة حسب العائلة.',
      ),
    ]);
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('العائلة'),
      TextCellValue('العائلات الفرعية المسموحة'),
      TextCellValue('ملاحظات'),
    ]);

    final familyRowsStart = sheet.maxRows;
    for (final entry in PerfumeConstants.subFamilies.entries) {
      sheet.appendRow([
        TextCellValue(entry.key),
        TextCellValue(entry.value.join('، ')),
        TextCellValue('اختر قيمة مطابقة تمامًا من هذه القائمة'),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    final levelsTitleRow = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('مرجع المستويات'),
      TextCellValue('القيم المقبولة'),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('الجنس'),
      TextCellValue('ذكر، أنثى، للجنسين'),
      TextCellValue('يمكن أيضًا: male/female/unisex'),
    ]);
    sheet.appendRow([
      TextCellValue('القوة'),
      TextCellValue('خفيف، معتدل، قوي'),
      TextCellValue('يمكن أيضًا: light/medium/strong'),
    ]);
    sheet.appendRow([
      TextCellValue('الحلاوة'),
      TextCellValue('غير حلو، حلو خفيف، حلو، حلو جداً'),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('الانتعاش'),
      TextCellValue('دافئ، معتدل، منعش'),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('الدفء'),
      TextCellValue('بارد، محايد، دافئ'),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('نشط'),
      TextCellValue('true/false'),
      TextCellValue('يمكن أيضًا: yes/no, نعم/لا'),
    ]);

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#7C3AED'),
      fontColorHex: ExcelColor.white,
    );
    final subtitleStyle = CellStyle(
      bold: true,
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#DDD6FE'),
      fontColorHex: ExcelColor.fromHexString('#4C1D95'),
      textWrapping: TextWrapping.WrapText,
    );
    final sectionHeaderStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1D4ED8'),
      fontColorHex: ExcelColor.white,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );
    final rowStyle = CellStyle(
      textWrapping: TextWrapping.WrapText,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      backgroundColorHex: ExcelColor.fromHexString('#F8FAFC'),
    );
    final levelsTitleStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#0F766E'),
      fontColorHex: ExcelColor.white,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1),
    );

    _styleRow(sheet, 0, 3, titleStyle);
    _styleRow(sheet, 1, 3, subtitleStyle);
    _styleRow(sheet, 3, 3, sectionHeaderStyle);

    final familyCount = PerfumeConstants.subFamilies.length;
    for (
      var row = familyRowsStart;
      row < familyRowsStart + familyCount;
      row++
    ) {
      _styleRow(sheet, row, 3, rowStyle);
    }

    _styleRow(sheet, levelsTitleRow, 3, levelsTitleStyle);
    for (var row = levelsTitleRow + 1; row <= levelsTitleRow + 6; row++) {
      _styleRow(sheet, row, 3, rowStyle);
    }

    sheet.setRowHeight(0, 28);
    sheet.setRowHeight(1, 34);
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 52);
    sheet.setColumnWidth(2, 34);
  }

  void _styleRow(Sheet sheet, int rowIndex, int columnCount, CellStyle style) {
    for (var col = 0; col < columnCount; col++) {
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: col,
                  rowIndex: rowIndex,
                ),
              )
              .cellStyle =
          style;
    }
  }

  Future<String?> saveTemplateToFile() async {
    final data = await generateTemplate();
    if (kIsWeb) {
      await downloadBytes(data, 'perfume_template.xlsx');
      return 'perfume_template.xlsx';
    }
    return FilePicker.platform.saveFile(
      dialogTitle: 'حفظ نموذج العطور',
      fileName: 'perfume_template.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: data,
    );
  }

  static Future<PlatformFile?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    return result?.files.single;
  }

  Future<ExcelImportResult> readPerfumesFromExcel({
    required Uint8List fileBytes,
    required String storeId,
  }) async {
    if (storeId.trim().isEmpty) {
      throw ArgumentError('storeId is required.');
    }

    final excel = Excel.decodeBytes(fileBytes);
    final perfumes = <PerfumeModel>[];
    final errors = <String>[];

    for (final tableName in excel.tables.keys) {
      final sheet = excel.tables[tableName];
      if (sheet == null) continue;

      final headerRowIndex = _findHeaderRowIndex(sheet);
      if (headerRowIndex == -1) {
        errors.add(
          'لم يتم العثور على صف عناوين صالح في ورقة: $tableName. تأكد من وجود أعمدة: ${columnLabels['name']}، ${columnLabels['brandName']}، ${columnLabels['family']}.',
        );
        continue;
      }

      final headerKeys = _extractHeaderKeys(sheet.rows[headerRowIndex]);
      final missingEssential = _essentialColumns
          .where((key) => !headerKeys.contains(key))
          .toList();
      if (missingEssential.isNotEmpty) {
        final missingLabels = missingEssential
            .map((e) => columnLabels[e] ?? e)
            .join('، ');
        errors.add('الورقة $tableName: أعمدة أساسية مفقودة: $missingLabels');
        continue;
      }

      for (
        var rowIndex = headerRowIndex + 1;
        rowIndex < sheet.rows.length;
        rowIndex++
      ) {
        final row = sheet.rows[rowIndex];
        final data = _extractRowData(row, headerKeys);

        if (_isRowSkippable(data)) {
          continue;
        }

        final rowErrors = _validateRow(data, rowIndex + 1);
        if (rowErrors.isNotEmpty) {
          errors.addAll(rowErrors);
          continue;
        }

        final perfume = _createPerfumeFromMap(data);
        if (perfume == null) {
          errors.add('فشل تحويل الصف ${rowIndex + 1} إلى عطر صالح.');
          continue;
        }
        perfumes.add(perfume);
      }
    }

    return ExcelImportResult(perfumes: perfumes, errors: errors);
  }

  int _findHeaderRowIndex(Sheet sheet) {
    for (var i = 0; i < sheet.rows.length; i++) {
      final headerKeys = _extractHeaderKeys(sheet.rows[i]);
      final recognizedCount = headerKeys.where((e) => e.isNotEmpty).length;
      if (recognizedCount >= 3 &&
          headerKeys.contains('name') &&
          headerKeys.contains('brandName')) {
        return i;
      }
    }
    return -1;
  }

  List<String> _extractHeaderKeys(List<Data?> row) {
    return row.map((c) => _normalizeHeader(_cellToString(c))).toList();
  }

  Map<String, String> _extractRowData(
    List<Data?> row,
    List<String> headerKeys,
  ) {
    final data = <String, String>{};
    for (var colIndex = 0; colIndex < headerKeys.length; colIndex++) {
      final key = headerKeys[colIndex];
      if (key.isEmpty) continue;
      final value = colIndex < row.length ? _cellToString(row[colIndex]) : '';
      data[key] = value.trim();
    }
    return data;
  }

  bool _isRowSkippable(Map<String, String> data) {
    if (data.isEmpty) return true;

    final values = data.values.map((v) => v.trim()).toList();
    if (values.every((v) => v.isEmpty)) return true;

    final onlySeparators = values.every(
      (v) => v.isEmpty || RegExp(r'^[-_]+$').hasMatch(v),
    );
    if (onlySeparators) return true;

    final name = data['name'] ?? '';
    final brandName = data['brandName'] ?? '';
    if (_looksLikeHeaderValue(name, 'name') &&
        _looksLikeHeaderValue(brandName, 'brandName')) {
      return true;
    }

    final hasAnyEssentialValue =
        (data['name'] ?? '').isNotEmpty ||
        (data['brandName'] ?? '').isNotEmpty ||
        (data['family'] ?? '').isNotEmpty;

    return !hasAnyEssentialValue;
  }

  bool _looksLikeHeaderValue(String rawValue, String key) {
    final normalizedValue = _normalizeToken(rawValue);
    if (normalizedValue.isEmpty) return false;

    final aliases = <String>{
      key,
      columnLabels[key] ?? '',
      ...(_columnAliases[key] ?? const <String>[]),
    };

    for (final alias in aliases) {
      if (_normalizeToken(alias) == normalizedValue) {
        return true;
      }
    }
    return false;
  }

  List<String> _validateRow(Map<String, String> data, int rowNumber) {
    final errors = <String>[];
    if ((data['name'] ?? '').isEmpty) {
      errors.add('الصف $rowNumber: اسم العطر مطلوب.');
    }
    if ((data['brandName'] ?? '').isEmpty) {
      errors.add('الصف $rowNumber: اسم الماركة مطلوب.');
    }
    if (_mapFamily(data['family']).isEmpty) {
      errors.add('الصف $rowNumber: العائلة العطرية غير صحيحة.');
    }
    return errors;
  }

  PerfumeModel? _createPerfumeFromMap(Map<String, String> data) {
    try {
      final family = _mapFamily(data['family']);
      if (family.isEmpty) return null;

      final subFamily = _resolveSubFamily(family, data['subFamily']);
      final brandName = data['brandName']?.trim() ?? '';
      final notes = _parseNotes(data['notes']);

      return PerfumeModel(
        name: data['name']?.trim() ?? '',
        brandId: brandName,
        brandName: brandName,
        description: data['description']?.trim() ?? '',
        genderTarget: _validateGenderTarget(data['genderTarget']),
        family: family,
        subFamily: subFamily,
        intensityLevel: _validateIntensity(data['intensityLevel']),
        sweetnessLevel: _validateSweetness(data['sweetnessLevel']),
        freshnessLevel: _validateFreshness(data['freshnessLevel']),
        warmthLevel: _validateWarmth(data['warmthLevel']),
        notes: notes,
        imageUrl: data['imageUrl']?.trim() ?? '',
        active: _parseBoolean(data['active']),
      );
    } catch (e) {
      debugPrint('Error building perfume from excel row: $e');
      return null;
    }
  }

  String _resolveSubFamily(String family, String? requested) {
    final list = PerfumeConstants.subFamilies[family] ?? const <String>[];
    if (list.isEmpty) return requested?.trim() ?? '';

    final requestedValue = requested?.trim() ?? '';
    if (requestedValue.isEmpty) return list.first;

    if (list.contains(requestedValue)) return requestedValue;

    final normalizedRequested = _normalizeToken(requestedValue);
    for (final candidate in list) {
      if (_normalizeToken(candidate) == normalizedRequested) {
        return candidate;
      }
    }
    return list.first;
  }

  String _normalizeHeader(String rawHeader) {
    final normalized = _normalizeToken(rawHeader);
    if (normalized.isEmpty) return '';

    for (final key in requiredColumns) {
      final aliases = <String>{
        key,
        columnLabels[key] ?? '',
        ...(_columnAliases[key] ?? const <String>[]),
      };
      for (final alias in aliases) {
        if (_normalizeToken(alias) == normalized) {
          return key;
        }
      }
    }
    return '';
  }

  String _normalizeToken(String input) {
    var value = input.toLowerCase().trim();
    if (value.isEmpty) return '';

    value = value
        .replaceAll('\u200f', '')
        .replaceAll('\u200e', '')
        .replaceAll('\ufeff', '')
        .replaceAll('\u00a0', ' ');

    value = value
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    value = value.replaceAll(RegExp(r'[\u064b-\u065f\u0670\u0640]'), '');
    value = value.replaceAll(RegExp(r'[()\[\]{}\-_/\\|,:;.!?]'), ' ');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    return value;
  }

  String _cellToString(Data? cell) {
    final dynamic value = cell?.value;
    if (value == null) return '';

    try {
      final dynamic raw = value.value;
      if (raw != null) return raw.toString();
    } catch (_) {}

    return value.toString();
  }

  String _validateGenderTarget(String? value) {
    final raw = _normalizeToken(value ?? '');
    if (raw.contains('male') || raw.contains('ذكر') || raw == 'رجل') {
      return AppConstants.genderMale;
    }
    if (raw.contains('female') || raw.contains('انث') || raw == 'امراه') {
      return AppConstants.genderFemale;
    }
    return AppConstants.genderUnisex;
  }

  String _mapFamily(String? value) {
    final raw = _normalizeToken(value ?? '');
    if (raw.isEmpty) return '';

    const familyMap = {
      'fresh': 'منعش',
      'floral': 'زهري',
      'oriental': 'شرقي',
      'woody': 'خشبي',
      'fern': 'سرخسي',
      'fougere': 'سرخسي',
      'منعش': 'منعش',
      'زهري': 'زهري',
      'شرقي': 'شرقي',
      'خشبي': 'خشبي',
      'سرخسي': 'سرخسي',
    };

    final mapped = familyMap[raw];
    if (mapped != null && PerfumeConstants.mainFamilies.contains(mapped)) {
      return mapped;
    }
    return '';
  }

  String _validateIntensity(String? value) {
    final raw = _normalizeToken(value ?? '');

    if (raw.isEmpty) return PerfumeConstants.intensityOptions[1];
    if (raw.contains('خفيف') || raw == 'light' || raw == 'low') {
      return PerfumeConstants.intensityOptions[0];
    }
    if (raw.contains('قوي') || raw == 'strong' || raw == 'high') {
      return PerfumeConstants.intensityOptions[2];
    }

    return PerfumeConstants.intensityOptions[1];
  }

  String _validateSweetness(String? value) {
    final raw = _normalizeToken(value ?? '');

    if (raw.isEmpty) return PerfumeConstants.sweetnessOptions[2];
    if (raw == 'غير حلو' ||
        raw == 'not sweet' ||
        raw == 'unsweet' ||
        raw == 'unsweetened') {
      return PerfumeConstants.sweetnessOptions[0];
    }
    if (raw.contains('خفيف') ||
        raw == 'light sweet' ||
        raw == 'slightly sweet') {
      return PerfumeConstants.sweetnessOptions[1];
    }
    if (raw.contains('جدا') || raw == 'very sweet' || raw == 'strong sweet') {
      return PerfumeConstants.sweetnessOptions[3];
    }
    if (raw.contains('حلو') || raw == 'sweet') {
      return PerfumeConstants.sweetnessOptions[2];
    }

    for (final option in PerfumeConstants.sweetnessOptions) {
      if (_normalizeToken(option) == raw) return option;
    }

    return PerfumeConstants.sweetnessOptions[2];
  }

  String _validateFreshness(String? value) {
    final raw = _normalizeToken(value ?? '');

    if (raw.isEmpty) return PerfumeConstants.freshnessOptions[1];
    if (raw == 'دافي' || raw == 'warm' || raw == 'low') {
      return PerfumeConstants.freshnessOptions[0];
    }
    if (raw == 'منعش' || raw == 'fresh' || raw == 'cool' || raw == 'high') {
      return PerfumeConstants.freshnessOptions[2];
    }

    for (final option in PerfumeConstants.freshnessOptions) {
      if (_normalizeToken(option) == raw) return option;
    }

    return PerfumeConstants.freshnessOptions[1];
  }

  String _validateWarmth(String? value) {
    final raw = _normalizeToken(value ?? '');

    if (raw.isEmpty) return PerfumeConstants.warmthOptions[1];
    if (raw == 'بارد' || raw == 'cool' || raw == 'cold') {
      return PerfumeConstants.warmthOptions[0];
    }
    if (raw == 'دافي' || raw == 'warm' || raw == 'hot') {
      return PerfumeConstants.warmthOptions[2];
    }

    for (final option in PerfumeConstants.warmthOptions) {
      if (_normalizeToken(option) == raw) return option;
    }

    return PerfumeConstants.warmthOptions[1];
  }

  List<String> _parseNotes(String? value) {
    if (value == null || value.trim().isEmpty) return const <String>[];
    return value
        .split(RegExp(r'[,،;|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _parseBoolean(String? value) {
    final raw = _normalizeToken(value ?? '');
    if (raw.isEmpty) return true;
    return raw == 'true' ||
        raw == '1' ||
        raw == 'نعم' ||
        raw == 'yes' ||
        raw == 'active' ||
        raw == 'enabled';
  }
}
