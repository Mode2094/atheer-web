import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/shared/models/user_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
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
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
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
                  Text(
                    user.name.isNotEmpty ? user.name : context.loc.noName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone.isNotEmpty ? user.phone : context.loc.notAvailable,
                    style: ThemeConstants.bodyText2,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    user.gender.isNotEmpty
                        ? user.gender
                        : context.loc.unspecifiedValue,
                    style: const TextStyle(
                      color: ThemeConstants.accentColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.recommendationsCount(
                    user.pastRecommendations.length,
                  ),
                  style: ThemeConstants.bodyText2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
