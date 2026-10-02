import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/core/models/eeg_result_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class EEGTestCard extends StatelessWidget {
  final String perfumeName;
  final String perfumeBrand;
  final String perfumeImage;
  final VoidCallback onStartTest;
  final bool isTesting;
  final double progress;
  final EEGResultModel? result;

  const EEGTestCard({
    super.key,
    required this.perfumeName,
    required this.perfumeBrand,
    required this.perfumeImage,
    required this.onStartTest,
    this.isTesting = false,
    this.progress = 0,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ThemeConstants.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.zero,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                      child: perfumeImage.isNotEmpty
                      ? Image.network(
                          perfumeImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Failed to load image: $perfumeImage');
                            return Icon(
                              Icons.spa,
                              color: ThemeConstants.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.spa,
                          color: ThemeConstants.accentColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfumeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      perfumeBrand,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isTesting && result == null)
                ElevatedButton(
                  onPressed: onStartTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.accentColor,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(context.loc.startTest),
                )
              else if (isTesting)
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: progress,
                    valueColor: const AlwaysStoppedAnimation(
                      ThemeConstants.accentColor,
                    ),
                    backgroundColor: Colors.white24,
                  ),
                )
              else if (result != null)
                Builder(
                  builder: (context) {
                    final score = _overallScorePercent(result!);
                    final color = _colorForScore(score);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        _messageForScore(score, context),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: 20),
            _buildEEGResults(result!, context),
          ],
        ],
      ),
    );
  }

  Widget _buildEEGResults(EEGResultModel result, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: ThemeConstants.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.neuralAnalysisResults,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricItem(
                context.loc.interest,
                (result.interest * 100).round(),
                Colors.purple,
              ),
              const SizedBox(width: 8),
              _buildMetricItem(
                context.loc.excitement,
                (result.excitement * 100).round(),
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildMetricItem(
                context.loc.relaxation,
                (result.relaxation * 100).round(),
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricItem(
                context.loc.engagement,
                (result.engagement * 100).round(),
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildMetricItem(
                context.loc.attention,
                (result.attention * 100).round(),
                Colors.teal,
              ),
              const SizedBox(width: 8),
              _buildMetricItem(
                context.loc.stress,
                (result.stress * 100).round(),
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.lowerStressHigherRelaxation,
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  double _overallScorePercent(EEGResultModel result) {
    final score =
        (result.interest * 0.4) +
        (result.excitement * 0.2) +
        ((1 - result.stress) * 0.2) +
        (result.relaxation * 0.2);
    return (score.clamp(0.0, 1.0) * 100).toDouble();
  }

  String _messageForScore(double score, BuildContext context) {
    if (score >= 80) return context.loc.excellent;
    if (score >= 60) return context.loc.veryGood;
    if (score >= 40) return context.loc.good;
    return context.loc.tryAgain;
  }

  Color _colorForScore(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
