import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:perfume/core/localization/locale_controller.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/admin/screens/manage_store_screen.dart';
import 'package:perfume/features/admin/screens/store_users_screen.dart';
import 'package:perfume/features/admin/widgets/perfume_list.dart';
import 'package:perfume/features/admin/widgets/store_card.dart';
import 'package:perfume/features/admin_auth/admin_auth_controller.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dashboardGlowController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  late final Animation<double> _glowAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;

  final List<DashboardParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _dashboardGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _dashboardGlowController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _initDashboardParticles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  void _initDashboardParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(
        DashboardParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3 + 1,
          speedX: _random.nextDouble() * 0.005 - 0.0025,
          speedY: _random.nextDouble() * 0.005 - 0.0025,
          color: i % 3 == 0
              ? ThemeConstants.accentColor
              : i % 3 == 1
              ? Colors.blue
              : Colors.purple,
        ),
      );
    }
  }

  @override
  void dispose() {
    _dashboardGlowController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final adminAuth = Provider.of<AdminAuthController>(context, listen: false);
    await adminAuth.refreshSession();
    if (!mounted) return;

    if (!adminAuth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/admin-login');
      return;
    }

    if (mounted) {
      Provider.of<AdminController>(context, listen: false).loadStores();
    }
  }

  Future<void> _showLanguagePicker() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final localeController = Provider.of<LocaleController>(
          sheetContext,
          listen: false,
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                StringHelper.tr('change_language'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.white70),
                title: Text(
                  StringHelper.tr('arabic'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await localeController.setLocale('ar');
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.white70),
                title: Text(
                  StringHelper.tr('english'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await localeController.setLocale('en');
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset.zero,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      // أيقونة المدير مع تأثيرات
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ThemeConstants.accentColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeConstants.accentColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeConstants.accentColor.withValues(
                                    alpha: _glowAnimation.value * 0.3,
                                  ),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: ThemeConstants.accentColor,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        StringHelper.tr('admin_dashboard'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // إحصائيات سريعة
                      Consumer<AdminController>(
                        builder: (context, controller, child) {
                          return Row(
                            children: [
                              _buildStatItem(
                                StringHelper.tr('stores'),
                                controller.stores.length.toString(),
                                Icons.store,
                              ),
                              const SizedBox(width: 12),
                              _buildStatItem(
                                StringHelper.tr('perfumes'),
                                controller.totalPerfumesCount.toString(),
                                Icons.spa,
                              ),
                            ],
                          );
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeConstants.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ThemeConstants.accentColor, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (color ?? ThemeConstants.accentColor).withValues(
                  alpha: 0.3,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: (color ?? ThemeConstants.accentColor).withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(icon, color: color ?? ThemeConstants.accentColor),
              onPressed: onPressed,
              tooltip: tooltip,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.add,
            tooltip: StringHelper.tr('add_store'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageStoreScreen()),
              ).then((_) {
                if (mounted) {
                  context.read<AdminController>().loadStores();
                }
              });
            },
          ),
          _buildActionButton(
            icon: Icons.pie_chart,
            tooltip: StringHelper.tr('advanced_reports'),
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, '/admin/advanced-reports');
              }
            },
            color: Colors.blue,
          ),
          _buildActionButton(
            icon: Icons.bar_chart,
            tooltip: StringHelper.tr('reports'),
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, '/admin/reports');
              }
            },
            color: Colors.green,
          ),
          _buildActionButton(
            icon: Icons.people,
            tooltip: StringHelper.tr('users'),
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, '/admin/users');
              }
            },
            color: Colors.purple,
          ),
          _buildActionButton(
            icon: Icons.manage_accounts,
            tooltip: StringHelper.tr('manage_users'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreUsersScreen()),
              );
            },
            color: Colors.orange,
          ),
          _buildActionButton(
            icon: Icons.system_update,
            tooltip: StringHelper.tr('system_update'),
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, '/admin/update');
              }
            },
            color: Colors.teal,
          ),
          _buildActionButton(
            icon: Icons.language,
            tooltip: StringHelper.tr('change_language'),
            onPressed: _showLanguagePicker,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.accentColor.withValues(
                      alpha: _glowAnimation.value * 0.3,
                    ),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (mounted) {
                      Navigator.pushNamed(context, '/admin/update');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.accentColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeConstants.accentColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.system_update_alt,
                          color: ThemeConstants.accentColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            StringHelper.tr('app_update_available'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
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
    );
  }

  Widget _buildStoresPanel(AdminController controller, bool isNarrow) {
    return Container(
      decoration: BoxDecoration(
        border: isNarrow
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              )
            : Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildActionsRow(),
          _buildUpdateBanner(),
          Expanded(
            child: controller.stores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          StringHelper.tr('no_stores_yet'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          StringHelper.tr('click_plus_add_store'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.stores.length,
                    itemBuilder: (context, index) {
                      final store = controller.stores[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StoreCard(
                          store: store,
                          isSelected: controller.selectedStore?.id == store.id,
                          onTap: () => controller.selectStore(store),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isNarrow) {
    final panelRadius = isNarrow ? 24.0 : 40.0;
    final panelPadding = isNarrow
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 28)
        : const EdgeInsets.all(40);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 16 : 24),
        child: Container(
          padding: panelPadding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(panelRadius),
            border: Border.all(
              color: ThemeConstants.accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(panelRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة متحركة
                    Container(
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
                      child: const Icon(
                        Icons.storefront,
                        color: ThemeConstants.accentColor,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      StringHelper.tr('choose_store'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      StringHelper.tr('choose_store_manage_perfumes'),
                      textAlign: TextAlign.center,
                      maxLines: isNarrow ? 3 : 2,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

          // جسيمات لوحة التحكم
          AnimatedBuilder(
            animation: _dashboardGlowController,
            builder: (context, child) {
              return CustomPaint(
                painter: DashboardParticlesPainter(
                  particles: _particles,
                  progress: _dashboardGlowController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: Consumer<AdminController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.stores.isEmpty) {
                  return Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ThemeConstants.accentColor,
                                width: 3,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: ThemeConstants.accentColor,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 980;

                    return Column(
                      children: [
                        _buildDashboardHeader(),
                        Expanded(
                          child: isNarrow
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: constraints.maxHeight * 0.4,
                                      child: _buildStoresPanel(
                                        controller,
                                        true,
                                      ),
                                    ),
                                    Expanded(
                                      child: controller.selectedStore == null
                                          ? _buildEmptyState(true)
                                          : PerfumeList(
                                              store: controller.selectedStore!,
                                              perfumes: controller
                                                  .currentStorePerfumes,
                                            ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    SizedBox(
                                      width: 380,
                                      child: _buildStoresPanel(
                                        controller,
                                        false,
                                      ),
                                    ),
                                    Expanded(
                                      child: controller.selectedStore == null
                                          ? _buildEmptyState(false)
                                          : PerfumeList(
                                              store: controller.selectedStore!,
                                              perfumes: controller
                                                  .currentStorePerfumes,
                                            ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// كلاس جسيمات لوحة التحكم
class DashboardParticle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  Color color;

  DashboardParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

// رسام جسيمات لوحة التحكم
class DashboardParticlesPainter extends CustomPainter {
  final List<DashboardParticle> particles;
  final double progress;

  DashboardParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // تحديث الموقع
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      if (particle.x > 1.0) particle.x = 0.0;
      if (particle.x < 0.0) particle.x = 1.0;
      if (particle.y > 1.0) particle.y = 0.0;
      if (particle.y < 0.0) particle.y = 1.0;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: 0.1 + sin(progress * pi + particle.x) * 0.1,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 + progress * 0.3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashboardParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
