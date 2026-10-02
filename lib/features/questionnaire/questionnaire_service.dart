import 'package:perfume/features/questionnaire/data/questions_data.dart';
import 'package:perfume/features/questionnaire/models/answer_model.dart';
import 'package:perfume/features/questionnaire/models/question_model.dart';
import 'package:perfume/shared/models/personality_profile_model.dart';

class QuestionnaireService {
  // Get all questions
  List<QuestionModel> getQuestions() {
    return QuestionsData.getQuestions();
  }

  // Calculate personality profile from answers
  PersonalityProfileModel calculateProfile(List<AnswerModel> answers) {
    final Map<String, double> traitSums = {};
    final Map<String, double> traitWeights = {};
    final questions = getQuestions();
    final questionById = <String, QuestionModel>{
      for (final question in questions) question.id: question,
    };

    for (final answer in answers) {
      final question = questionById[answer.questionId] ?? QuestionModel.empty;
      final weight = question.weight;
      traitSums[answer.trait] =
          (traitSums[answer.trait] ?? 0) + (answer.value * weight);
      traitWeights[answer.trait] = (traitWeights[answer.trait] ?? 0) + weight;
    }

    return PersonalityProfileModel(
      openness: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'openness',
        0.5,
      ),
      extraversion: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'extraversion',
        0.5,
      ),
      agreeableness: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'agreeableness',
        0.5,
      ),
      conscientiousness: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'conscientiousness',
        0.5,
      ),
      neuroticism: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'neuroticism',
        0.5,
      ),
      freshnessPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'freshness',
        0.5,
      ),
      sweetnessPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'sweetness',
        0.5,
      ),
      warmthPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'warmth',
        0.5,
      ),
      intensityPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'intensity',
        0.5,
      ),
      usagePreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'usagePreference',
        0.5,
      ),
      projectionPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'projectionPreference',
        0.5,
      ),
      longevityPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'longevityPreference',
        0.5,
      ),
      impressionPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'impressionPreference',
        0.5,
      ),
      luxuryPreference: _getWeightedTraitValue(
        traitSums,
        traitWeights,
        'luxuryPreference',
        0.5,
      ),
    );
  }

  double _getWeightedTraitValue(
    Map<String, double> sums,
    Map<String, double> weights,
    String trait,
    double defaultValue,
  ) {
    final sum = sums[trait];
    final weight = weights[trait];
    if (sum != null && weight != null && weight > 0) {
      return sum / weight;
    }
    return defaultValue;
  }
}
