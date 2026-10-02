import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/device_config.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/questionnaire/data/questions_data.dart';
import 'package:perfume/features/questionnaire/models/question_model.dart';
import 'package:perfume/features/questionnaire/questionnaire_controller.dart';
import 'package:perfume/features/shared/widgets/inactivity_detector.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  String? _nameFromArgs;
  String? _genderFromArgs;
  String? _phoneFromArgs;
  bool _argsLoaded = false;
  bool _savingProfile = false;
  int? _lastAnimatedQuestionIndex;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Animation controllers للشاشة النهائية
  late final AnimationController _brainExplosionController;
  late final AnimationController _neuralPulseController;
  late final AnimationController _particleController;
  late final AnimationController _glowController;
  late final AnimationController _rotateController;

  late final Animation<double> _explosionAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _rotateAnimation;

  final List<NeuralParticle> _particles = [];
  final Random _random = Random();
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // تهيئة AnimationControllers للشاشة النهائية
    _brainExplosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _neuralPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _explosionAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _brainExplosionController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _neuralPulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionnaireController>(context, listen: false).initialize();
      if (mounted) {
        _fadeController.forward();
      }
    });

    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(
        NeuralParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 4 + 2,
          speedX: _random.nextDouble() * 0.02 - 0.01,
          speedY: _random.nextDouble() * 0.02 - 0.01,
          color: [
            ThemeConstants.accentColor,
            Colors.blue,
            Colors.purple,
            Colors.pink,
          ][_random.nextInt(4)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _brainExplosionController.dispose();
    _neuralPulseController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _nameFromArgs = args['name']?.toString();
      _genderFromArgs = args['gender']?.toString();
      _phoneFromArgs = args['phone']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B0B1A), Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Consumer<QuestionnaireController>(
                builder: (context, controller, child) {
                  if (controller.isComplete) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _brainExplosionController.forward();
                    });
                    return _buildCompleteScreen(context, controller);
                  }

                  final question = controller.currentQuestion;
                  if (question == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ThemeConstants.accentColor,
                      ),
                    );
                  }

                  if (_lastAnimatedQuestionIndex !=
                      controller.currentQuestionIndex) {
                    _lastAnimatedQuestionIndex =
                        controller.currentQuestionIndex;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _fadeController
                        ..reset()
                        ..forward();
                    });
                  }

                  return _buildQuestionContent(context, controller, question);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
    BuildContext context,
    QuestionnaireController controller,
    QuestionModel question,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const pagePadding = 24.0;
        final availableWidth = (constraints.maxWidth - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final availableHeight = (constraints.maxHeight - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final contentWidth = constraints.maxWidth > 900
            ? 760.0
            : (constraints.maxWidth - 48).clamp(260.0, 760.0).toDouble();

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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressIndicator(controller),
                      const SizedBox(height: 40),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            context.localizeQuestion(
                              question.textKey.isNotEmpty
                                  ? question.textKey
                                  : question.text,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ...question.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildOptionButton(
                            context,
                            context.localizeOption(option),
                            () {
                              _fadeController.reverse().then((_) {
                                controller.answerCurrentQuestion(
                                  QuestionsData.optionToValue(option),
                                );
                              });
                            },
                          ),
                        ),
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

  Widget _buildProgressIndicator(QuestionnaireController controller) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.transparent),
              strokeWidth: 8,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: controller.progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(
                    ThemeConstants.accentColor,
                  ),
                  strokeWidth: 8,
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${controller.currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                context.loc.questionCounterOf(controller.questions.length),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.accentColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(20),
                splashColor: ThemeConstants.accentColor.withValues(alpha: 0.2),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteScreen(
    BuildContext context,
    QuestionnaireController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const pagePadding = 24.0;
        final availableWidth = (constraints.maxWidth - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final availableHeight = (constraints.maxHeight - (pagePadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final contentWidth = (constraints.maxWidth - 48)
            .clamp(260.0, 560.0)
            .toDouble();

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(pagePadding),
            child: SizedBox(
              width: availableWidth,
              height: availableHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: contentWidth,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _brainExplosionController,
                      _neuralPulseController,
                      _particleController,
                      _glowController,
                      _rotateController,
                    ]),
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // رسم الجسيمات العصبية
                          CustomPaint(
                            size: Size(contentWidth, 500),
                            painter: NeuralParticlesPainter(
                              particles: _particles,
                              progress: _particleController.value,
                              explosionProgress:
                                  _brainExplosionController.value,
                            ),
                          ),

                          // حلقات متحدة المركز دوارة
                          ...List.generate(4, (index) {
                            return Positioned(
                              top: 100 + index * 20,
                              child: Transform.rotate(
                                angle:
                                    _rotateAnimation.value + (index * pi / 4),
                                child: Container(
                                  width: 200 + index * 40,
                                  height: 200 + index * 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ThemeConstants.accentColor
                                          .withValues(
                                            alpha: 0.1 - index * 0.02,
                                          ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // المحتوى الرئيسي
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // أيقونة النجاح مع تأثير الانفجار العصبي
                              Transform.scale(
                                scale:
                                    _explosionAnimation.value *
                                    _pulseAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        ThemeConstants.accentColor.withValues(
                                          alpha: 0.8,
                                        ),
                                        ThemeConstants.accentColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        Colors.transparent,
                                      ],
                                      stops: [0.3, 0.7, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConstants.accentColor
                                            .withValues(
                                              alpha: _glowAnimation.value * 0.5,
                                            ),
                                        blurRadius: 40,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // موجات متحركة داخل الأيقونة
                                        ...List.generate(3, (index) {
                                          return Transform.scale(
                                            scale:
                                                1 +
                                                sin(
                                                      _particleController
                                                                  .value *
                                                              pi *
                                                              2 +
                                                          index,
                                                    ) *
                                                    0.1,
                                            child: Container(
                                              width: 80 - index * 20,
                                              height: 80 - index * 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(
                                                        alpha:
                                                            0.3 - index * 0.1,
                                                      ),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // النص الرئيسي مع تأثير توهج
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    ThemeConstants.accentColor,
                                    Colors.white,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(bounds),
                                child: Text(
                                  context.loc.analysisComplete,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: ThemeConstants.accentColor
                                            .withValues(alpha: 0.5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // النص الفرعي
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: ThemeConstants.accentColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  context.loc.preferencesAnalyzed,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 50),

                              // مؤشرات الموجات
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildWaveIndicator('Alpha', Colors.blue),
                                  const SizedBox(width: 20),
                                  _buildWaveIndicator(
                                    'Beta',
                                    ThemeConstants.accentColor,
                                  ),
                                  const SizedBox(width: 20),
                                  _buildWaveIndicator('Gamma', Colors.purple),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // زر التوصية المحسن
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeConstants.accentColor
                                                .withValues(
                                                  alpha:
                                                      _glowAnimation.value *
                                                      0.5,
                                                ),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: AnimatedButton(
                                        text: context.loc.seeRecommendation,
                                        isLoading: _savingProfile,
                                        onPressed: () async {
                                          if (_savingProfile) return;

                                          final authController =
                                              Provider.of<AuthController>(
                                                context,
                                                listen: false,
                                              );

                                          if (!authController.isLoggedIn) {
                                            final loggedIn = await authController
                                                .signInWithPhone(
                                                  _phoneFromArgs
                                                              ?.trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? _phoneFromArgs!.trim()
                                                      : 'guest_${DateTime.now().millisecondsSinceEpoch}',
                                                );
                                            if (!context.mounted) return;
                                            if (!loggedIn) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    authController.error ??
                                                        context.loc.errorTitle,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                          }

                                          final name =
                                              (_nameFromArgs?.trim() ?? '')
                                                  .isNotEmpty
                                              ? _nameFromArgs!.trim()
                                              : '${context.loc.guestPrefix} ${DateTime.now().millisecondsSinceEpoch}';
                                          final gender =
                                              (_genderFromArgs?.trim() ?? '')
                                                  .isNotEmpty
                                              ? _genderFromArgs!.trim()
                                              : AppConstants.genderUnisex;

                                          setState(() => _savingProfile = true);
                                          try {
                                            await controller
                                                .saveProfileToFirebase(
                                                  authController:
                                                      authController,
                                                  name: name,
                                                  gender: gender,
                                                );

                                            final hasValidStore =
                                                await DeviceConfig.hasValidStore();
                                            if (!context.mounted) return;
                                            if (!hasValidStore) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context
                                                        .loc
                                                        .deviceNotConfiguredStore,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            final currentStoreId =
                                                await DeviceConfig.getCurrentStoreId();
                                            if (!context.mounted) return;
                                            if (currentStoreId == null ||
                                                currentStoreId.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context
                                                        .loc
                                                        .deviceNotConfiguredStore,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            final storeController =
                                                Provider.of<StoreController>(
                                                  context,
                                                  listen: false,
                                                );
                                            final storeLoaded =
                                                await storeController.loadStore(
                                                  currentStoreId,
                                                );

                                            if (!context.mounted) return;
                                            if (!storeLoaded) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    storeController.error ??
                                                        'Failed to load store',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/recommendation',
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                () => _savingProfile = false,
                                              );
                                            }
                                          }
                                        },
                                        width: 240,
                                        height: 60,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveIndicator(String label, Color color) {
    return AnimatedBuilder(
      animation: _neuralPulseController,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 40,
              height: 30,
              child: CustomPaint(
                painter: WavePainter(
                  color: color,
                  progress: _neuralPulseController.value,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

// كلاس الجسيمات العصبية
class NeuralParticle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  Color color;

  NeuralParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

// رسام الجسيمات العصبية
class NeuralParticlesPainter extends CustomPainter {
  final List<NeuralParticle> particles;
  final double progress;
  final double explosionProgress;

  NeuralParticlesPainter({
    required this.particles,
    required this.progress,
    required this.explosionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // تحديث موقع الجسيم بناءً على التقدم
      final x = (particle.x + particle.speedX * progress * 10) * size.width;
      final y = (particle.y + particle.speedY * progress * 10) * size.height;

      // تكبير الجسيمات أثناء الانفجار
      final explodedSize = particle.size * (1 + explosionProgress * 2);

      // رسم الجسيم
      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: 0.4 * (1 - explosionProgress * 0.5),
        )
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

      canvas.drawCircle(Offset(x, y), explodedSize, paint);

      // رسم خطوط ربط بين الجسيمات القريبة
      for (var other in particles) {
        final otherX = (other.x + other.speedX * progress * 10) * size.width;
        final otherY = (other.y + other.speedY * progress * 10) * size.height;
        final dx = (otherX - x).abs();
        final dy = (otherY - y).abs();
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 80) {
          final linePaint = Paint()
            ..color = particle.color.withValues(
              alpha: 0.1 * (1 - distance / 80) * (1 + explosionProgress),
            )
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

          canvas.drawLine(Offset(x, y), Offset(otherX, otherY), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NeuralParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.explosionProgress != explosionProgress;
  }
}

// رسام الموجات المصغر
class WavePainter extends CustomPainter {
  final Color color;
  final double progress;

  WavePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x < size.width; x += 2) {
      final y = centerY + sin(x * 0.3 + progress * 2 * pi) * (size.height / 3);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
