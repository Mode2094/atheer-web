import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupService {
  static final SetupService _instance = SetupService._internal();
  factory SetupService() => _instance;
  SetupService._internal();

  // New standardized keys.
  static const String _storeIdKey = AppConstants.storeIdKey;
  static const String _setupCompleteKey = AppConstants.setupCompleteKey;
  static const String _lastUpdateCheckKey = AppConstants.lastUpdateCheckKey;

  // Legacy keys kept for backward compatibility with existing installs.
  static const String _legacyStoreIdKey = 'device_store_id';
  static const String _legacySetupCompleteKey = 'is_setup_complete';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Store ID is persisted and migrated from legacy keys if needed.
  static Future<void> saveStoreId(String storeId) async {
    final prefs = await _prefs();
    await prefs.setString(_storeIdKey, storeId);
    await prefs.setBool(_setupCompleteKey, true);
    await prefs.remove(_legacyStoreIdKey);
    await prefs.remove(_legacySetupCompleteKey);
    AppLogger.i('Store ID persisted: $storeId');
  }

  static Future<String?> getStoreId() async {
    final prefs = await _prefs();
    final current = prefs.getString(_storeIdKey);
    if (current != null && current.isNotEmpty) {
      return current;
    }

    // Migrate legacy key seamlessly.
    final legacy = prefs.getString(_legacyStoreIdKey);
    if (legacy != null && legacy.isNotEmpty) {
      await prefs.setString(_storeIdKey, legacy);
      await prefs.remove(_legacyStoreIdKey);
      AppLogger.w('Migrated legacy store ID key to standardized key');
      return legacy;
    }
    return null;
  }

  static Future<bool> isSetupComplete() async {
    final prefs = await _prefs();
    final current = prefs.getBool(_setupCompleteKey);
    if (current != null) return current;

    final legacy = prefs.getBool(_legacySetupCompleteKey);
    if (legacy != null) {
      await prefs.setBool(_setupCompleteKey, legacy);
      await prefs.remove(_legacySetupCompleteKey);
      AppLogger.w('Migrated legacy setup completion key');
      return legacy;
    }
    return false;
  }

  static Future<void> setSetupComplete() async {
    final prefs = await _prefs();
    await prefs.setBool(_setupCompleteKey, true);
    await prefs.remove(_legacySetupCompleteKey);
    AppLogger.i('Setup marked as complete');
  }

  static Future<void> saveLastUpdateCheck() async {
    final prefs = await _prefs();
    await prefs.setInt(
      _lastUpdateCheckKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<int?> getLastUpdateCheckMs() async {
    final prefs = await _prefs();
    return prefs.getInt(_lastUpdateCheckKey);
  }

  // Update check runs every 24h by default.
  static Future<bool> shouldCheckForUpdate() async {
    final prefs = await _prefs();
    final lastCheck = prefs.getInt(_lastUpdateCheckKey);
    if (lastCheck == null) return true;

    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final elapsed = DateTime.now().difference(lastCheckTime);
    return elapsed.inHours >= AppConstants.updateCheckIntervalHours;
  }

  // Persist critical setup/session markers before OTA install.
  static Future<void> persistCriticalSetupSnapshot() async {
    final prefs = await _prefs();
    final storeId = await getStoreId();
    final setupComplete = await isSetupComplete();
    final userId = prefs.getString(AppConstants.userIdKey);

    if (storeId != null) {
      await prefs.setString(_storeIdKey, storeId);
    }
    await prefs.setBool(_setupCompleteKey, setupComplete);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(AppConstants.userIdKey, userId);
    }
    AppLogger.i('Critical setup/session snapshot persisted before OTA install');
  }

  // Kept only for factory reset/admin use, never during OTA.
  static Future<void> resetSetup() async {
    final prefs = await _prefs();
    await prefs.remove(_storeIdKey);
    await prefs.remove(_setupCompleteKey);
    await prefs.remove(_legacyStoreIdKey);
    await prefs.remove(_legacySetupCompleteKey);
  }
}
