import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/reports/models/user_report_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserReportModel report;

  const UserDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          report.user.name.isNotEmpty
              ? report.user.name
              : StringHelper.tr('userDetailsFallbackTitle'),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              StringHelper.tr('basicInfo'),
              Icons.person,
              [
                _infoRow(StringHelper.tr('nameLabel'), report.user.name),
                _infoRow(StringHelper.tr('phoneLabel'), report.user.phone),
                _infoRow(
                  StringHelper.tr('genderLabel'),
                  _normalizeGender(report.user.gender),
                ),
                _infoRow(StringHelper.tr('countryLabel'), report.user.country),
                _infoRow(
                  StringHelper.tr('registrationDateLabel'),
                  _formatDate(report.user.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.personalityAverages.isNotEmpty)
              _buildSection(
                StringHelper.tr('personalityAnalysis'),
                Icons.psychology,
                report.personalityAverages.entries
                    .where(
                      (e) => ['openness', 'extraversion', 'neuroticism']
                          .contains(e.key),
                    )
                    .map((e) => _traitRow(e.key, e.value))
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (report.personalityAverages.isNotEmpty)
              _buildSection(
                StringHelper.tr('sensoryPreferencesTitle'),
                Icons.favorite,
                report.personalityAverages.entries
                    .where(
                      (e) => ['freshness', 'sweetness', 'warmth', 'intensity']
                          .contains(e.key),
                    )
                    .map((e) => _traitRow(e.key, e.value))
                    .toList(),
              ),
            const SizedBox(height: 16),
            _buildSection(
              StringHelper.tr('statsTitle'),
              Icons.analytics,
              [
                _infoRow(
                  StringHelper.tr('favorite_family'),
                  _normalizeFamily(report.favoriteFamily),
                ),
                _infoRow(
                  StringHelper.tr('recommendations'),
                  report.totalRecommendations.toString(),
                ),
                _infoRow(
                  StringHelper.tr('profile_status'),
                  report.hasCompleteProfile
                      ? StringHelper.tr('profile_complete')
                      : StringHelper.tr('profile_incomplete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeConstants.accentColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : StringHelper.tr('unspecifiedValue'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _traitRow(String trait, double value) {
    final safeValue = value.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_traitLabel(trait), style: const TextStyle(color: Colors.white70)),
              Text('${(safeValue * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: safeValue,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation(ThemeConstants.accentColor),
          ),
        ],
      ),
    );
  }

  String _traitLabel(String trait) {
    switch (trait) {
      case 'openness':
        return StringHelper.tr('trait_openness');
      case 'extraversion':
        return StringHelper.tr('trait_extraversion');
      case 'neuroticism':
        return StringHelper.tr('trait_neuroticism');
      case 'freshness':
        return StringHelper.tr('traitFreshness');
      case 'sweetness':
        return StringHelper.tr('traitSweetness');
      case 'warmth':
        return StringHelper.tr('traitWarmth');
      case 'intensity':
        return StringHelper.tr('traitIntensity');
      default:
        return trait;
    }
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

  String _formatDate(dynamic date) {
    if (date == null) return StringHelper.tr('unknownValue');
    if (date is Timestamp) {
      final value = date.toDate();
      return '${value.year}/${value.month}/${value.day}';
    }
    if (date is DateTime) {
      return '${date.year}/${date.month}/${date.day}';
    }
    return StringHelper.tr('unknownValue');
  }
}
