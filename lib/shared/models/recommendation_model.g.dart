// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationModel _$RecommendationModelFromJson(Map<String, dynamic> json) =>
    _RecommendationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      perfumeId: json['perfumeId'] as String? ?? '',
      perfumeName: json['perfumeName'] as String? ?? '',
      perfumeFamily: json['perfumeFamily'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      wasEegUsed: json['wasEegUsed'] as bool? ?? false,
      createdAt: json['createdAt'],
    );

Map<String, dynamic> _$RecommendationModelToJson(
  _RecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'storeId': instance.storeId,
  'perfumeId': instance.perfumeId,
  'perfumeName': instance.perfumeName,
  'perfumeFamily': instance.perfumeFamily,
  'reason': instance.reason,
  'confidenceScore': instance.confidenceScore,
  'wasEegUsed': instance.wasEegUsed,
  'createdAt': instance.createdAt,
};
