// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => _AnswerModel(
  questionId: json['questionId'] as String,
  trait: json['trait'] as String,
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$AnswerModelToJson(_AnswerModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'trait': instance.trait,
      'value': instance.value,
    };
