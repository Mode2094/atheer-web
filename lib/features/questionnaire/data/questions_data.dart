import 'package:perfume/features/questionnaire/models/question_model.dart';

class QuestionsData {
  static List<QuestionModel> getQuestions() {
    return [
      // Big Five - Openness (الانفتاح)
      const QuestionModel(
        id: 'q1',
        textKey: 'question1',
        category: 'personality',
        trait: 'openness',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),
      const QuestionModel(
        id: 'q2',
        textKey: 'question2',
        category: 'sensory',
        trait: 'openness',
        weight: 1.5, // Higher weight because it directly affects perfume taste
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Big Five - Extraversion (الانبساط)
      const QuestionModel(
        id: 'q3',
        textKey: 'question3',
        category: 'personality',
        trait: 'extraversion',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),
      const QuestionModel(
        id: 'q4',
        textKey: 'question4',
        category: 'sensory',
        trait: 'extraversion',
        weight: 1.5,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Big Five - Neuroticism (الحساسية)
      const QuestionModel(
        id: 'q5',
        textKey: 'question5',
        category: 'personality',
        trait: 'neuroticism',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),
      const QuestionModel(
        id: 'q6',
        textKey: 'question6',
        category: 'sensory',
        trait: 'neuroticism',
        weight: 1.5,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Sensory - Freshness
      const QuestionModel(
        id: 'q7',
        textKey: 'question7',
        category: 'sensory',
        trait: 'freshness',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Sensory - Sweetness
      const QuestionModel(
        id: 'q8',
        textKey: 'question8',
        category: 'sensory',
        trait: 'sweetness',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Sensory - Warmth
      const QuestionModel(
        id: 'q9',
        textKey: 'question9',
        category: 'sensory',
        trait: 'warmth',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Sensory - Intensity
      const QuestionModel(
        id: 'q10',
        textKey: 'question10',
        category: 'sensory',
        trait: 'intensity',
        weight: 1.0,
        options: ['answer_yes', 'answer_sometimes', 'answer_no'],
      ),

      // Usage style
      const QuestionModel(
        id: 'q11',
        textKey: 'question11',
        category: 'context',
        trait: 'usagePreference',
        weight: 1.2,
        options: ['usage_daily', 'usage_work', 'usage_events', 'usage_evening'],
      ),

      // Projection
      const QuestionModel(
        id: 'q12',
        textKey: 'question12',
        category: 'context',
        trait: 'projectionPreference',
        weight: 1.5,
        options: ['answer_yes', 'answer_medium', 'answer_no'],
      ),

      // Longevity
      const QuestionModel(
        id: 'q13',
        textKey: 'question13',
        category: 'context',
        trait: 'longevityPreference',
        weight: 1.5,
        options: ['answer_yes', 'answer_medium', 'answer_no'],
      ),

      // Desired impression
      const QuestionModel(
        id: 'q14',
        textKey: 'question14',
        category: 'context',
        trait: 'impressionPreference',
        weight: 1.3,
        options: [
          'impression_luxurious',
          'impression_charming',
          'impression_elegant',
          'impression_calm',
        ],
      ),

      // Luxury affinity
      const QuestionModel(
        id: 'q15',
        textKey: 'question15',
        category: 'context',
        trait: 'luxuryPreference',
        weight: 1.4,
        options: ['answer_yes', 'answer_medium', 'answer_no'],
      ),
    ];
  }

  // Convert answer option to a normalized value from 0.0 to 1.0.
  static double optionToValue(String option) {
    switch (option) {
      case 'نعم':
      case 'Yes':
      case 'answer_yes':
        return 1.0;
      case 'أحياناً':
      case 'Sometimes':
      case 'answer_sometimes':
      case 'متوسط':
      case 'Medium':
      case 'answer_medium':
      case 'عمل':
      case 'usage_work':
        return 0.5;
      case 'لا':
      case 'No':
      case 'answer_no':
        return 0.0;
      case 'يومي':
      case 'usage_daily':
        return 0.3;
      case 'مناسبات':
      case 'usage_events':
        return 0.8;
      case 'مساء':
      case 'usage_evening':
        return 1.0;
      case 'فاخر':
      case 'impression_luxurious':
        return 1.0;
      case 'جذاب':
      case 'impression_charming':
        return 0.8;
      case 'أنيق':
      case 'impression_elegant':
        return 0.6;
      case 'هادئ':
      case 'impression_calm':
        return 0.3;
      default:
        return 0.5;
    }
  }
}
