import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/reports/models/user_report_model.dart';
import 'package:perfume/features/admin/reports/screens/user_details_screen.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class UsersList extends StatelessWidget {
  final List<UserReportModel> users;
  final VoidCallback onRefresh;
  final VoidCallback onExport;

  const UsersList({
    super.key,
    required this.users,
    required this.onRefresh,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${StringHelper.tr('users')} (${users.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedButton(
                            text: StringHelper.tr('export_csv'),
                            icon: Icons.download,
                            onPressed: onExport,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedButton(
                            text: StringHelper.tr('refresh'),
                            icon: Icons.refresh,
                            onPressed: onRefresh,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${StringHelper.tr('users')} (${users.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      AnimatedButton(
                        text: StringHelper.tr('export_csv'),
                        icon: Icons.download,
                        onPressed: onExport,
                        width: 120,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      AnimatedButton(
                        text: StringHelper.tr('refresh'),
                        icon: Icons.refresh,
                        onPressed: onRefresh,
                        width: 100,
                        height: 40,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final report = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildUserCard(context, report),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserReportModel report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsScreen(report: report)),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ThemeConstants.accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  report.user.name.isNotEmpty
                      ? report.user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: ThemeConstants.accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.user.name.isNotEmpty
                              ? report.user.name
                              : StringHelper.tr('new_user'),
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
                          color: report.hasCompleteProfile
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          report.hasCompleteProfile
                              ? StringHelper.tr('profile_complete')
                              : StringHelper.tr('profile_incomplete'),
                          style: TextStyle(
                            color: report.hasCompleteProfile
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _infoChip(Icons.phone, report.user.phone),
                      _infoChip(Icons.person, _normalizeGender(report.user.gender)),
                      if (report.user.country.isNotEmpty)
                        _infoChip(Icons.location_on, report.user.country),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _statChip(
                        '${StringHelper.tr('favorite_family')}: ${_normalizeFamily(report.favoriteFamily)}',
                        ThemeConstants.accentColor,
                      ),
                      _statChip(
                        '${StringHelper.tr('recommendations')}: ${report.totalRecommendations}',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          text.isEmpty ? StringHelper.tr('unspecifiedValue') : text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.zero,
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  String _normalizeGender(String rawGender) {
    final value = rawGender.toLowerCase().trim();
    if (value == 'male' || value == 'ذكر') return StringHelper.tr('gender_male');
    if (value == 'female' || value == 'أنثى') {
      return StringHelper.tr('gender_female');
    }
    if (value == 'unisex' || value == 'للجنسين') {
      return StringHelper.tr('gender_unisex');
    }
    return rawGender;
  }

  String _normalizeFamily(String rawFamily) {
    final value = rawFamily.toLowerCase().trim();
    if (value.contains('floral') || value.contains('زهري')) {
      return StringHelper.tr('family_floral');
    }
    if (value.contains('oriental') || value.contains('شرقي')) {
      return StringHelper.tr('family_oriental');
    }
    if (value.contains('woody') || value.contains('خشبي')) {
      return StringHelper.tr('family_woody');
    }
    if (value.contains('fresh') || value.contains('منعش')) {
      return StringHelper.tr('family_fresh');
    }
    if (value.contains('fern') || value.contains('سرخسي')) {
      return StringHelper.tr('family_fern');
    }
    return rawFamily;
  }
}
