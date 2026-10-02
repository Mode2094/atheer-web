import 'package:flutter/material.dart';

class EEGMetrics {
  final double interest;
  final double excitement;
  final double stress;
  final double engagement;
  final double attention;
  final double relaxation;

  EEGMetrics({
    required this.interest,
    required this.excitement,
    required this.stress,
    required this.engagement,
    required this.attention,
    required this.relaxation,
  });

  int get interestPercent => (interest * 100).round();
  int get excitementPercent => (excitement * 100).round();
  int get stressPercent => (stress * 100).round();
  int get engagementPercent => (engagement * 100).round();
  int get attentionPercent => (attention * 100).round();
  int get relaxationPercent => (relaxation * 100).round();

  Color getInterestColor() => _getColor(interest);
  Color getExcitementColor() => _getColor(excitement);
  Color getStressColor() => _getColor(1 - stress);
  Color getEngagementColor() => _getColor(engagement);
  Color getAttentionColor() => _getColor(attention);
  Color getRelaxationColor() => _getColor(relaxation);

  Color _getColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }

  static EEGMetrics get sample {
    return EEGMetrics(
      interest: 0.81,
      excitement: 0.52,
      stress: 0.28,
      engagement: 0.65,
      attention: 0.70,
      relaxation: 0.72,
    );
  }
}
