import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfume/app.dart';
import 'package:perfume/core/localization/locale_controller.dart';
import 'package:perfume/core/services/firebase_service.dart';
import 'package:perfume/core/utils/logger.dart';
import 'package:perfume/core/utils/prefs_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/admin/reports/advanced_reports_controller.dart';
import 'package:perfume/features/admin/reports/reports_controller.dart';
import 'package:perfume/features/admin/users/users_controller.dart';
import 'package:perfume/features/admin_auth/admin_auth_controller.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/eeg/eeg_controller.dart';
import 'package:perfume/features/questionnaire/questionnaire_controller.dart';
import 'package:perfume/features/recommendation/recommendation_controller.dart';
import 'package:perfume/features/store_auth/store_auth_controller.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_controller.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:perfume/features/update/update_controller.dart';
import 'package:perfume/features/updater/updater_controller.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsHelper = PrefsHelper();
  await prefsHelper.init();

  final firebaseService = FirebaseService();
  final firebaseReady = await firebaseService.initialize();
  if (!firebaseReady) {
    AppLogger.w(
      'App started without Firebase readiness; OTA and cloud features will retry later',
    );
  }

  final updaterController = UpdaterController();
  await updaterController.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => StoreController()),
        ChangeNotifierProvider(create: (_) => QuestionnaireController()),
        ChangeNotifierProvider(create: (_) => RecommendationController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => AdvancedReportsController()),
        ChangeNotifierProvider(create: (_) => ReportsController()),
        ChangeNotifierProvider(create: (_) => UsersController()),
        ChangeNotifierProvider(create: (_) => AdminAuthController()),
        ChangeNotifierProvider(create: (_) => StoreAuthController()),
        ChangeNotifierProvider(create: (_) => StoreDashboardController()),
        ChangeNotifierProvider(create: (_) => EEGController()),
        ChangeNotifierProvider(create: (_) => UpdateController()),
        ChangeNotifierProvider<UpdaterController>.value(
          value: updaterController,
        ),
      ],
      child: const NeuroScentAdvisorApp(),
    ),
  );

  // Kiosk mode: run OTA flow automatically in background (no user action).
  unawaited(updaterController.startAutoUpdateFlow());
}