import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_user_model.freezed.dart';
part 'store_user_model.g.dart';

@freezed
abstract class StoreUserModel with _$StoreUserModel {
  const StoreUserModel._();

  const factory StoreUserModel({
    @Default('') String id,
    @Default('') String username,
    @Default('') String passwordHash,
    @Default('') String storeId,
    @Default('') String storeName,
    @Default('store') String role,
    @Default(true) bool active,
    dynamic createdAt,
    dynamic lastLogin,
  }) = _StoreUserModel;

  factory StoreUserModel.fromJson(Map<String, dynamic> json) =>
      _$StoreUserModelFromJson(json);

  static const empty = StoreUserModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}
