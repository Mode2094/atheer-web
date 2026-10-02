import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static final PrefsHelper _instance = PrefsHelper._internal();
  factory PrefsHelper() => _instance;
  PrefsHelper._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _safePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('PrefsHelper not initialized. Call init() first.');
    }
    return prefs;
  }

  Future<bool> setString(String key, String value) async {
    return _safePrefs.setString(key, value);
  }

  String? getString(String key) => _safePrefs.getString(key);

  Future<bool> setBool(String key, bool value) async {
    return _safePrefs.setBool(key, value);
  }

  bool? getBool(String key) => _safePrefs.getBool(key);

  Future<bool> setInt(String key, int value) async {
    return _safePrefs.setInt(key, value);
  }

  int? getInt(String key) => _safePrefs.getInt(key);

  Future<bool> remove(String key) async => _safePrefs.remove(key);

  Future<bool> clear() async => _safePrefs.clear();
}
