import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfume/core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool withParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.withParticles = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    for (var i = 0; i < 50; i++) {
      _particles.add(Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        if (widget.withParticles)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _controller.value),
                size: Size.infinite,
              );
            },
          ),
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Color color;

  Particle(Random random)
    : x = random.nextDouble() * 2 - 1,
      y = random.nextDouble() * 2 - 1,
      size = 2 + random.nextDouble() * 4,
      speed = 0.5 + random.nextDouble() * 1.5,
      opacity = 0.2 + random.nextDouble() * 0.3,
      color = random.nextBool() ? AppTheme.goldMain : AppTheme.purpleLight;

  void update(double _) {
    y += speed * 0.001;
    if (y > 1) {
      y = -1;
      x = Random().nextDouble() * 2 - 1;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(animation);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(
          (particle.x + 1) / 2 * size.width,
          (particle.y + 1) / 2 * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
