import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_model.freezed.dart';
part 'recommendation_model.g.dart';

@freezed
abstract class RecommendationModel with _$RecommendationModel {
  const RecommendationModel._();

  const factory RecommendationModel({
    @Default('') String id,
    @Default('') String userId,
    @Default('') String storeId,
    @Default('') String perfumeId,
    @Default('') String perfumeName,
    @Default('') String perfumeFamily,
    @Default('') String reason, // Why this perfume was recommended
    @Default(0.0) double confidenceScore, // 0.0 to 1.0
    @Default(false) bool wasEegUsed, // Whether EEG data was used
    dynamic createdAt,
  }) = _RecommendationModel;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationModelFromJson(json);

  static const empty = RecommendationModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}

extension RecommendationModelFirestoreX on RecommendationModel {
  Map<String, dynamic> toFirestoreJson() {
    final json = toJson();
    json['createdAt'] ??= FieldValue.serverTimestamp();
    return json;
  }
}
