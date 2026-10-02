import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/admin/screens/create_store_user_screen.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class StoreUsersScreen extends StatefulWidget {
  const StoreUsersScreen({super.key});

  @override
  State<StoreUsersScreen> createState() => _StoreUsersScreenState();
}

class _StoreUsersScreenState extends State<StoreUsersScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  late final AnimationController _listAnimationController;
  late final AnimationController _headerGlowController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  late final Animation<double> _headerGlowAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;

  final List<UserParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _headerGlowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _headerGlowController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _initParticles();
    _loadUsers();
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(
        UserParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3 + 1,
          speed: _random.nextDouble() * 0.005 + 0.002,
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
    _listAnimationController.dispose();
    _headerGlowController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    _listAnimationController.reset();

    final controller = Provider.of<AdminController>(context, listen: false);
    _users = await controller.getAllStoreUsers();

    if (!mounted) return;
    setState(() => _loading = false);
    _listAnimationController.forward();
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_headerGlowAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // أيقونة المستخدمين مع تأثيرات
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ThemeConstants.accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.accentColor.withValues(
                            alpha: _headerGlowAnimation.value * 0.3,
                          ),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people,
                      color: ThemeConstants.accentColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                'إدارة مستخدمي المتاجر',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // عداد المستخدمين
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: ThemeConstants.accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_users.length} مستخدم',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (user['active'] == true
                          ? ThemeConstants.accentColor
                          : Colors.grey)
                      .withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                    (user['active'] == true
                            ? ThemeConstants.accentColor
                            : Colors.grey)
                        .withValues(alpha: 0.02),
                  ],
                ),
                border: Border.all(
                  color:
                      (user['active'] == true
                              ? ThemeConstants.accentColor
                              : Colors.grey)
                          .withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // أيقونة المستخدم مع حالة النشاط
                  Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              (user['active'] == true
                                      ? ThemeConstants.accentColor
                                      : Colors.grey)
                                  .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user['username']?.toString()[0].toUpperCase() ??
                                'U',
                            style: TextStyle(
                              color: user['active'] == true
                                  ? ThemeConstants.accentColor
                                  : Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: user['active'] == true
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // معلومات المستخدم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['username']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user['active'] == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'نشط',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'المتجر: ${user['storeName'] ?? ''}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Switch مع تأثير
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: user['active'] == true,
                      // ignore: deprecated_member_use
                      activeColor: ThemeConstants.accentColor,
                      activeTrackColor: ThemeConstants.accentColor.withValues(
                        alpha: 0.3,
                      ),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                      onChanged: (value) async {
                        await Provider.of<AdminController>(
                          context,
                          listen: false,
                        ).toggleStoreUserStatus(user['id'].toString(), value);
                        _loadUsers();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // زر الحذف مع تأكيد
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteDialog(user),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف المستخدم "${user['username']}"؟',
          style: const TextStyle(color: Colors.white70),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('إلغاء'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('حذف'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _loading = true);
      await Provider.of<AdminController>(
        context,
        listen: false,
      ).deleteStoreUser(user['id'].toString());
      _loadUsers();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: ThemeConstants.accentColor.withValues(
                            alpha: 0.5,
                          ),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد مستخدمين',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'انقر على زر الإضافة لإنشاء مستخدم جديد',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadUsers,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية متحركة
          const AnimatedBackground(
            withParticles: true,
            child: SizedBox.expand(),
          ),

          // جسيمات إضافية
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return CustomPaint(
                painter: UserParticlesPainter(
                  particles: _particles,
                  progress: _rotateController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // المحتوى الرئيسي
          Consumer<AdminController>(
            builder: (context, controller, child) {
              if (_loading) {
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

              return Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: ThemeConstants.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'بحث عن مستخدم...',
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedButton(
                          text: 'إضافة',
                          icon: Icons.add,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateStoreUserScreen(),
                              ),
                            );
                            _loadUsers();
                          },
                          width: 100,
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return _buildUserCard(user, index);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// كلاس جسيمات المستخدمين
class UserParticle {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  UserParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// رسام جسيمات المستخدمين
class UserParticlesPainter extends CustomPainter {
  final List<UserParticle> particles;
  final double progress;

  UserParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y += particle.speed;
      if (particle.y > 1.0) {
        particle.y = 0.0;
        particle.x = Random().nextDouble();
      }

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: 0.1 + sin(progress * pi + particle.x) * 0.1,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant UserParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
