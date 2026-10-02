import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool animate;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              [
                const Color(0xFF0F0F1A),
                const Color(0xFF1A1A2E),
                const Color(0xFF23233D),
              ],
        ),
      ),
      child: child,
    );
  }
}
