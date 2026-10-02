// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eeg_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EEGResultModel _$EEGResultModelFromJson(Map<String, dynamic> json) =>
    _EEGResultModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      perfumeId: json['perfumeId'] as String? ?? '',
      perfumeName: json['perfumeName'] as String? ?? '',
      relaxation: (json['relaxation'] as num?)?.toDouble() ?? 0.0,
      attention: (json['attention'] as num?)?.toDouble() ?? 0.0,
      engagement: (json['engagement'] as num?)?.toDouble() ?? 0.0,
      excitement: (json['excitement'] as num?)?.toDouble() ?? 0.0,
      stress: (json['stress'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interest'] as num?)?.toDouble() ?? 0.0,
      rawData:
          json['rawData'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      createdAt: json['createdAt'],
    );

Map<String, dynamic> _$EEGResultModelToJson(_EEGResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'storeId': instance.storeId,
      'perfumeId': instance.perfumeId,
      'perfumeName': instance.perfumeName,
      'relaxation': instance.relaxation,
      'attention': instance.attention,
      'engagement': instance.engagement,
      'excitement': instance.excitement,
      'stress': instance.stress,
      'interest': instance.interest,
      'rawData': instance.rawData,
      'createdAt': instance.createdAt,
    };
