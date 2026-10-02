import 'package:flutter/material.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class UpdateProgressDialog extends StatelessWidget {
  const UpdateProgressDialog({
    super.key,
    required this.progress,
    required this.statusMessage,
  });

  final double progress;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0, 1).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تحديث أثير',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: normalizedProgress),
            const SizedBox(height: 8),
            Text(
              '${(normalizedProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
