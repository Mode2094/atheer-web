import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/device_config.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/core/models/eeg_result_model.dart';
import 'package:perfume/core/theme/app_theme.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/eeg/eeg_controller.dart';
import 'package:perfume/features/eeg/eeg_visualization_screen.dart';
import 'package:perfume/features/questionnaire/questionnaire_controller.dart';
import 'package:perfume/features/recommendation/recommendation_controller.dart';
import 'package:perfume/features/recommendation/widgets/eeg_test_card.dart';
import 'package:perfume/features/shared/services/session_service.dart';
import 'package:perfume/features/shared/widgets/inactivity_detector.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:perfume/shared/widgets/glowing_button.dart';
import 'package:provider/provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final Map<String, EEGResultModel?> _testResults = {};
  String? _activeTestPerfumeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRecommendation();
    });
  }

  Future<void> _getRecommendation() async {
    final recController = Provider.of<RecommendationController>(
      context,
      listen: false,
    );
    final authController = Provider.of<AuthController>(context, listen: false);
    final questionnaireController = Provider.of<QuestionnaireController>(
      context,
      listen: false,
    );

    if (questionnaireController.calculatedProfile == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/questionnaire');
      return;
    }

    final hasStore = await DeviceConfig.hasValidStore();
    if (!hasStore) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.deviceNotConfiguredStore),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final storeId = await DeviceConfig.getCurrentStoreId();
    if (storeId == null || storeId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.deviceNotConfiguredStore),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await recController.getRecommendation(
      profile: questionnaireController.calculatedProfile!,
      storeId: storeId,
      gender: authController.userProfile?.gender.isNotEmpty == true
          ? authController.userProfile!.gender
          : AppConstants.genderUnisex,
      userId: authController.user?.uid ?? '',
    );

    if (success && mounted) {
      final mainRecommendation =
          recController.recommendation?['mainRecommendation'];
      if (mainRecommendation is Map && mainRecommendation['id'] != null) {
        await authController.addToHistory(mainRecommendation['id'].toString());
      }
    }
  }

  Future<EEGResultModel> _simulateEEGTest(String perfumeId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final random = Random();
    final interest = 0.5 + random.nextDouble() * 0.5;
    final excitement = 0.3 + random.nextDouble() * 0.6;
    final stress = random.nextDouble() * 0.4;
    final engagement = 0.4 + random.nextDouble() * 0.5;
    final attention = 0.5 + random.nextDouble() * 0.5;
    final relaxation = 0.3 + random.nextDouble() * 0.6;

    final overallScore =
        ((interest * 0.4) +
            (excitement * 0.2) +
            ((1 - stress) * 0.2) +
            (relaxation * 0.2)) *
        100;

    return EEGResultModel(
      perfumeId: perfumeId,
      interest: interest,
      excitement: excitement,
      stress: stress,
      engagement: engagement,
      attention: attention,
      relaxation: relaxation,
      rawData: {'simulatedOverallScore': overallScore},
    );
  }

  // عند توفر SDK الحقيقي:
  // Future<EEGResultModel> _realEEGTest(String perfumeId) async { ... }

  Future<void> _startEEGTest(String perfumeId, String perfumeName) async {
    if (_activeTestPerfumeId != null) return;
    setState(() {
      _activeTestPerfumeId = perfumeId;
    });

    var didComplete = false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EEGVisualizationScreen(
          perfumeName: perfumeName,
          onComplete: () {
            didComplete = true;
          },
          onCancel: () {
            didComplete = false;
          },
        ),
      ),
    );

    if (!mounted) return;
    if (didComplete) {
      await _completeEEGTest(perfumeId, perfumeName);
      return;
    }

    setState(() {
      _activeTestPerfumeId = null;
    });
  }

  Future<void> _completeEEGTest(String perfumeId, String perfumeName) async {
    final result = await _simulateEEGTest(perfumeId);
    if (!mounted) return;
    setState(() {
      _testResults[perfumeId] = result;
      _activeTestPerfumeId = null;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final eegController = Provider.of<EEGController>(context, listen: false);
    final storeController = Provider.of<StoreController>(context, listen: false);

    final userId = authController.user?.uid ?? '';
    final storeId =
        storeController.currentStore?.id ??
        await DeviceConfig.getCurrentStoreId() ??
        '';

    if (userId.isEmpty || storeId.isEmpty) {
      return;
    }

    final eegData = <String, dynamic>{
      'relaxation': result.relaxation,
      'attention': result.attention,
      'engagement': result.engagement,
      'excitement': result.excitement,
      'stress': result.stress,
      'interest': result.interest,
    };

    await eegController.saveResult(
      userId: userId,
      storeId: storeId,
      perfumeId: perfumeId,
      perfumeName: perfumeName,
      eegData: eegData,
    );
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.idealPerfume,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () {
                SessionService.logoutAndReset(context);
              },
              icon: const Icon(
                Icons.person_add_alt_1,
                color: ThemeConstants.accentColor,
                size: 30,
              ),
              label: Text(
                context.loc.newCustomer,
                style: TextStyle(
                  color: ThemeConstants.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConstants.accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        body: AnimatedBackground(
          withParticles: true,
          child: SafeArea(
            child: Consumer<RecommendationController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return _buildLoading();
                }
                if (controller.error != null) {
                  return _buildError(controller.error!);
                }
                if (controller.hasRecommendation) {
                  return _buildRecommendation(controller.recommendation!);
                }
                return _buildError(context.loc.noRecommendationsAvailable);
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _extractPerfumes(Map<String, dynamic> data) {
    final list = <Map<String, dynamic>>[];

    final all = data['all'];
    if (all is List) {
      list.addAll(
        all.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }

    if (list.isEmpty) {
      final mainData = data['mainRecommendation'];
      if (mainData is Map) {
        list.add(Map<String, dynamic>.from(mainData));
      }
      final alternatives = (data['alternatives'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      list.addAll(alternatives);
    }

    final unique = <String, Map<String, dynamic>>{};
    for (final perfume in list) {
      final id = perfume['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      unique[id] = perfume;
    }
    return unique.values.toList();
  }

  Widget _buildRecommendation(Map<String, dynamic> data) {
    final allPerfumes = _extractPerfumes(data);
    if (allPerfumes.isEmpty) {
      return _buildError(context.loc.noRecommendationsAvailable);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const pagePadding = 24.0;
        final availableWidth = (constraints.maxWidth - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final availableHeight = (constraints.maxHeight - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final contentWidth = constraints.maxWidth > 1000
            ? 840.0
            : (constraints.maxWidth - 48).clamp(320.0, 840.0).toDouble();

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(pagePadding),
            child: SizedBox(
              width: availableWidth,
              height: availableHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.loc.suggestedPerfumesTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.loc.selectPerfumeForSensorTest,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...allPerfumes.map((perfume) {
                        final perfumeId = perfume['id']?.toString() ?? '';
                        final isTesting = _activeTestPerfumeId == perfumeId;
                        final result = _testResults[perfumeId];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EEGTestCard(
                            perfumeName: perfume['name']?.toString() ?? '',
                            perfumeBrand: perfume['brandName']?.toString() ?? '',
                            perfumeImage: perfume['imageUrl']?.toString() ?? '',
                            onStartTest: perfumeId.isEmpty
                                ? () {}
                                : () => _startEEGTest(
                                    perfumeId,
                                    perfume['name']?.toString() ?? '',
                                  ),
                            isTesting: isTesting,
                            progress: isTesting ? 0.35 : 0,
                            result: result,
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      GlowingButton(
                        text: context.loc.restartTest,
                        icon: Icons.restart_alt,
                        onPressed: () {
                          Provider.of<QuestionnaireController>(
                            context,
                            listen: false,
                          ).reset();
                          Navigator.pushReplacementNamed(context, '/questionnaire');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.goldLight,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldGradient.createShader(bounds),
            child: Text(
              context.loc.findingPerfume,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                context.loc.errorTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              GlowingButton(
                text: context.loc.retry,
                icon: Icons.refresh,
                onPressed: _getRecommendation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
