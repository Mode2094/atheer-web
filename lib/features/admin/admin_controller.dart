import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:perfume/features/auth/auth_service.dart';
import 'package:perfume/features/store_auth/store_auth_service.dart';
import 'package:perfume/features/stores/store_service.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/store_model.dart';

class AdminController extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  final AuthService _authService = AuthService();

  // State
  bool _isLoading = false;
  List<StoreModel> _stores = [];
  List<PerfumeModel> _currentStorePerfumes = [];
  int _totalPerfumesCount = 0;
  StoreModel? _selectedStore;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<StoreModel> get stores => _stores;
  List<PerfumeModel> get currentStorePerfumes => _currentStorePerfumes;
  int get totalPerfumesCount => _totalPerfumesCount;
  StoreModel? get selectedStore => _selectedStore;
  String? get error => _error;
  bool get hasAdminSession => _authService.isLoggedIn;

  // Load all stores
  Future<void> loadStores() async {
    _setLoading(true);
    _error = null;
    try {
      _stores = await _storeService.getAllStores();
      await _loadTotalPerfumesCount();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading stores: $e');
    }
    _setLoading(false);
  }

  Future<void> _loadTotalPerfumesCount() async {
    if (_stores.isEmpty) {
      _totalPerfumesCount = 0;
      return;
    }

    try {
      final futures = _stores.map((store) {
        return FirebaseFirestore.instance
            .collection('stores')
            .doc(store.id)
            .collection('perfumes')
            .get();
      }).toList();

      final snapshots = await Future.wait(futures);
      _totalPerfumesCount = snapshots.fold<int>(
        0,
        (acc, snap) => acc + snap.docs.length,
      );
    } catch (e) {
      debugPrint('Error loading total perfumes count: $e');
      _totalPerfumesCount = 0;
    }
  }

  // Select store
  Future<void> selectStore(StoreModel store) async {
    _selectedStore = store;
    await loadStorePerfumes(store.id);
    notifyListeners();
  }

  // Load perfumes for selected store
  Future<void> loadStorePerfumes(String storeId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('perfumes')
          .get();

      _currentStorePerfumes = snapshot.docs.map((doc) {
        return PerfumeModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading store perfumes: $e');
    }
    notifyListeners();
  }

  // Add new perfume
  Future<bool> addPerfume(PerfumeModel perfume, String storeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('perfumes')
          .add(perfume.toJson()..remove('id'));

      await loadStorePerfumes(storeId);
      await _loadTotalPerfumesCount();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding perfume: $e');
      return false;
    }
  }

  // Update perfume
  Future<bool> updatePerfume(PerfumeModel perfume, String storeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('perfumes')
          .doc(perfume.id)
          .update(perfume.toJson()..remove('id'));

      await loadStorePerfumes(storeId);
      await _loadTotalPerfumesCount();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating perfume: $e');
      return false;
    }
  }

  // Delete perfume
  Future<bool> deletePerfume(String perfumeId, String storeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('perfumes')
          .doc(perfumeId)
          .delete();

      await loadStorePerfumes(storeId);
      await _loadTotalPerfumesCount();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting perfume: $e');
      return false;
    }
  }

  // Create new store
  Future<bool> createStore(StoreModel store) async {
    try {
      final uniqueCode = _generateUniqueCode();

      await FirebaseFirestore.instance.collection('stores').add({
        ...store.toFirestoreJson(),
        'uniqueCode': uniqueCode,
      });

      await loadStores();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating store: $e');
      return false;
    }
  }

  // Update store
  Future<bool> updateStore(StoreModel store) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(store.id)
          .update(store.toFirestoreJson());

      if (_selectedStore?.id == store.id) {
        _selectedStore = store;
      }
      await loadStores();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating store: $e');
      return false;
    }
  }

  // Activate/deactivate store
  Future<bool> toggleStoreActive(String storeId, bool active) async {
    try {
      await FirebaseFirestore.instance.collection('stores').doc(storeId).update(
        {'active': active},
      );

      await loadStores();
      if (_selectedStore?.id == storeId) {
        _selectedStore = await _storeService.getStoreById(storeId);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error toggling store: $e');
      return false;
    }
  }

  // Delete store
  Future<bool> deleteStore(String storeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .delete();

      if (_selectedStore?.id == storeId) {
        _selectedStore = null;
        _currentStorePerfumes = [];
      }
      await loadStores();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting store: $e');
      return false;
    }
  }

  // Generate random unique code
  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> createStoreUser({
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  }) async {
    try {
      final storeAuthService = StoreAuthService();
      final success = await storeAuthService.createStoreUser(
        username: username,
        password: password,
        storeId: storeId,
        storeName: storeName,
      );
      if (!success) {
        _error = 'فشل إنشاء المستخدم أو اسم المستخدم مستخدم مسبقاً';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllStoreUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('store_users')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'username': data['username'],
          'storeId': data['storeId'],
          'storeName': data['storeName'],
          'active': data['active'],
          'createdAt': data['createdAt'],
          'lastLogin': data['lastLogin'],
        };
      }).toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<bool> toggleStoreUserStatus(String userId, bool active) async {
    try {
      await FirebaseFirestore.instance
          .collection('store_users')
          .doc(userId)
          .update({'active': active});
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteStoreUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('store_users')
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
