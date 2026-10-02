import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:perfume/features/shared/widgets/inactivity_detector.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/glowing_button.dart';
import 'package:provider/provider.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  String _selectedCountry = '+974';
  bool _isSubmitting = false;

  late final AnimationController _floatingController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _glowController;
  late final AnimationController _fieldFocusController;
  late final AnimationController _particleController;

  late final Animation<double> _floatAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _glowAnimation;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fieldFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initParticles();

    _nameFocus.addListener(_onFocusChange);
    _phoneFocus.addListener(_onFocusChange);
    _genderFocus.addListener(_onFocusChange);
    _countryFocus.addListener(_onFocusChange);
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 4 + 2,
          speed: _random.nextDouble() * 0.02 + 0.01,
          color: [
            ThemeConstants.accentColor,
            Colors.blue,
            Colors.purple,
          ][_random.nextInt(3)],
        ),
      );
    }
  }

  void _onFocusChange() {
    if (_nameFocus.hasFocus ||
        _phoneFocus.hasFocus ||
        _genderFocus.hasFocus ||
        _countryFocus.hasFocus) {
      _fieldFocusController.forward();
    } else {
      _fieldFocusController.reverse();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    _fieldFocusController.dispose();
    _particleController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _genderFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  Future<void> _goQuestionnaire({required bool skip}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final signedIn = await authController.signInWithPhone(
      _phoneController.text.trim(),
    );

    if (!mounted) return;
    if (!signedIn) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  authController.error ??
                      StringHelper.tr('session_creation_failed'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/questionnaire',
      arguments: {
        'name': skip ? '' : _nameController.text.trim(),
        'gender': _selectedGender ?? '',
        'phone': skip ? '' : _phoneController.text.trim(),
        'country': skip ? '' : _selectedCountry,
      },
    );
  }

  Widget _buildCosmicHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _pulseAnimation,
        _rotateAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // حلقات كونية دوارة
              ...List.generate(4, (index) {
                return Transform.rotate(
                  angle: _rotateAnimation.value + (index * pi / 2),
                  child: Container(
                    width: 120 + index * 30,
                    height: 120 + index * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeConstants.accentColor.withValues(
                          alpha: 0.15 - index * 0.03,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }),

              // توهج داخلي
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConstants.accentColor.withValues(
                        alpha: _glowAnimation.value * 0.4,
                      ),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),

              // الأيقونة الرئيسية مع تأثير نبض
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: const [
                        Color(0xFFF9E076), // goldLight
                        Color(0xFFD4AF37), // goldPrimary
                        Color(0xFF8B6910), // goldDeep
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              // نقاط متحركة حول الأيقونة
              ...List.generate(8, (index) {
                final angle = index * pi / 4 + _rotateAnimation.value;
                return Positioned(
                  left: 35 + 50 * cos(angle),
                  top: 35 + 50 * sin(angle),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeConstants.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.accentColor.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeuralField() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        // تحديث مواقع الجسيمات
        for (var particle in _particles) {
          particle.y += particle.speed;
          if (particle.y > 1.0) {
            particle.y = 0.0;
            particle.x = _random.nextDouble();
          }
        }

        return CustomPaint(
          size: const Size(200, 100),
          painter: NeuralFieldPainter(
            particles: _particles,
            progress: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildQuantumDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    FocusNode? focusNode,
    IconData? icon,
  }) {
    return AnimatedBuilder(
      animation: _fieldFocusController,
      builder: (context, child) {
        final isFocused = focusNode?.hasFocus ?? false;
        final scale = 1.0 + (_fieldFocusController.value * 0.02);

        return Transform.scale(
          scale: isFocused ? scale : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: ThemeConstants.accentColor.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isFocused
                      ? ThemeConstants.accentColor
                      : Colors.white.withValues(alpha: 0.1),
                  width: isFocused ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: value,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: isFocused
                        ? ThemeConstants.accentColor
                        : Colors.white70,
                  ),
                  prefixIcon: icon != null
                      ? Icon(
                          icon,
                          color: isFocused
                              ? ThemeConstants.accentColor
                              : Colors.white70,
                        )
                      : null,
                  border: InputBorder.none,
                ),
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isFocused
                      ? ThemeConstants.accentColor
                      : Colors.white70,
                ),
                items: items,
                onChanged: onChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${StringHelper.tr('please_select')} $label';
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isSmallScreen = size.width < 380;

    return InactivityDetector(
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متحركة
            const AnimatedBackground(
              withParticles: true,
              child: SizedBox.expand(),
            ),

            // جسيمات كونية إضافية
            ...List.generate(15, (index) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final x =
                      (sin(_particleController.value * 2 * pi + index) * 0.5 +
                          0.5) *
                      size.width;
                  final y =
                      (cos(_particleController.value * 3 + index) * 0.5 + 0.5) *
                      size.height;
                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: ThemeConstants.accentColor.withValues(
                          alpha: 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),

            // المحتوى الرئيسي
            SafeArea(
              child: Center(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: SizedBox(
                        width: 680,
                        child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: ThemeConstants.accentColor.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.transparent,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // الهيدر الكوني
                                    _buildCosmicHeader(),

                                    const SizedBox(height: 24),

                                    // نص ترحيبي
                                    Text(
                                      StringHelper.tr('additional_info'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 30),

                                    // حقل الجنس بتصميم كوانتي
                                    _buildQuantumDropdown(
                                      label: StringHelper.tr('gender'),
                                      value: _selectedGender,
                                      focusNode: _genderFocus,
                                      icon: Icons.wc,
                                      items: AppConstants.genderOptions
                                          .map(
                                            (gender) =>
                                                DropdownMenuItem<String>(
                                                  value: gender,
                                                  child: Text(
                                                    _localizedGender(gender),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(
                                            () => _selectedGender = value,
                                          );
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // حقل الاسم
                                    TextFormField(
                                      controller: _nameController,
                                      focusNode: _nameFocus,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: StringHelper.tr(
                                          'optional_name',
                                        ),
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: Colors.white70,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          borderSide: BorderSide(
                                            color: _nameFocus.hasFocus
                                                ? ThemeConstants.accentColor
                                                : Colors.white.withValues(
                                                    alpha: 0.1,
                                                  ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          borderSide: BorderSide(
                                            color: ThemeConstants.accentColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // صف الهاتف والدولة
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // حقل رقم الهاتف
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: _phoneController,
                                            focusNode: _phoneFocus,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              labelText: StringHelper.tr(
                                                'phone_number',
                                              ),
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.phone_outlined,
                                                color: Colors.white70,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withValues(alpha: 0.05),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                borderSide: BorderSide(
                                                  color: _phoneFocus.hasFocus
                                                      ? ThemeConstants
                                                            .accentColor
                                                      : Colors.white.withValues(
                                                          alpha: 0.1,
                                                        ),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                borderSide: BorderSide(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                borderSide: BorderSide(
                                                  color: ThemeConstants
                                                      .accentColor,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // حقل الدولة
                                        Expanded(
                                          flex: 2,
                                          child: _buildQuantumDropdown(
                                            label: StringHelper.tr('country'),
                                            value: _selectedCountry,
                                            focusNode: _countryFocus,
                                            icon: Icons.public,
                                            items: [
                                              DropdownMenuItem(
                                                value: '+974',
                                                child: Text(
                                                  StringHelper.tr('qatar'),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: '+971',
                                                child: Text(
                                                  StringHelper.tr(
                                                    'uae',
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: '+966',
                                                child: Text(
                                                  StringHelper.tr(
                                                    'saudi_arabia',
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: '+962',
                                                child: Text(
                                                  StringHelper.tr('jordan'),
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () =>
                                                      _selectedCountry = value,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 30),

                                    // حقل الموجات العصبية التفاعلي
                                    Container(
                                      height: 60,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      child: _buildNeuralField(),
                                    ),

                                    // الأزرار
                                    Row(
                                      children: [
                                        // زر التخطي
                                        Expanded(
                                          child: TextButton(
                                            onPressed: _isSubmitting
                                                ? null
                                                : () {
                                                    if (!_formKey.currentState!
                                                        .validate()) {
                                                      return;
                                                    }
                                                    _goQuestionnaire(
                                                      skip: true,
                                                    );
                                                  },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              StringHelper.tr('skip'),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // زر المتابعة
                                        Expanded(
                                          child: GlowingButton(
                                            text: StringHelper.tr('continue'),
                                            isLoading: _isSubmitting,
                                            onPressed: () {
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              _goQuestionnaire(skip: false);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 0),

                                    // نص تلميحي
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.white.withValues(
                                            alpha: 0.0,
                                          ),
                                          size: 0,
                                        ),
                                        const SizedBox(width: 0),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.0,
                                            ),
                                            fontSize: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedGender(String value) {
    if (value == AppConstants.genderMale) {
      return StringHelper.tr('gender_male');
    }
    if (value == AppConstants.genderFemale) {
      return StringHelper.tr('gender_female');
    }
    return StringHelper.tr('gender_unisex');
  }
}

// كلاس الجسيمات
class Particle {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// رسام الحقل العصبي
class NeuralFieldPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  NeuralFieldPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // رسم الجسيم
      canvas.drawCircle(Offset(x, y), particle.size, paint);

      // رسم خطوط ربط بين الجسيمات القريبة
      for (var other in particles) {
        final dx = (other.x * size.width - x).abs();
        final dy = (other.y * size.height - y).abs();
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 50) {
          final linePaint = Paint()
            ..color = particle.color.withValues(
              alpha: 0.1 * (1 - distance / 50),
            )
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

          canvas.drawLine(
            Offset(x, y),
            Offset(other.x * size.width, other.y * size.height),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NeuralFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
