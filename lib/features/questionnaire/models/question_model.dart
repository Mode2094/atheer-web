import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
abstract class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    @Default('') String text,
    @Default('') String textKey,
    required String category, // 'personality' or 'sensory'
    required String trait, // 'openness', 'extraversion', 'freshness', etc.
    @Default(0.5) double weight, // importance of this question
    @Default(<String>[]) List<String> options,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  static const empty = QuestionModel(id: '', category: '', trait: '');
}
