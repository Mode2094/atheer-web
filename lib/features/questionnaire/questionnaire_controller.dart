import 'package:flutter/material.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/questionnaire/models/answer_model.dart';
import 'package:perfume/features/questionnaire/models/question_model.dart';
import 'package:perfume/features/questionnaire/questionnaire_service.dart';
import 'package:perfume/shared/models/personality_profile_model.dart';

class QuestionnaireController extends ChangeNotifier {
  final QuestionnaireService _service = QuestionnaireService();

  // State
  bool _isLoading = false;
  List<QuestionModel> _questions = [];
  final Map<String, double> _answers = {}; // questionId -> value
  int _currentQuestionIndex = 0;
  PersonalityProfileModel? _calculatedProfile;

  // Getters
  bool get isLoading => _isLoading;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;
  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex == _questions.length - 1;
  bool get isComplete => _calculatedProfile != null;
  PersonalityProfileModel? get calculatedProfile => _calculatedProfile;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;

  // Initialize questionnaire
  void initialize() {
    _questions = _service.getQuestions();
    _currentQuestionIndex = 0;
    _answers.clear();
    _calculatedProfile = null;
    notifyListeners();
  }

  // Answer current question
  void answerCurrentQuestion(double value) {
    if (currentQuestion == null) return;

    _answers[currentQuestion!.id] = value;

    if (isLastQuestion) {
      // Calculate profile
      calculateProfile();
    } else {
      // Move to next question
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Go to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Calculate personality profile
  void calculateProfile() {
    _isLoading = true;
    notifyListeners();

    // Convert answers map to list of AnswerModel
    final answerList = _answers.entries.map((entry) {
      // Find question to get trait
      final question = _questions.firstWhere((q) => q.id == entry.key);
      return AnswerModel(
        questionId: entry.key,
        trait: question.trait,
        value: entry.value,
      );
    }).toList();

    // Calculate profile
    _calculatedProfile = _service.calculateProfile(answerList);
    _isLoading = false;
    notifyListeners();
  }

  // Reset questionnaire
  void reset() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _calculatedProfile = null;
    notifyListeners();
  }

  // حفظ ملف الشخصية في Firebase
  Future<void> saveProfileToFirebase({
    required AuthController authController,
    required String name,
    required String gender,
    String? phone,
    String? country,
  }) async {
    if (_calculatedProfile == null) return;
    await authController.updateProfile(
      name: name,
      gender: gender,
      phone: phone,
      country: country,
      personalityProfile: _calculatedProfile!.toJson(),
    );
  }

  // إضافة التوصية للسجل
  Future<void> saveRecommendationToHistory({
    required AuthController authController,
    required String perfumeId,
  }) async {
    await authController.addToHistory(perfumeId);
  }
}
