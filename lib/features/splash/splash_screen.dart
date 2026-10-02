import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfume/core/services/setup_service.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/language/widgets/language_switcher.dart';
import 'package:perfume/features/shared/services/session_service.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:perfume/features/update/update_checker.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _brainWaveController;
  late final AnimationController _alphaController;
  late final AnimationController _betaController;
  late final AnimationController _gammaController;
  late final AnimationController _ctaHoverController;
  late final AnimationController _ctaSheenController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // كونترولرات متعددة للحركات المختلفة
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _brainWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _alphaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _betaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _gammaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _ctaHoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _ctaSheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionService.stopInactivityTimer();
      _loadStoreForSplash();
      _checkForAppUpdate();
    });
  }

  Future<void> _loadStoreForSplash() async {
    final storeController = context.read<StoreController>();
    if (storeController.currentStore != null && storeController.hasCurrentStore) {
      return;
    }

    final savedStoreId = await SetupService.getStoreId();
    if (!mounted || savedStoreId == null || savedStoreId.trim().isEmpty) {
      return;
    }

    await storeController.loadStore(savedStoreId.trim());
  }

  Future<void> _checkForAppUpdate() async {
    if (!mounted) return;
    final checker = UpdateChecker();
    await checker.checkForUpdate(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _brainWaveController.dispose();
    _alphaController.dispose();
    _betaController.dispose();
    _gammaController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _ctaHoverController.dispose();
    _ctaSheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final shortestSide = size.shortestSide;
    final isSmallScreen = shortestSide < 380;
    final isMediumScreen = shortestSide >= 380 && shortestSide < 900;
    final isShortScreen = size.height < 820;
    final widthScale = (size.width / 430).clamp(0.68, 1.0);
    final heightScale = min((size.height / 860).clamp(0.48, 1.0), widthScale);
    final spacingScale = isShortScreen ? 0.62 : 1.0;
    final safeBottomInset = mediaQuery.padding.bottom;

    final horizontalPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 18.0
        : ThemeConstants.paddingLarge;
    final verticalPadding =
        ((isSmallScreen ? 12.0 : ThemeConstants.paddingLarge) * heightScale)
            .clamp(8.0, 32.0);
    final contentMaxWidth = size.width < 420
        ? size.width - (horizontalPadding * 2)
        : (size.width < 1100 ? 620.0 : 760.0);

    final logoBaseSize =
        (isSmallScreen
            ? 140.0
            : isMediumScreen
            ? 180.0
            : 200.0) *
        heightScale;
    final outerRingStep = (isSmallScreen ? 22.0 : 30.0) * heightScale;
    final splashLogoWidth = (isSmallScreen ? 250.0 : 360.0) * heightScale;
    final splashLogoHeight = (isSmallScreen ? 105.0 : 150.0) * heightScale;

    final brandFontSize =
        (isSmallScreen
            ? 20.0
            : isMediumScreen
            ? 22.0
            : 26.0) *
        heightScale;
    final cardHorizontalPadding = (isSmallScreen ? 16.0 : 30.0) * heightScale;
    final cardVerticalPadding = (isSmallScreen ? 14.0 : 20.0) * heightScale;
    final buttonWidth = (size.width * (isSmallScreen ? 0.72 : 0.45))
        .clamp(170.0, 260.0)
        .toDouble();
    final buttonHeight = ((isSmallScreen ? 50.0 : 56.0) * heightScale).clamp(
      46.0,
      56.0,
    );
    final storeName =
        (context.watch<StoreController>().currentStore?.name ?? '').trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const LanguageSwitcher(),
      body: Stack(
        children: [
          // ========== خلفية متعددة الطبقات ==========
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF0B0B1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF0F0F1A),
                  Color(0xFF050510),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // ========== توهج خلفي ناعم ==========
          AnimatedBuilder(
            animation: _alphaController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      sin(_alphaController.value * 2 * pi) * 0.2,
                      cos(_alphaController.value * 2 * pi) * 0.2,
                    ),
                    radius: 1.2,
                    colors: [
                      ThemeConstants.accentColor.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // ========== نجوم متلألئة ==========
          ...List.generate(40, (index) {
            final randomX = _random.nextDouble() * size.width;
            final randomY = _random.nextDouble() * size.height;
            final starSize = _random.nextDouble() * 2 + 1;
            final twinkleSpeed = _random.nextDouble() * 2 + 1;

            return Positioned(
              left: randomX,
              top: randomY,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: twinkleSpeed.toInt()),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 0.3 + sin(value * pi) * 0.3,
                    child: Container(
                      width: starSize,
                      height: starSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: starSize * 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            );
          }),

          // ========== رسم الموجات الدماغية المحسن ==========
          AnimatedBuilder(
            animation: Listenable.merge([
              _brainWaveController,
              _alphaController,
              _betaController,
              _gammaController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedBrainWavePainter(
                  progress: _brainWaveController.value,
                  alphaValue: _alphaController.value,
                  betaValue: _betaController.value,
                  gammaValue: _gammaController.value,
                  color: ThemeConstants.accentColor,
                ),
                size: size,
              );
            },
          ),

          // ========== حلقات طاقة متحدة المركز ==========
          ...List.generate(6, (index) {
            final delay = index * 0.15;
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final progress = (_pulseController.value + delay) % 1.0;
                final scale = 0.2 + progress * 1.8;
                final opacity = (1 - progress).clamp(0.0, 0.2);

                return Positioned(
                  left: size.width / 2 - 150 * scale,
                  top: size.height / 2 - 150 * scale,
                  child: Container(
                    width: 300 * scale,
                    height: 300 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeConstants.accentColor.withValues(
                          alpha: opacity,
                        ),
                        width: 2 - index * 0.3,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // ========== خطوط طيفية متحركة ==========
          AnimatedBuilder(
            animation: _gammaController,
            builder: (context, child) {
              return CustomPaint(
                painter: SpectralLinesPainter(
                  progress: _gammaController.value,
                  color: ThemeConstants.accentColor,
                ),
                size: size,
              );
            },
          ),

          // ========== جسيمات متوهجة متطورة ==========
          ...List.generate(25, (index) {
            final randomX = _random.nextDouble() * size.width;
            final randomY = _random.nextDouble() * size.height;
            final particleSize = _random.nextDouble() * 6 + 2;
            final speed = _random.nextDouble() * 3 + 2;
            final angle = _random.nextDouble() * 2 * pi;
            final colorIndex = _random.nextInt(3);

            return AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final floatOffset =
                    sin(_floatController.value * 2 * pi + index) * 30;
                final glowIntensity =
                    0.3 + sin(_betaController.value * pi + index) * 0.2;

                return Positioned(
                  left: randomX + floatOffset * cos(angle),
                  top: randomY + floatOffset * sin(angle),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: speed.toInt()),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: glowIntensity * sin(value * pi).abs(),
                        child: Container(
                          width: particleSize,
                          height: particleSize,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                colorIndex == 0
                                    ? ThemeConstants.accentColor
                                    : colorIndex == 1
                                    ? Colors.blue
                                    : Colors.purple,
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (colorIndex == 0
                                            ? ThemeConstants.accentColor
                                            : colorIndex == 1
                                            ? Colors.blue
                                            : Colors.purple)
                                        .withValues(alpha: 0.4),
                                blurRadius: particleSize * 3,
                                spreadRadius: particleSize,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }),

          // ========== طبقة ضبابية خلفية ==========
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ========== المحتوى الرئيسي ==========
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = max(
                  0.0,
                  constraints.maxWidth - (horizontalPadding * 2),
                );
                final availableHeight = max(
                  0.0,
                  constraints.maxHeight - (verticalPadding * 2),
                );

                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: SizedBox(
                      width: availableWidth,
                      height: availableHeight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: min(contentMaxWidth, availableWidth),
                            maxWidth: contentMaxWidth,
                          ),
                          child: Column(
                            mainAxisAlignment: isShortScreen
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                            // ========== الشعار المحسن ==========
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _floatController,
                                _alphaController,
                              ]),
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    sin(_floatController.value * 2 * pi) * 10,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // طبقات التوهج
                                      ...List.generate(3, (index) {
                                        return AnimatedBuilder(
                                          animation: _alphaController,
                                          builder: (context, child) {
                                            final glowSize =
                                                logoBaseSize +
                                                index * outerRingStep * 1.5;
                                            final glowOpacity =
                                                0.15 -
                                                index * 0.04 +
                                                sin(
                                                      _alphaController.value *
                                                              pi +
                                                          index,
                                                    ) *
                                                    0.05;

                                            return Container(
                                              width: glowSize,
                                              height: glowSize,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ThemeConstants
                                                        .accentColor
                                                        .withValues(
                                                          alpha: glowOpacity,
                                                        ),
                                                    blurRadius: 40 + index * 20,
                                                    spreadRadius:
                                                        10 - index * 3,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }),

                                      // حلقات متحركة رئيسية
                                      ...List.generate(4, (index) {
                                        return AnimatedBuilder(
                                          animation: _gammaController,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle:
                                                  _gammaController.value *
                                                  2 *
                                                  pi *
                                                  (index.isEven ? 1 : -1),
                                              child: Container(
                                                width:
                                                    logoBaseSize +
                                                    index * outerRingStep,
                                                height:
                                                    logoBaseSize +
                                                    index * outerRingStep,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: ThemeConstants
                                                        .accentColor
                                                        .withValues(
                                                          alpha:
                                                              0.25 -
                                                              index * 0.05,
                                                        ),
                                                    width: 1.5 - index * 0.2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),

                                      // حلقة بلورية متألقة
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          logoBaseSize,
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 20,
                                            sigmaY: 20,
                                          ),
                                          child: Container(
                                            width: logoBaseSize * 1.1,
                                            height: logoBaseSize * 1.1,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.02,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.1,
                                                ),
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // الأيقونة الرئيسية مع تأثيرات متعددة
                                      AnimatedBuilder(
                                        animation: Listenable.merge([
                                          _betaController,
                                          _pulseController,
                                        ]),
                                        builder: (context, child) {
                                          return SizedBox(
                                            width: splashLogoWidth,
                                            height: splashLogoHeight,
                                            child: Center(
                                              child: TweenAnimationBuilder(
                                                tween: Tween<double>(
                                                  begin: 0.96,
                                                  end: 1.04,
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 2000,
                                                ),
                                                curve: Curves.easeInOut,
                                                builder: (context, scale, child) {
                                                  return Transform.scale(
                                                    scale: scale,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      child: Image.asset(
                                                        'assets/image/logo.png',
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Icon(
                                                                Icons.image_not_supported_outlined,
                                                                size: isSmallScreen
                                                                    ? 42
                                                                    : 56,
                                                                color: Colors
                                                                    .white70,
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              height:
                                  (isSmallScreen ? 8.0 : 12.0) *
                                  heightScale *
                                  spacingScale,
                            ),

                            // ========== النص الرئيسي المحسن ==========
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: const [
                                      Colors.white,
                                      Color(0xFFD4AF37),
                                      Colors.white,
                                      Color(0xFFB8860B),
                                    ],
                                    stops: const [0.0, 0.3, 0.7, 1.0],
                                    transform: GradientRotation(
                                      _alphaController.value * pi,
                                    ),
                                  ).createShader(bounds),
                                  child: Text(
                                    '',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0,
                                      shadows: const [],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                                  0 *
                                  heightScale *
                                  spacingScale,
                            ),

                            // ========== النص الفرعي المحسن ==========
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Text(
                                  '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    shadows: const [],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            if (storeName.isNotEmpty) ...[
                              SizedBox(
                                height: (isSmallScreen ? 10.0 : 12.0) * heightScale,
                              ),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (isSmallScreen ? 12.0 : 16.0) * heightScale,
                                    vertical: (isSmallScreen ? 6.0 : 8.0) * heightScale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ThemeConstants.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.store,
                                        color: ThemeConstants.accentColor,
                                        size: brandFontSize,
                                      ),
                                      SizedBox(
                                        width: (isSmallScreen ? 6.0 : 8.0) * heightScale,
                                      ),
                                      Text(
                                        storeName,
                                        style: TextStyle(
                                          fontSize: brandFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            SizedBox(
                              height:
                                  (isSmallScreen ? 20.0 : 30.0) *
                                  heightScale *
                                  spacingScale,
                            ),

                            // ========== بطاقة الشرح المتطورة ==========
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 2000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: Transform.scale(
                                      scale: 0.95 + value * 0.05,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: cardHorizontalPadding,
                                    vertical: cardVerticalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.08),
                                        Colors.white.withValues(alpha: 0.03),
                                        ThemeConstants.accentColor.withValues(
                                          alpha: 0.05,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 24 : 32,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 24 : 32,
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: [
                                            Text(
                                              StringHelper.tr(
                                                'discover_ideal_perfume',
                                              ),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    (isSmallScreen
                                                        ? 16.0
                                                        : 20.0) *
                                                    heightScale,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  (isSmallScreen ? 8.0 : 12.0) *
                                                  heightScale,
                                            ),

                                            // ========== رسم موجات تفاعلي ==========
                                            SizedBox(
                                              height: 50,
                                              child: AnimatedBuilder(
                                                animation: Listenable.merge([
                                                  _betaController,
                                                  _gammaController,
                                                ]),
                                                builder: (context, child) {
                                                  return CustomPaint(
                                                    painter: WaveformPainter(
                                                      progress:
                                                          _betaController.value,
                                                      gammaValue:
                                                          _gammaController
                                                              .value,
                                                      color: ThemeConstants
                                                          .accentColor,
                                                    ),
                                                    size: const Size(200, 50),
                                                  );
                                                },
                                              ),
                                            ),

                                            SizedBox(
                                              height:
                                                  (isSmallScreen ? 4.0 : 6.0) *
                                                  heightScale,
                                            ),

                                            // ========== مؤشرات الموجات ==========
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _buildEnhancedWaveIndicator(
                                                  'Alpha',
                                                  0.2,
                                                  Colors.blue,
                                                  _alphaController,
                                                ),
                                                SizedBox(
                                                  width:
                                                      (isSmallScreen
                                                          ? 16.0
                                                          : 24.0) *
                                                      heightScale,
                                                ),
                                                _buildEnhancedWaveIndicator(
                                                  'Beta',
                                                  0.5,
                                                  ThemeConstants.accentColor,
                                                  _betaController,
                                                ),
                                                SizedBox(
                                                  width:
                                                      (isSmallScreen
                                                          ? 16.0
                                                          : 24.0) *
                                                      heightScale,
                                                ),
                                                _buildEnhancedWaveIndicator(
                                                  'Gamma',
                                                  0.8,
                                                  Colors.purple,
                                                  _gammaController,
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height:
                                                  (isSmallScreen ? 6.0 : 8.0) *
                                                  heightScale,
                                            ),

                                            Text(
                                              StringHelper.tr(
                                                'analyze_brain_waves',
                                              ),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize:
                                                    (isSmallScreen
                                                        ? 13.0
                                                        : 15.0) *
                                                    heightScale,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                                  (isSmallScreen ? 28.0 : 50.0) *
                                  heightScale *
                                  spacingScale,
                            ),

                            // ========== زر البداية الفاخر ==========
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.9, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(opacity: value, child: child);
                                },
                                child: _buildLuxuryStartButton(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: max(
                                (isSmallScreen ? 14.0 : 20.0) *
                                    heightScale *
                                    spacingScale,
                                safeBottomInset + 14,
                              ).toDouble(),
                            ),

                            // ========== نص حقوق الملكية المتلألئ ==========
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value * 0.5,
                                  child: child,
                                );
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: const [
                                    Colors.white24,
                                    Colors.white54,
                                    Colors.white24,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(bounds),
                                child: Text(
                                  StringHelper.tr('copyright_neuroscent'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWaveIndicator(
    String label,
    double phase,
    Color color,
    AnimationController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: color.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return SizedBox(
              width: 40,
              height: 30,
              child: CustomPaint(
                painter: MiniWavePainter(
                  progress: controller.value,
                  color: color,
                  phase: phase,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLuxuryStartButton({
    required double width,
    required double height,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctaHoverController.forward(),
      onExit: (_) => _ctaHoverController.reverse(),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/profile-input');
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _ctaHoverController,
            _ctaSheenController,
            _pulseController,
          ]),
          builder: (context, child) {
            const goldLight = Color(0xFFF9E076);
            const goldPrimary = Color(0xFFD4AF37);
            const goldDeep = Color(0xFF8B6910);
            const warmWhite = Color(0xFFFFFAF0);

            final hoverT = Curves.easeOut.transform(_ctaHoverController.value);
            final scale = 1.0 + (hoverT * 0.03);
            final glowOpacity = 0.3 + (hoverT * 0.5);
            final borderOpacity = 0.4 + (hoverT * 0.4);
            final sheenOffset =
                -width + (_ctaSheenController.value * width * 2.2);
            final pulseScale = 1.0 + sin(_pulseController.value * pi) * 0.02;

            return Transform.scale(
              scale: scale * pulseScale,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // طبقة التوهج الخارجي
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: goldPrimary.withValues(alpha: glowOpacity),
                              blurRadius: 30 + (hoverT * 15),
                              spreadRadius: 2 + (hoverT * 3),
                            ),
                            BoxShadow(
                              color: goldLight.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // طبقة الحدود المتدرجة
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          gradient: LinearGradient(
                            colors: [
                              goldLight.withValues(alpha: borderOpacity),
                              goldPrimary.withValues(
                                alpha: borderOpacity * 1.2,
                              ),
                              goldDeep.withValues(alpha: borderOpacity * 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: ClipRRect(
                            borderRadius: borderRadius,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: const [
                                    Color(0xFF1A1A1A),
                                    Color(0xFF0A0A0A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // طبقة اللمعان المتحرك
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: Stack(
                          children: [
                            // اللمعان الأساسي
                            Transform.translate(
                              offset: Offset(sheenOffset, 0),
                              child: Container(
                                width: width * 0.4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.25),
                                      goldLight.withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),

                            // نقاط متلألئة إضافية
                            ...List.generate(3, (index) {
                              return Positioned(
                                left:
                                    _ctaSheenController.value * width * 1.5 -
                                    (index * 20),
                                top: index * 5.0,
                                child: Opacity(
                                  opacity:
                                      (sin(
                                                _ctaSheenController.value *
                                                        pi *
                                                        2 +
                                                    index,
                                              ).abs() *
                                              0.15)
                                          .clamp(0.0, 1.0),
                                  child: Container(
                                    width: 2,
                                    height: height,
                                    color: goldLight,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // المحتوى
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: goldLight,
                            size: height * 0.38,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            StringHelper.tr('start_journey'),
                            style: TextStyle(
                              color: warmWhite,
                              fontSize: height * 0.32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: goldPrimary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ========== رسام الموجات الدماغية المحسن ==========
class EnhancedBrainWavePainter extends CustomPainter {
  final double progress;
  final double alphaValue;
  final double betaValue;
  final double gammaValue;
  final Color color;

  EnhancedBrainWavePainter({
    required this.progress,
    required this.alphaValue,
    required this.betaValue,
    required this.gammaValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // الموجة الرئيسية (Alpha)
    final alphaPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // الموجة الثانوية (Beta)
    final betaPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // الموجة السريعة (Gamma)
    final gammaPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final centerY = size.height * 0.3;
    final pathAlpha = Path();
    final pathBeta = Path();
    final pathGamma = Path();

    for (double x = 0; x < size.width; x += 3) {
      // Alpha wave - بطيئة وعميقة
      final yAlpha =
          centerY +
          sin(x * 0.015 + progress * 2 * pi) * 20 * (1 + alphaValue) +
          cos(x * 0.005 + progress) * 15;

      // Beta wave - متوسطة
      final yBeta =
          centerY +
          40 +
          sin(x * 0.025 + progress * 3 * pi + betaValue) * 18 +
          cos(x * 0.01 + progress * 2) * 12;

      // Gamma wave - سريعة
      final yGamma =
          centerY +
          80 +
          sin(x * 0.04 + progress * 5 * pi + gammaValue * 2) * 15 +
          sin(x * 0.02 + progress * 3) * 10;

      if (x == 0) {
        pathAlpha.moveTo(x, yAlpha);
        pathBeta.moveTo(x, yBeta);
        pathGamma.moveTo(x, yGamma);
      } else {
        pathAlpha.lineTo(x, yAlpha);
        pathBeta.lineTo(x, yBeta);
        pathGamma.lineTo(x, yGamma);
      }
    }

    canvas.drawPath(pathAlpha, alphaPaint);
    canvas.drawPath(pathBeta, betaPaint);
    canvas.drawPath(pathGamma, gammaPaint);

    // رسم نقاط متوهجة على الموجات
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 30) {
      final y = centerY + sin(x * 0.015 + progress * 2 * pi) * 20;
      final opacity = 0.2 + sin(x * 0.1 + progress * 4) * 0.1;

      dotPaint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedBrainWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.alphaValue != alphaValue ||
        oldDelegate.betaValue != betaValue ||
        oldDelegate.gammaValue != gammaValue;
  }
}

// ========== رسام الخطوط الطيفية ==========
class SpectralLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  SpectralLinesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + progress * 2 * pi;
      final length1 = 80 + sin(progress * 2 * pi + i) * 30;
      final length2 = 150 + cos(progress * 2 * pi + i) * 40;

      final point1 = Offset(
        center.dx + cos(angle) * length1,
        center.dy + sin(angle) * length1,
      );

      final point2 = Offset(
        center.dx + cos(angle + 0.2) * length2,
        center.dy + sin(angle + 0.2) * length2,
      );

      canvas.drawLine(point1, point2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpectralLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ========== رسام الموجات المصغر ==========
class MiniWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double phase;

  MiniWavePainter({
    required this.progress,
    required this.color,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x < size.width; x += 2) {
      final y =
          centerY +
          sin(x * 0.3 + progress * 2 * pi + phase * 4) * (size.height / 3);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MiniWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ========== رسام شكل الموجة ==========
class WaveformPainter extends CustomPainter {
  final double progress;
  final double gammaValue;
  final Color color;

  WaveformPainter({
    required this.progress,
    required this.gammaValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x < size.width; x += 1) {
      final y =
          centerY +
          sin(x * 0.2 + progress * 2 * pi) *
              (size.height / 2.5) *
              (0.7 + gammaValue * 0.3);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gammaValue != gammaValue;
  }
}
