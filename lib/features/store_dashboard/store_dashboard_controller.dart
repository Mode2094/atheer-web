import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/stores/store_service.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/store_model.dart';

class StoreDashboardController extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  bool _isLoading = false;
  StoreModel? _store;
  List<PerfumeModel> _perfumes = [];
  String? _error;
  String? _storeId;

  bool get isLoading => _isLoading;
  StoreModel? get store => _store;
  List<PerfumeModel> get perfumes => _perfumes;
  String? get error => _error;
  bool get hasStore => _store != null;

  void setStoreId(String id) {
    _storeId = id;
  }

  Future<bool> loadStoreData({required String storeId}) async {
    _setLoading(true);
    _error = null;
    _storeId = storeId;

    try {
      _store = await _storeService.getStoreById(storeId);
      if (_store == null) {
        _error = StringHelper.tr('store_not_found');
        _setLoading(false);
        return false;
      }

      await _loadPerfumes();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> _loadPerfumes() async {
    if (_storeId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection)
          .doc(_storeId)
          .collection(AppConstants.perfumesCollection)
          .get();

      _perfumes = snapshot.docs.map((doc) {
        return PerfumeModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addPerfume(PerfumeModel perfume) async {
    if (_storeId == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection)
          .doc(_storeId)
          .collection(AppConstants.perfumesCollection)
          .add(perfume.toJson()..remove('id'));

      await _loadPerfumes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePerfume(PerfumeModel perfume) async {
    if (_storeId == null || perfume.id.isEmpty) return false;

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection)
          .doc(_storeId)
          .collection(AppConstants.perfumesCollection)
          .doc(perfume.id)
          .update(perfume.toJson()..remove('id'));

      await _loadPerfumes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePerfume(String perfumeId) async {
    if (_storeId == null || perfumeId.isEmpty) return false;

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection)
          .doc(_storeId)
          .collection(AppConstants.perfumesCollection)
          .doc(perfumeId)
          .delete();

      await _loadPerfumes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStore(StoreModel updatedStore) async {
    if (_storeId == null) return false;

    try {
      final success = await _storeService.updateStore(updatedStore);
      if (!success) {
        _error = StringHelper.tr('update_failed');
        notifyListeners();
        return false;
      }
      _store = updatedStore;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
