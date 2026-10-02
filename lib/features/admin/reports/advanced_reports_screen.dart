import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/reports/advanced_reports_controller.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class AdvancedReportsScreen extends StatefulWidget {
  const AdvancedReportsScreen({super.key});

  @override
  State<AdvancedReportsScreen> createState() => _AdvancedReportsScreenState();
}

class _AdvancedReportsScreenState extends State<AdvancedReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdvancedReportsController>(
        context,
        listen: false,
      ).loadAllAdvancedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AdvancedReportsController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.advancedStats.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: ThemeConstants.accentColor,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      StringHelper.tr('advanced_reports'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedButton(
                          text: StringHelper.tr('refresh'),
                          icon: Icons.refresh,
                          onPressed: controller.loadAllAdvancedData,
                          width: 120,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        AnimatedButton(
                          text: StringHelper.tr('export_pdf'),
                          icon: Icons.picture_as_pdf,
                          onPressed: controller.generateAndSharePDF,
                          width: 140,
                          height: 40,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 760
                        ? 2
                        : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.5,
                      children: [
                        _buildStatCard(
                          StringHelper.tr('this_week'),
                          controller.advancedStats['usersThisWeek']?.toString() ??
                              '0',
                          Icons.people,
                        ),
                        _buildStatCard(
                          StringHelper.tr('this_month'),
                          controller.advancedStats['usersThisMonth']
                                  ?.toString() ??
                              '0',
                          Icons.people_outline,
                        ),
                        _buildStatCard(
                          StringHelper.tr('this_year'),
                          controller.advancedStats['usersThisYear']?.toString() ??
                              '0',
                          Icons.people_alt,
                        ),
                        _buildStatCard(
                          StringHelper.tr('average_recommendations'),
                          (controller
                                      .advancedStats['avgRecommendationsPerUser']
                                  as num?)
                              ?.toStringAsFixed(1) ??
                              '0',
                          Icons.trending_up,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                if (controller.userActivity.isNotEmpty)
                  _buildActivityChart(controller.userActivity),
                const SizedBox(height: 30),
                if (controller.perfumesPerStore.isNotEmpty)
                  _buildPerfumesPerStoreChart(controller.perfumesPerStore),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ThemeConstants.accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ThemeConstants.bodyText2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(Map<int, int> data) {
    final spots =
        data.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringHelper.tr('users_activity_by_hour'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 3 != 0) return const Text('');
                        return Text(
                          '${value.toInt()}:00',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white24),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: ThemeConstants.accentColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: ThemeConstants.accentColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfumesPerStoreChart(Map<String, int> data) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringHelper.tr('perfumes_distribution_by_store'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  final percent = total == 0 ? 0.0 : (entry.value / total) * 100;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${percent.toStringAsFixed(1)}%',
                    color: colors[index % colors.length],
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    '${entry.value} ${StringHelper.tr('perfume_singular')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
