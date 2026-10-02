import 'package:freezed_annotation/freezed_annotation.dart';

part 'personality_profile_model.freezed.dart';
part 'personality_profile_model.g.dart';

@freezed
abstract class PersonalityProfileModel with _$PersonalityProfileModel {
  const PersonalityProfileModel._();

  const factory PersonalityProfileModel({
    @Default(0.5) double openness, // Openness to experience
    @Default(0.5) double conscientiousness, // Conscientiousness
    @Default(0.5) double extraversion, // Extraversion
    @Default(0.5) double agreeableness, // Agreeableness
    @Default(0.5) double neuroticism, // Neuroticism (sensitivity)
    @Default(0.5) double freshnessPreference, // Preference for fresh scents
    @Default(0.5) double sweetnessPreference, // Preference for sweet scents
    @Default(0.5) double intensityPreference, // Preference for strong scents
    @Default(0.5) double warmthPreference, // Preference for warm scents
    @Default(0.5) double usagePreference, // Daily/work/events/evening profile
    @Default(0.5)
    double projectionPreference, // How noticeable the scent should be
    @Default(0.5) double longevityPreference, // Preferred lasting power
    @Default(0.5) double impressionPreference, // Desired social impression
    @Default(0.5) double luxuryPreference, // Preference for luxury/rare scents
    @Default('') String dominantFamily, // The matched perfume family
  }) = _PersonalityProfileModel;

  factory PersonalityProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalityProfileModelFromJson(json);

  static const empty = PersonalityProfileModel();

  // Calculate dominant trait
  String get dominantTrait {
    final traits = {
      'openness': openness,
      'conscientiousness': conscientiousness,
      'extraversion': extraversion,
      'agreeableness': agreeableness,
      'neuroticism': neuroticism,
    };
    return traits.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
