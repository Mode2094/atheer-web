import 'package:flutter/material.dart';
import 'package:perfume/core/theme/app_theme.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class AnimatedInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  const AnimatedInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<AnimatedInput> createState() => _AnimatedInputState();
}

class _AnimatedInputState extends State<AnimatedInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() => _isFocused = hasFocus);
                if (hasFocus) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              child: TextFormField(
                controller: widget.controller,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: _isFocused ? AppTheme.goldLight : Colors.white70,
                    fontSize: 16,
                  ),
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: widget.icon != null
                      ? Icon(
                          widget.icon,
                          color: _isFocused
                              ? AppTheme.goldLight
                              : Colors.white70,
                        )
                      : null,
                  border: InputBorder.none,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                validator: widget.validator,
              ),
            ),
          ),
        );
      },
    );
  }
}
