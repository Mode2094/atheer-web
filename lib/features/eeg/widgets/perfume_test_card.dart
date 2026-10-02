import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/eeg/eeg_visualization_screen.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class PerfumeTestCard extends StatelessWidget {
  final String perfumeName;
  final String perfumeFamily;
  final VoidCallback onTestComplete;

  const PerfumeTestCard({
    super.key,
    required this.perfumeName,
    required this.perfumeFamily,
    required this.onTestComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  perfumeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ThemeConstants.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: ThemeConstants.accentColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  perfumeFamily,
                  style: const TextStyle(
                    color: ThemeConstants.accentColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EEGVisualizationScreen(
                          perfumeName: perfumeName,
                          onComplete: onTestComplete,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(StringHelper.tr('start_test')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
