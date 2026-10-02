import 'package:flutter/foundation.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/services/firebase_service.dart';
import 'package:perfume/shared/models/store_model.dart';

class StoreService {
  final FirebaseService _firebaseService = FirebaseService();

  // Get store by ID
  Future<StoreModel?> getStoreById(String storeId) async {
    try {
      final doc = await _firebaseService.storesRef.doc(storeId).get();
      if (doc.exists) {
        return StoreModel.fromJson(doc.data()!..['id'] = doc.id);
      }
    } catch (e) {
      debugPrint(
        'Error getting store from ${AppConstants.storesCollection}: $e',
      );
    }
    return null;
  }

  Future<StoreModel?> getStoreByUniqueCode(String uniqueCode) async {
    try {
      debugPrint('🔍 Searching for store with uniqueCode: $uniqueCode');
      final querySnapshot = await _firebaseService.storesRef
          .where('uniqueCode', isEqualTo: uniqueCode)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      debugPrint('📄 Found ${querySnapshot.docs.length} stores with this code');

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        debugPrint('📊 Store found: ${doc.data()}');
        return StoreModel.fromJson({...doc.data(), 'id': doc.id});
      }
    } catch (e) {
      debugPrint('❌ Error getting store by uniqueCode: $e');
    }
    return null;
  }

  // Get all active stores (for admin)
  Future<List<StoreModel>> getAllStores() async {
    try {
      final snapshot = await _firebaseService.storesRef.get();
      return snapshot.docs.map((doc) {
        return StoreModel.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    } catch (e) {
      debugPrint(
        'Error getting stores from ${AppConstants.storesCollection}: $e',
      );
      return [];
    }
  }

  // Create new store (admin only)
  Future<String?> createStore(StoreModel store) async {
    try {
      final docRef = await _firebaseService.storesRef.add(
        store.toFirestoreJson(),
      );
      return docRef.id;
    } catch (e) {
      debugPrint(
        'Error creating store in ${AppConstants.storesCollection}: $e',
      );
      return null;
    }
  }

  // Update store
  Future<bool> updateStore(StoreModel store) async {
    try {
      await _firebaseService.storesRef
          .doc(store.id)
          .update(store.toFirestoreJson());
      return true;
    } catch (e) {
      debugPrint(
        'Error updating store in ${AppConstants.storesCollection}: $e',
      );
      return false;
    }
  }

  // Deactivate store (soft delete)
  Future<bool> deactivateStore(String storeId) async {
    try {
      await _firebaseService.storesRef.doc(storeId).update({'active': false});
      return true;
    } catch (e) {
      debugPrint(
        'Error deactivating store in ${AppConstants.storesCollection}: $e',
      );
      return false;
    }
  }

  // Get current device store ID (from local storage)
  String? getCurrentStoreId() {
    // سنضيف SharedPreferences لاحقاً
    return null;
  }

  // Set current device store ID
  Future<void> setCurrentStoreId(String storeId) async {
    // سنضيف SharedPreferences لاحقاً
  }
}
