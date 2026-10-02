import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_model.freezed.dart';
part 'admin_user_model.g.dart';

@freezed
abstract class AdminUserModel with _$AdminUserModel {
  const AdminUserModel._();

  const factory AdminUserModel({
    @Default('') String id,
    @Default('') String username,
    @Default('') String passwordHash,
    @Default('admin') String role,
    @Default(true) bool active,
    @Default('') String name,
    @Default('') String email,
    dynamic createdAt,
    dynamic lastLogin,
  }) = _AdminUserModel;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  static const empty = AdminUserModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}
