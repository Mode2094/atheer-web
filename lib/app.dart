import 'package:flutter/material.dart';
import 'package:perfume/l10n/app_localizations.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/localization/locale_controller.dart';
import 'package:perfume/features/admin/admin_screen.dart';
import 'package:perfume/features/admin/reports/advanced_reports_screen.dart';
import 'package:perfume/features/admin/reports/reports_screen.dart';
import 'package:perfume/features/admin/screens/telemetry_dashboard.dart';
import 'package:perfume/features/admin/users/users_list_screen.dart';
import 'package:perfume/features/admin/screens/store_users_screen.dart';
import 'package:perfume/features/admin_auth/admin_login_screen.dart';
import 'package:perfume/features/auth/profile_input_screen.dart';
import 'package:perfume/features/init/init_screen.dart';
import 'package:perfume/features/questionnaire/question_screen.dart';
import 'package:perfume/features/recommendation/recommendation_screen.dart';
import 'package:perfume/features/store_auth/store_login_screen.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_screen.dart';
import 'package:perfume/features/update/update_screen.dart';
import 'package:perfume/features/setup/setup_screen.dart';
import 'package:perfume/features/splash/splash_screen.dart';
import 'package:perfume/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class NeuroScentAdvisorApp extends StatelessWidget {
  const NeuroScentAdvisorApp({super.key});

  static const Color _primaryColor = Color(0xFF1A1A2E);
  static const Color _accentColor = Color(0xFFC6A43F);

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();

    const colorScheme = ColorScheme.dark(
      primary: _primaryColor,
      secondary: _accentColor,
      surface: Color(0xFF111120),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _accentColor,
      ),
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      locale: localeController.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: '/',
      builder: (context, child) {
        return GradientBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final page = child ?? const SizedBox.shrink();
              const minUsableWidth = 320.0;

              Widget content = page;
              if (constraints.maxWidth < minUsableWidth) {
                content = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: minUsableWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: SizedBox(width: minUsableWidth, child: page),
                  ),
                );
              }

              return content;
            },
          ),
        );
      },
      routes: {
        '/': (context) => const InitScreen(),
        '/setup': (context) => const SetupScreen(),
        '/splash': (context) => const SplashScreen(),
        '/profile-input': (context) => const ProfileInputScreen(),
        '/questionnaire': (context) => const QuestionScreen(),
        '/recommendation': (context) => const RecommendationScreen(),
        '/store-login': (context) => const StoreLoginScreen(),
        '/store-dashboard': (context) => const StoreDashboardScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminScreen(),
        '/admin/reports': (context) => const ReportsScreen(),
        '/admin/advanced-reports': (context) => const AdvancedReportsScreen(),
        '/admin/telemetry': (context) => const TelemetryDashboard(),
        '/admin/users': (context) => const UsersListScreen(),
        '/admin/store-users': (context) => const StoreUsersScreen(),
        '/admin/update': (context) => const UpdateScreen(),
      },
    );
  }
}
