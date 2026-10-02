import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
abstract class StoreModel with _$StoreModel {
  const StoreModel._();

  const factory StoreModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String logo,
    @Default('') String address,
    @Default('') String phone,
    @Default('') String uniqueCode,
    @Default(true) bool active,
    dynamic createdAt,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  static const empty = StoreModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}

extension StoreModelFirestoreX on StoreModel {
  Map<String, dynamic> toFirestoreJson() {
    final json = toJson();
    json['createdAt'] ??= FieldValue.serverTimestamp();
    return json;
  }
}
