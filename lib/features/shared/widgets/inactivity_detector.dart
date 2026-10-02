import 'package:flutter/material.dart';
import 'package:perfume/features/shared/services/session_service.dart';

class InactivityDetector extends StatefulWidget {
  final Widget child;

  const InactivityDetector({super.key, required this.child});

  @override
  State<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SessionService.startInactivityTimer(context);
      }
    });
  }

  @override
  void dispose() {
    SessionService.stopInactivityTimer();
    super.dispose();
  }

  void _onInteraction() {
    if (!mounted) return;
    SessionService.resetInactivityTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onInteraction(),
      onPointerMove: (_) => _onInteraction(),
      onPointerUp: (_) => _onInteraction(),
      onPointerSignal: (_) => _onInteraction(),
      child: widget.child,
    );
  }
}
