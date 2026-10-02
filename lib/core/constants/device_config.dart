import 'package:perfume/core/services/setup_service.dart';

class DeviceConfig {
  static Future<String?> getCurrentStoreId() async {
    return SetupService.getStoreId();
  }

  static Future<bool> hasValidStore() async {
    final storeId = await getCurrentStoreId();
    return storeId != null && storeId.isNotEmpty;
  }
}
