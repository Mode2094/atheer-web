import 'package:flutter/material.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class StatsCards extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 700
            ? 2
            : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatCard(
              StringHelper.tr('total_users'),
              (stats['totalUsers'] ?? 0).toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              StringHelper.tr('total_recommendations'),
              (stats['totalRecommendations'] ?? 0).toString(),
              Icons.recommend,
              Colors.green,
            ),
            _buildStatCard(
              StringHelper.tr('new_users_month'),
              (stats['newUsersThisMonth'] ?? 0).toString(),
              Icons.person_add,
              Colors.orange,
            ),
            _buildStatCard(
              StringHelper.tr('average_recommendations'),
              _avgLabel(),
              Icons.analytics,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  String _avgLabel() {
    final totalUsers = (stats['totalUsers'] ?? 0) as int;
    final totalRecs = (stats['totalRecommendations'] ?? 0) as int;
    if (totalUsers == 0) return '0';
    return (totalRecs / totalUsers).toStringAsFixed(1);
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
