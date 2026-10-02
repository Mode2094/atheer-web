import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class DistributionCharts extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DistributionCharts({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringHelper.tr('users_distribution'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _buildChart(
                      StringHelper.tr('gender_distribution'),
                      Map<String, int>.from(stats['genderDistribution'] ?? {}),
                    ),
                    const SizedBox(height: 16),
                    _buildChart(
                      StringHelper.tr('countries_distribution'),
                      Map<String, int>.from(stats['countries'] ?? {}),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildChart(
                      StringHelper.tr('gender_distribution'),
                      Map<String, int>.from(stats['genderDistribution'] ?? {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildChart(
                      StringHelper.tr('countries_distribution'),
                      Map<String, int>.from(stats['countries'] ?? {}),
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

  Widget _buildChart(String title, Map<String, int> data) {
    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (data.isEmpty)
          Center(
            child: Text(
              StringHelper.tr('no_data_available'),
              style: const TextStyle(color: Colors.white70),
            ),
          )
        else
          ...data.entries.map((entry) {
            final percentage = total == 0 ? 0.0 : (entry.value / total * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _normalizeDisplay(entry.key),
                      style: const TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : entry.value / total,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation(
                        ThemeConstants.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _normalizeDisplay(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'male' || normalized == 'ذكر') {
      return StringHelper.tr('gender_male');
    }
    if (normalized == 'female' || normalized == 'أنثى') {
      return StringHelper.tr('gender_female');
    }
    if (normalized == 'unisex' || normalized == 'للجنسين') {
      return StringHelper.tr('gender_unisex');
    }
    return value;
  }
}
