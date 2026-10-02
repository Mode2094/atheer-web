// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personality_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalityProfileModel _$PersonalityProfileModelFromJson(
  Map<String, dynamic> json,
) => _PersonalityProfileModel(
  openness: (json['openness'] as num?)?.toDouble() ?? 0.5,
  conscientiousness: (json['conscientiousness'] as num?)?.toDouble() ?? 0.5,
  extraversion: (json['extraversion'] as num?)?.toDouble() ?? 0.5,
  agreeableness: (json['agreeableness'] as num?)?.toDouble() ?? 0.5,
  neuroticism: (json['neuroticism'] as num?)?.toDouble() ?? 0.5,
  freshnessPreference: (json['freshnessPreference'] as num?)?.toDouble() ?? 0.5,
  sweetnessPreference: (json['sweetnessPreference'] as num?)?.toDouble() ?? 0.5,
  intensityPreference: (json['intensityPreference'] as num?)?.toDouble() ?? 0.5,
  warmthPreference: (json['warmthPreference'] as num?)?.toDouble() ?? 0.5,
  usagePreference: (json['usagePreference'] as num?)?.toDouble() ?? 0.5,
  projectionPreference:
      (json['projectionPreference'] as num?)?.toDouble() ?? 0.5,
  longevityPreference: (json['longevityPreference'] as num?)?.toDouble() ?? 0.5,
  impressionPreference:
      (json['impressionPreference'] as num?)?.toDouble() ?? 0.5,
  luxuryPreference: (json['luxuryPreference'] as num?)?.toDouble() ?? 0.5,
  dominantFamily: json['dominantFamily'] as String? ?? '',
);

Map<String, dynamic> _$PersonalityProfileModelToJson(
  _PersonalityProfileModel instance,
) => <String, dynamic>{
  'openness': instance.openness,
  'conscientiousness': instance.conscientiousness,
  'extraversion': instance.extraversion,
  'agreeableness': instance.agreeableness,
  'neuroticism': instance.neuroticism,
  'freshnessPreference': instance.freshnessPreference,
  'sweetnessPreference': instance.sweetnessPreference,
  'intensityPreference': instance.intensityPreference,
  'warmthPreference': instance.warmthPreference,
  'usagePreference': instance.usagePreference,
  'projectionPreference': instance.projectionPreference,
  'longevityPreference': instance.longevityPreference,
  'impressionPreference': instance.impressionPreference,
  'luxuryPreference': instance.luxuryPreference,
  'dominantFamily': instance.dominantFamily,
};
