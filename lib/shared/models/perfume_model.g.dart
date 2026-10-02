// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfume_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerfumeModel _$PerfumeModelFromJson(
  Map<String, dynamic> json,
) => _PerfumeModel(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  brandId: json['brandId'] as String? ?? '',
  brandName: json['brandName'] as String? ?? '',
  description: json['description'] as String? ?? '',
  genderTarget: json['genderTarget'] as String? ?? '',
  family: json['family'] as String? ?? '',
  subFamily: json['subFamily'] as String? ?? '',
  intensityLevel: json['intensityLevel'] as String? ?? 'معتدل',
  sweetnessLevel: json['sweetnessLevel'] as String? ?? 'حلو',
  freshnessLevel: json['freshnessLevel'] as String? ?? 'معتدل',
  warmthLevel: json['warmthLevel'] as String? ?? 'محايد',
  projection: (json['projection'] as num?)?.toDouble() ?? 0.5,
  longevity: (json['longevity'] as num?)?.toDouble() ?? 0.5,
  luxuryScore: (json['luxuryScore'] as num?)?.toDouble() ?? 0.5,
  notes:
      (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  topNotes:
      (json['topNotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  heartNotes:
      (json['heartNotes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  baseNotes:
      (json['baseNotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  imageUrl: json['imageUrl'] as String? ?? '',
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$PerfumeModelToJson(_PerfumeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
      'description': instance.description,
      'genderTarget': instance.genderTarget,
      'family': instance.family,
      'subFamily': instance.subFamily,
      'intensityLevel': instance.intensityLevel,
      'sweetnessLevel': instance.sweetnessLevel,
      'freshnessLevel': instance.freshnessLevel,
      'warmthLevel': instance.warmthLevel,
      'projection': instance.projection,
      'longevity': instance.longevity,
      'luxuryScore': instance.luxuryScore,
      'notes': instance.notes,
      'topNotes': instance.topNotes,
      'heartNotes': instance.heartNotes,
      'baseNotes': instance.baseNotes,
      'imageUrl': instance.imageUrl,
      'active': instance.active,
    };
