// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    _QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      textKey: json['textKey'] as String? ?? '',
      category: json['category'] as String,
      trait: json['trait'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.5,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$QuestionModelToJson(_QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'textKey': instance.textKey,
      'category': instance.category,
      'trait': instance.trait,
      'weight': instance.weight,
      'options': instance.options,
    };
