import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String storageKey = 'selected_locale';

  static String _currentCode = 'ar';

  static String get currentCode => _currentCode;

  Locale _locale = const Locale('ar');

  Locale get locale {
    // Keep StringHelper language source always aligned with MaterialApp locale.
    _currentCode = _locale.languageCode;
    return _locale;
  }

  LocaleController() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(storageKey);

      if (code != null) {
        _locale = Locale(code);
        _currentCode = code;
        notifyListeners();
        return;
      }
    } catch (_) {
      // Keep default locale if persistence fails.
    }

    _currentCode = _locale.languageCode;
  }

  Future<void> setLocale(String code) async {
    final previousLocale = _locale.languageCode;
    final previousCode = _currentCode;

    _locale = Locale(code);
    _currentCode = code;

    if (previousLocale != code || previousCode != code) {
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, code);
    } catch (_) {
      // UI already updated; ignore persistence errors.
    }
  }
}
