import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/features/admin/users/users_controller.dart';
import 'package:perfume/shared/models/recommendation_model.dart';
import 'package:perfume/shared/models/user_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersController>(
        context,
        listen: false,
      ).selectUser(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.user.name.isNotEmpty
              ? widget.user.name
              : context.loc.userDetailsFallbackTitle,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<UsersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeConstants.accentColor),
            );
          }

          final user = controller.selectedUser ?? widget.user;
          final recommendations = controller.userRecommendations;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.basicInfo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(context.loc.nameLabel, user.name),
                      _buildInfoRow(context.loc.phoneLabel, user.phone),
                      _buildInfoRow(context.loc.genderLabel, user.gender),
                      _buildInfoRow(context.loc.countryLabel, user.country),
                      _buildInfoRow(
                        context.loc.registrationDateLabel,
                        _formatDate(user.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (user.personalityProfile.isNotEmpty) ...[
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.personalityAnalysis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTraitBar(
                          context.loc.traitOpenness,
                          _toDouble(user.personalityProfile['openness']),
                        ),
                        _buildTraitBar(
                          context.loc.traitExtraversion,
                          _toDouble(user.personalityProfile['extraversion']),
                        ),
                        _buildTraitBar(
                          context.loc.traitNeuroticism,
                          _toDouble(user.personalityProfile['neuroticism']),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (user.personalityProfile.isNotEmpty) ...[
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.sensoryPreferencesTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTraitBar(
                          context.loc.traitFreshness,
                          _toDouble(user.personalityProfile['freshnessPreference']),
                        ),
                        _buildTraitBar(
                          context.loc.traitSweetness,
                          _toDouble(user.personalityProfile['sweetnessPreference']),
                        ),
                        _buildTraitBar(
                          context.loc.traitWarmth,
                          _toDouble(user.personalityProfile['warmthPreference']),
                        ),
                        _buildTraitBar(
                          context.loc.traitIntensity,
                          _toDouble(user.personalityProfile['intensityPreference']),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.recommendationHistoryTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (recommendations.isEmpty)
                        Center(
                          child: Text(
                            context.loc.noPreviousRecommendations,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ...recommendations.map(_buildRecommendationItem),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : context.loc.unspecifiedValue,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitBar(String label, double value) {
    final safe = value.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(
                '${(safe * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: safe,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation(ThemeConstants.accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(RecommendationModel rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.perfumeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.reason,
                  style: ThemeConstants.bodyText2,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeConstants.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.zero,
            ),
            child: Text(
              '${(rec.confidenceScore * 100).toInt()}%',
              style: const TextStyle(
                color: ThemeConstants.accentColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return 0.5;
  }

  String _formatDate(dynamic date) {
    if (date == null) return context.loc.unknownValue;
    if (date is Timestamp) {
      return '${date.toDate().year}/${date.toDate().month}/${date.toDate().day}';
    }
    if (date is DateTime) {
      return '${date.year}/${date.month}/${date.day}';
    }
    return context.loc.unknownValue;
  }
}
