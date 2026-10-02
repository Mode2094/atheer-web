import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/questionnaire/questionnaire_controller.dart';
import 'package:perfume/features/recommendation/recommendation_controller.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:provider/provider.dart';

class SessionService {
  static Timer? _inactivityTimer;
  static const int _timeoutSeconds = 60;

  static void startInactivityTimer(BuildContext context) {
    _cancelTimer();
    _inactivityTimer = Timer(const Duration(seconds: _timeoutSeconds), () {
      unawaited(_logoutAndReset(context));
    });
  }

  static void resetInactivityTimer(BuildContext context) {
    _cancelTimer();
    startInactivityTimer(context);
  }

  static void stopInactivityTimer() {
    _cancelTimer();
  }

  static Future<void> logoutAndReset(BuildContext context) {
    return _logoutAndReset(context);
  }

  static void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  static Future<void> _logoutAndReset(BuildContext context) async {
    _cancelTimer();
    if (!context.mounted) return;

    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final storeController = Provider.of<StoreController>(
        context,
        listen: false,
      );
      final questionnaireController = Provider.of<QuestionnaireController>(
        context,
        listen: false,
      );
      final recommendationController = Provider.of<RecommendationController>(
        context,
        listen: false,
      );

      await authController.signOut();
      storeController.clearCurrentStore();
      questionnaireController.reset();
      recommendationController.clear();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    }
  }
}
