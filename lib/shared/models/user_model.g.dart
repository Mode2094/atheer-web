// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  country: json['country'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  personalityProfile:
      json['personalityProfile'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
  pastRecommendations:
      (json['pastRecommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: json['createdAt'],
  lastActive: json['lastActive'],
  updatedAt: json['updatedAt'],
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'country': instance.country,
      'gender': instance.gender,
      'personalityProfile': instance.personalityProfile,
      'pastRecommendations': instance.pastRecommendations,
      'createdAt': instance.createdAt,
      'lastActive': instance.lastActive,
      'updatedAt': instance.updatedAt,
    };
