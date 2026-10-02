import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'eeg_result_model.freezed.dart';
part 'eeg_result_model.g.dart';

@freezed
abstract class EEGResultModel with _$EEGResultModel {
  const EEGResultModel._();

  const factory EEGResultModel({
    @Default('') String id,
    @Default('') String userId,
    @Default('') String storeId,
    @Default('') String perfumeId,
    @Default('') String perfumeName,
    @Default(0.0) double relaxation,
    @Default(0.0) double attention,
    @Default(0.0) double engagement,
    @Default(0.0) double excitement,
    @Default(0.0) double stress,
    @Default(0.0) double interest,
    @Default(<String, dynamic>{}) Map<String, dynamic> rawData,
    dynamic createdAt,
  }) = _EEGResultModel;

  factory EEGResultModel.fromJson(Map<String, dynamic> json) =>
      _$EEGResultModelFromJson(json);

  static const empty = EEGResultModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}

extension EEGResultModelFirestoreX on EEGResultModel {
  Map<String, dynamic> toFirestoreJson() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] ??= FieldValue.serverTimestamp();
    return json;
  }
}
