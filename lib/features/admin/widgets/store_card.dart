import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/widgets/store_actions.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class StoreCard extends StatelessWidget {
  final StoreModel store;
  final bool isSelected;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  void _copyUniqueCode(BuildContext context) {
    FlutterClipboard.copy(store.uniqueCode).then((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${StringHelper.tr('code_copied')}${store.uniqueCode}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ]
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: store.logo.isNotEmpty
                        ? null
                        : ThemeConstants.accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    image: store.logo.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(store.logo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: store.logo.isEmpty
                      ? const Icon(
                          Icons.store,
                          color: ThemeConstants.accentColor,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: ThemeConstants.bodyText2.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _copyUniqueCode(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                ThemeConstants.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.zero,
                            border: Border.all(
                              color: ThemeConstants.accentColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.copy,
                                color: ThemeConstants.accentColor,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${StringHelper.tr('code_label')}${store.uniqueCode}',
                                style: const TextStyle(
                                  color: ThemeConstants.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: ThemeConstants.accentColor,
                    size: 20,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StoreActions(store: store),
        ],
      ),
    );
  }
}
