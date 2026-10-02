import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:perfume/core/constants/app_constants.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String phone,
    @Default('') String country,
    @Default('') String gender,
    @Default(<String, dynamic>{}) Map<String, dynamic> personalityProfile,
    @Default(<String>[]) List<String> pastRecommendations,
    dynamic createdAt,
    dynamic lastActive,
    dynamic updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Empty user for initial state
  static const empty = UserModel();

  // Check if user is empty
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
  bool get hasValidGender => AppConstants.genderOptions.contains(gender);
}

extension UserModelFirestoreX on UserModel {
  Map<String, dynamic> toFirestoreJson() {
    final json = toJson();
    json['createdAt'] ??= FieldValue.serverTimestamp();
    return json;
  }
}
