import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/store_model.dart';

class StoreCacheService {
  static final StoreCacheService _instance = StoreCacheService._internal();
  factory StoreCacheService() => _instance;
  StoreCacheService._internal();

  final Map<String, CachedStore> _storeCache = {};
  final Map<String, CachedPerfumes> _perfumeCache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  void cacheStore(StoreModel store) {
    _storeCache[store.id] = CachedStore(
      store: store,
      timestamp: DateTime.now(),
    );
  }

  StoreModel? getCachedStore(String storeId) {
    final cached = _storeCache[storeId];
    if (cached == null) return null;
    if (DateTime.now().difference(cached.timestamp) >= _cacheDuration) {
      _storeCache.remove(storeId);
      return null;
    }
    return cached.store;
  }

  void cachePerfumes(String storeId, List<PerfumeModel> perfumes) {
    _perfumeCache[storeId] = CachedPerfumes(
      perfumes: perfumes,
      timestamp: DateTime.now(),
    );
  }

  List<PerfumeModel>? getCachedPerfumes(String storeId) {
    final cached = _perfumeCache[storeId];
    if (cached == null) return null;
    if (DateTime.now().difference(cached.timestamp) >= _cacheDuration) {
      _perfumeCache.remove(storeId);
      return null;
    }
    return cached.perfumes;
  }

  void invalidateStore(String storeId) {
    _storeCache.remove(storeId);
  }

  void invalidatePerfumes(String storeId) {
    _perfumeCache.remove(storeId);
  }

  void clearCache() {
    _storeCache.clear();
    _perfumeCache.clear();
  }
}

class CachedStore {
  final StoreModel store;
  final DateTime timestamp;

  CachedStore({
    required this.store,
    required this.timestamp,
  });
}

class CachedPerfumes {
  final List<PerfumeModel> perfumes;
  final DateTime timestamp;

  CachedPerfumes({
    required this.perfumes,
    required this.timestamp,
  });
}
