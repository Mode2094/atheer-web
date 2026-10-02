import 'package:flutter/material.dart';
import 'package:perfume/features/admin/users/users_service.dart';
import 'package:perfume/shared/models/recommendation_model.dart';
import 'package:perfume/shared/models/user_model.dart';

class UsersController extends ChangeNotifier {
  final UsersService _service = UsersService();

  bool _isLoading = false;
  List<UserModel> _users = [];
  UserModel? _selectedUser;
  List<RecommendationModel> _userRecommendations = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;
  List<RecommendationModel> get userRecommendations => _userRecommendations;
  String? get error => _error;

  Future<void> loadAllUsers() async {
    _setLoading(true);
    _error = null;

    try {
      _users = await _service.getAllUsers();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<void> selectUser(UserModel user) async {
    _setLoading(true);
    _error = null;
    _selectedUser = user;

    try {
      final result = await _service.getUserWithRecommendations(user.id);
      _selectedUser = result['user'] as UserModel?;
      _userRecommendations = (result['recommendations'] as List<dynamic>)
          .whereType<RecommendationModel>()
          .toList();
    } catch (e) {
      _error = e.toString();
      _selectedUser = user;
      _userRecommendations = [];
    }

    _setLoading(false);
  }

  void clearSelection() {
    _selectedUser = null;
    _userRecommendations = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
