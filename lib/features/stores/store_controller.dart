import 'package:flutter/material.dart';
import 'package:perfume/features/stores/store_cache_service.dart';
import 'package:perfume/features/stores/store_service.dart';
import 'package:perfume/shared/models/store_model.dart';

class StoreController extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  final StoreCacheService _cacheService = StoreCacheService();

  // State
  bool _isLoading = false;
  StoreModel? _currentStore;
  List<StoreModel> _stores = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  StoreModel? get currentStore => _currentStore;
  List<StoreModel> get stores => _stores;
  String? get error => _error;
  bool get hasCurrentStore =>
      _currentStore != null && _currentStore!.isNotEmpty;

  // Load store by ID
  Future<bool> loadStore(String storeId) async {
    _setLoading(true);
    _error = null;

    try {
      final cachedStore = _cacheService.getCachedStore(storeId);
      if (cachedStore != null) {
        _currentStore = cachedStore;
        _setLoading(false);
        return true;
      }

      final store = await _storeService.getStoreById(storeId);
      if (store != null && store.active) {
        _currentStore = store;
        _cacheService.cacheStore(store);
        _setLoading(false);
        return true;
      } else {
        _error = 'Store not found or inactive';
      }
    } catch (e) {
      _error = 'Error loading store: $e';
    }

    _setLoading(false);
    return false;
  }

  // Validate and set current store
  Future<bool> validateStore(String uniqueCode) async {
    _setLoading(true);
    _error = null;
    try {
      debugPrint('🔍 Validating store with uniqueCode: $uniqueCode');
      final store = await _storeService.getStoreByUniqueCode(uniqueCode);
      if (store != null && store.active) {
        debugPrint('✅ Store found and active: ${store.name}');
        _currentStore = store;
        _setLoading(false);
        return true;
      } else {
        debugPrint('❌ Store not found or inactive');
        _error = 'المتجر غير موجود أو غير نشط';
      }
    } catch (e) {
      debugPrint('❌ Error validating store: $e');
      _error = 'خطأ في التحقق من المتجر';
    }
    _setLoading(false);
    return false;
  }

  // Load all stores (admin)
  Future<void> loadAllStores() async {
    _setLoading(true);
    _stores = await _storeService.getAllStores();
    _setLoading(false);
  }

  // Create new store
  Future<String?> createStore(StoreModel store) async {
    _setLoading(true);
    final id = await _storeService.createStore(store);
    if (id != null) {
      await loadAllStores();
    }
    _setLoading(false);
    return id;
  }

  // Update store
  Future<bool> updateStore(StoreModel store) async {
    _setLoading(true);
    final success = await _storeService.updateStore(store);
    if (success && _currentStore?.id == store.id) {
      _currentStore = store;
      _cacheService.cacheStore(store);
    }
    await loadAllStores();
    _setLoading(false);
    return success;
  }

  // Deactivate store
  Future<bool> deactivateStore(String storeId) async {
    _setLoading(true);
    final success = await _storeService.deactivateStore(storeId);
    if (success && _currentStore?.id == storeId) {
      _currentStore = null;
      _cacheService.invalidateStore(storeId);
      _cacheService.invalidatePerfumes(storeId);
    }
    await loadAllStores();
    _setLoading(false);
    return success;
  }

  // Clear current store
  void clearCurrentStore() {
    _currentStore = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
