import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/admin_auth/admin_auth_controller.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _glowController;
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;
  late final AnimationController _shieldController;
  late final AnimationController _fieldFocusController;

  late final Animation<double> _glowAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _shieldAnimation;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final List<SecurityParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fieldFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shieldAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );

    _initSecurityParticles();

    _usernameFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _initSecurityParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(
        SecurityParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3 + 1,
          speed: _random.nextDouble() * 0.01 + 0.005,
          angle: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _onFocusChange() {
    if (_usernameFocus.hasFocus || _passwordFocus.hasFocus) {
      _fieldFocusController.forward();
    } else {
      _fieldFocusController.reverse();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _shieldController.dispose();
    _fieldFocusController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AdminAuthController>(
      context,
      listen: false,
    );
    final success = await authController.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }

  Widget _buildSecurityShield() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimation,
        _rotateAnimation,
        _pulseAnimation,
        _shieldAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // حلقات أمنية دوارة
            ...List.generate(3, (index) {
              return Transform.rotate(
                angle: _rotateAnimation.value + (index * pi / 2),
                child: Container(
                  width: 130 + index * 30,
                  height: 130 + index * 30,
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

            // درع أمان متحرك
            Transform.scale(
              scale: _shieldAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ThemeConstants.accentColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // أيقونة المدير مع تأثير نبض
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFF8B6910)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConstants.accentColor.withValues(
                        alpha: _glowAnimation.value * 0.5,
                      ),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            // نقاط أمنية متحركة حول الأيقونة
            ...List.generate(8, (index) {
              final angle = index * pi / 4 + _rotateAnimation.value;
              return Positioned(
                left: 40 + 50 * cos(angle),
                top: 40 + 50 * sin(angle),
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
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    bool isPassword = false,
  }) {
    return AnimatedBuilder(
      animation: _fieldFocusController,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        final scale = 1.0 + (_fieldFocusController.value * 0.02);

        return Transform.scale(
          scale: isFocused ? scale : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword ? _obscurePassword : false,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: isFocused
                      ? ThemeConstants.accentColor
                      : Colors.white70,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  icon,
                  color: isFocused
                      ? ThemeConstants.accentColor
                      : Colors.white70,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isFocused
                              ? ThemeConstants.accentColor
                              : Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: ThemeConstants.accentColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال $label';
                }
                if (isPassword && value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityParticles() {
    return AnimatedBuilder(
      animation: _shieldController,
      builder: (context, child) {
        // تحديث مواقع الجسيمات
        for (var particle in _particles) {
          particle.x += particle.speed * cos(particle.angle);
          particle.y += particle.speed * sin(particle.angle);

          if (particle.x > 1.0) particle.x = 0.0;
          if (particle.x < 0.0) particle.x = 1.0;
          if (particle.y > 1.0) particle.y = 0.0;
          if (particle.y < 0.0) particle.y = 1.0;
        }

        return CustomPaint(
          size: const Size(200, 100),
          painter: SecurityParticlesPainter(
            particles: _particles,
            progress: _shieldController.value,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // خلفية متحركة
          const AnimatedBackground(
            withParticles: true,
            child: SizedBox.expand(),
          ),

          // طبقة أمنية إضافية
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(color: Colors.transparent),
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.accentColor.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                                const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                              ],
                            ),
                            border: Border.all(
                              color: ThemeConstants.accentColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // الدرع الأمني
                                _buildSecurityShield(),

                                const SizedBox(height: 24),

                                // العنوان
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFD4AF37),
                                          Colors.white,
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ).createShader(bounds),
                                  child: const Text(
                                    'لوحة تحكم المدير',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // نص فرعي
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: ThemeConstants.accentColor
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Text(
                                    'منطقة آمنة - دخول المدير فقط',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // حقول الإدخال
                                _buildAnimatedTextField(
                                  controller: _usernameController,
                                  label: 'اسم المستخدم',
                                  icon: Icons.person_outline,
                                  focusNode: _usernameFocus,
                                ),

                                _buildAnimatedTextField(
                                  controller: _passwordController,
                                  label: 'كلمة المرور',
                                  icon: Icons.lock_outline,
                                  focusNode: _passwordFocus,
                                  isPassword: true,
                                ),

                                // جسيمات أمنية متحركة
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: _buildSecurityParticles(),
                                ),

                                // زر تسجيل الدخول
                                Consumer<AdminAuthController>(
                                  builder: (context, authController, child) {
                                    return AnimatedBuilder(
                                      animation: _glowController,
                                      builder: (context, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ThemeConstants
                                                    .accentColor
                                                    .withValues(
                                                      alpha:
                                                          _glowAnimation.value *
                                                          0.3,
                                                    ),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: AnimatedButton(
                                            text: 'تسجيل الدخول',
                                            isLoading: authController.isLoading,
                                            onPressed: _login,
                                            width: double.infinity,
                                            height: 56,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),

                                // رسالة الخطأ
                                Consumer<AdminAuthController>(
                                  builder: (context, authController, child) {
                                    if (authController.error == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, opacity, child) {
                                          return Opacity(
                                            opacity: opacity,
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.red.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      authController.error!,
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // تلميحات أمنية
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'اتصال آمن • مشفر بالكامل',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        fontSize: 11,
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
        ],
      ),
    );
  }
}

// كلاس الجسيمات الأمنية
class SecurityParticle {
  double x;
  double y;
  double size;
  double speed;
  double angle;

  SecurityParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

// رسام الجسيمات الأمنية
class SecurityParticlesPainter extends CustomPainter {
  final List<SecurityParticle> particles;
  final double progress;

  SecurityParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // رسم الجسيم
      final paint = Paint()
        ..color = ThemeConstants.accentColor.withValues(
          alpha: 0.2 + sin(progress * pi + particle.x) * 0.1,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 + progress * 0.5),
        paint,
      );

      // رسم مسار حركة الجسيم (تأثير أمني)
      final linePaint = Paint()
        ..color = ThemeConstants.accentColor.withValues(alpha: 0.1)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      final nextX = x + cos(particle.angle) * 20;
      final nextY = y + sin(particle.angle) * 20;
      canvas.drawLine(Offset(x, y), Offset(nextX, nextY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SecurityParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
